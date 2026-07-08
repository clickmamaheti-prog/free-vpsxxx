#!/bin/bash
set +e

log() { echo "[$(date '+%H:%M:%S')] $*"; }

NTFY_TOPIC="${NTFY_TOPIC:-Rosma-vps}"
BORE_SERVER="${BORE_SERVER:-bore.pub}"
ROOT_PASS="${ROOT_PASS:-}"
PORT="${PORT:-8080}"

log "=== BORE TUNNEL MANAGER ==="
log "Server: $BORE_SERVER"
log "ntfy topic: $NTFY_TOPIC"

# Ports to tunnel: port:label
PORTS=(
    "22:SSH"
    "${PORT}:APP"
    "3000:APP3K"
)

declare -A TUNNEL_URLS
declare -A TUNNEL_PORTS

start_tunnel() {
    local port="$1" label="$2"
    local logf="/tmp/bore-${port}.log"
    local pidf="/tmp/bore-${port}.pid"

    # Kill existing tunnel on this port if running
    if test -f "$pidf"; then
        local old_pid
        old_pid=$(cat "$pidf" 2>/dev/null)
        kill "$old_pid" 2>/dev/null
        rm -f "$pidf"
    fi
    sleep 1

    # Clear old log
    > "$logf"

    log "  🚇 bore local $port → $BORE_SERVER ($label)"
    bore local "$port" --to "$BORE_SERVER" >> "$logf" 2>&1 &
    local pid=$!
    echo "$pid" > "$pidf"

    # Wait up to 30s for bore to output the remote address
    local remote_port=""
    for i in $(seq 1 15); do
        sleep 2
        remote_port=$(grep -oP "listening at ${BORE_SERVER}:\K[0-9]+" "$logf" 2>/dev/null | head -1)
        test -n "$remote_port" && break
        remote_port=$(grep -oP "${BORE_SERVER}:\K[0-9]+" "$logf" 2>/dev/null | head -1)
        test -n "$remote_port" && break
    done

    if test -n "$remote_port"; then
        log "  ✅ $label → ${BORE_SERVER}:${remote_port}"
        TUNNEL_URLS["$label"]="${BORE_SERVER}:${remote_port}"
        TUNNEL_PORTS["$label"]="$remote_port"
    else
        log "  ⚠️ $label — URL not detected yet"
        TUNNEL_URLS["$label"]="connecting..."
        TUNNEL_PORTS["$label"]=""
    fi
}

send_ntfy() {
    local title="$1" priority="$2" msg="$3"
    curl -s --max-time 15 -X POST "https://ntfy.sh/${NTFY_TOPIC}" \
        -H "Title: $title" \
        -H "Priority: $priority" \
        -H "Tags: computer,rocket,key" \
        -d "$msg" >/dev/null 2>&1 \
        && log "📲 ntfy terkirim (topic: $NTFY_TOPIC)" \
        || log "⚠️ ntfy gagal dikirim"
}

build_and_notify() {
    local ssh_addr="${TUNNEL_URLS[SSH]:-N/A}"
    local app_addr="${TUNNEL_URLS[APP]:-N/A}"
    local app3k_addr="${TUNNEL_URLS[APP3K]:-N/A}"
    local ssh_port="${TUNNEL_PORTS[SSH]:-}"

    local ssh_cmd="N/A"
    if test -n "$ssh_port"; then
        ssh_cmd="ssh root@${BORE_SERVER} -p ${ssh_port}"
    fi

    # TIDAK kirim password via ntfy — hanya info koneksi
    local msg="⚡ Rairu-Kun2 VPS Online — bore tunnel!
━━━━━━━━━━━━━━━━━━━━
🔐 SSH  : ${ssh_addr}
💡 Cmd  : ${ssh_cmd}
━━━━━━━━━━━━━━━━━━━━
📡 App  : ${app_addr}
📡 3000 : ${app3k_addr}
━━━━━━━━━━━━━━━━━━━━
ℹ️ Password: lihat env ROOT_PASS di Railway
━━━━━━━━━━━━━━━━━━━━
powered by DevCulture ©2026 (bore)"

    send_ntfy "⚡ Rairu-Kun2 VPS Online" "high" "$msg"
}

# ---- Start ALL tunnels ----
log "🚀 Starting bore tunnels..."
for entry in "${PORTS[@]}"; do
    IFS=':' read -r p l <<< "$entry"
    start_tunnel "$p" "$l"
done

build_and_notify

# ---- Watchdog loop — restart dead tunnels + re-notify jika port berubah ----
log "🔄 Bore tunnel watchdog aktif (${#PORTS[@]} tunnels)..."
LAST_STATUS_TIME=0

while true; do
    sleep 30

    CHANGED=false
    for entry in "${PORTS[@]}"; do
        IFS=':' read -r p l <<< "$entry"
        pidf="/tmp/bore-${p}.pid"
        old_addr="${TUNNEL_URLS[$l]}"

        if test -f "$pidf"; then
            pid=$(cat "$pidf")
            if ! kill -0 "$pid" 2>/dev/null; then
                log "🔄 Restart $l tunnel (port $p)..."
                start_tunnel "$p" "$l"
                # Jika port berubah setelah restart, tandai untuk re-notify
                if test "${TUNNEL_URLS[$l]}" != "$old_addr"; then
                    CHANGED=true
                fi
            fi
        else
            log "🔄 Starting $l tunnel (port $p) — no PID found..."
            start_tunnel "$p" "$l"
            CHANGED=true
        fi
    done

    # Re-kirim notifikasi jika SSH port berubah
    if test "$CHANGED" = "true"; then
        log "🔔 Port berubah — kirim notifikasi update..."
        build_and_notify
    fi

    # Status periodik tiap 5 menit
    NOW=$SECONDS
    if test $((NOW - LAST_STATUS_TIME)) -ge 300; then
        LAST_STATUS_TIME=$NOW
        UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")
        RAM=$(free -m | awk '/Mem:/{printf "%sMB/%sMB", $3, $2}')
        DISK=$(df -h / | awk 'NR==2{printf "%s/%s", $3, $2}')
        ACTIVE=0
        for pidf in /tmp/bore-*.pid; do
            test -f "$pidf" && kill -0 "$(cat "$pidf")" 2>/dev/null && ACTIVE=$((ACTIVE+1))
        done
        SSH_ADDR="${TUNNEL_URLS[SSH]:-N/A}"

        STATUS_MSG="📊 Rairu-Kun2 Status Update
━━━━━━━━━━━━━━━━━━━━
⏱  Uptime : ${UPTIME}
💾 RAM    : ${RAM}
💿 Disk   : ${DISK}
🔗 Tunnels: ${ACTIVE}/${#PORTS[@]} aktif
🔐 SSH    : ${SSH_ADDR}
━━━━━━━━━━━━━━━━━━━━"

        send_ntfy "📊 Rairu-Kun2 Status" "default" "$STATUS_MSG"
    fi
done
