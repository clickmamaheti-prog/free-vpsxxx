#!/bin/bash
set +e

log() { echo "[$(date '+%H:%M:%S')] $*"; }

NTFY_TOPIC="${NTFY_TOPIC:-vps-maill1}"
BORE_SERVER="${BORE_SERVER:-bore.pub}"
ROOT_PASS="${ROOT_PASS:-}"
PORT="${PORT:-8080}"

log "=== DEVCULTURE PRO — BORE TUNNEL MANAGER ==="
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
declare -A RESTART_COUNT

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

build_status_msg() {
    local mode="$1"   # "online" | "restart" | "status"
    local reason="$2" # Untuk restart: label tunnel yang restart
    local ssh_addr="${TUNNEL_URLS[SSH]:-N/A}"
    local app_addr="${TUNNEL_URLS[APP]:-N/A}"
    local app3k_addr="${TUNNEL_URLS[APP3K]:-N/A}"
    local ssh_port="${TUNNEL_PORTS[SSH]:-}"
    local uptime
    uptime=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")
    local ram
    ram=$(free -m | awk '/Mem:/{printf "%sMB/%sMB (%d%%)", $3, $2, $3*100/$2}' 2>/dev/null || echo "N/A")

    local ssh_cmd="N/A"
    if test -n "$ssh_port"; then
        ssh_cmd="ssh root@${BORE_SERVER} -p ${ssh_port}"
    fi

    local header="" footer=""
    case "$mode" in
        online)
            header="⚡ DevCulture Pro VPS — ONLINE"
            footer="🟢 Status  : First boot — semua tunnel aktif"
            ;;
        restart)
            header="🔄 DevCulture Pro VPS — AUTO RESTART"
            footer="♻️ Restart : Tunnel ${reason} mati → auto restart oleh watchdog
🤖 Engine  : supervisord + bore watchdog"
            ;;
        status)
            header="📊 DevCulture Pro VPS — STATUS UPDATE"
            footer="⏱  Uptime  : ${uptime}
💾 RAM     : ${ram}"
            ;;
    esac

    echo "${header}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 SSH   : ${ssh_addr}
💡 Cmd   : ${ssh_cmd}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📡 App   : ${app_addr}
📡 3000  : ${app3k_addr}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${footer}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ℹ️  Password : set via ROOT_PASS env
🚀 Powered by DevCulture Pro ©2026"
}

# ─── Start ALL tunnels ─────────────────────────────────
log "🚀 Starting bore tunnels..."
for entry in "${PORTS[@]}"; do
    IFS=':' read -r p l <<< "$entry"
    RESTART_COUNT["$l"]=0
    start_tunnel "$p" "$l"
done

send_ntfy "⚡ DevCulture Pro VPS — ONLINE" "high" "$(build_status_msg online)"

# ─── Watchdog loop ────────────────────────────────────
log "🔄 Watchdog aktif (${#PORTS[@]} tunnels)..."
LAST_STATUS_TIME=0

while true; do
    sleep 30

    CHANGED=false
    RESTARTED_LABELS=""

    for entry in "${PORTS[@]}"; do
        IFS=':' read -r p l <<< "$entry"
        pidf="/tmp/bore-${p}.pid"
        old_addr="${TUNNEL_URLS[$l]}"

        needs_restart=false
        if test -f "$pidf"; then
            pid=$(cat "$pidf" 2>/dev/null)
            kill -0 "$pid" 2>/dev/null || needs_restart=true
        else
            needs_restart=true
        fi

        if $needs_restart; then
            RESTART_COUNT["$l"]=$(( ${RESTART_COUNT[$l]:-0} + 1 ))
            log "♻️  Auto-restart $l (port $p) — restart #${RESTART_COUNT[$l]}..."
            start_tunnel "$p" "$l"
            if test "${TUNNEL_URLS[$l]}" != "$old_addr"; then
                CHANGED=true
            fi
            RESTARTED_LABELS="${RESTARTED_LABELS}${l}(#${RESTART_COUNT[$l]}) "
        fi
    done

    # Re-notify jika ada restart atau port berubah
    if test -n "$RESTARTED_LABELS"; then
        log "🔔 Kirim notifikasi auto-restart: $RESTARTED_LABELS"
        send_ntfy "🔄 DevCulture Pro — AUTO RESTART" "high" \
            "$(build_status_msg restart "$RESTARTED_LABELS")"
    elif test "$CHANGED" = "true"; then
        send_ntfy "🔄 DevCulture Pro — PORT BERUBAH" "default" \
            "$(build_status_msg restart "port changed")"
    fi

    # Status periodik tiap 5 menit
    NOW=$SECONDS
    if test $((NOW - LAST_STATUS_TIME)) -ge 300; then
        LAST_STATUS_TIME=$NOW
        ACTIVE=0
        for pidf in /tmp/bore-*.pid; do
            test -f "$pidf" && kill -0 "$(cat "$pidf" 2>/dev/null)" 2>/dev/null && ACTIVE=$((ACTIVE+1))
        done
        log "📊 Status periodik — ${ACTIVE}/${#PORTS[@]} tunnels aktif"
        send_ntfy "📊 DevCulture Pro — STATUS" "default" \
            "$(build_status_msg status)
🔗 Tunnels: ${ACTIVE}/${#PORTS[@]} aktif"
    fi
done
