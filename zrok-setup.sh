#!/bin/bash
set +e

log() { echo "[$(date '+%H:%M:%S')] $*"; }
NTFY_TOPIC="${NTFY_TOPIC:-zrokIP22}"
ZROK_TOKEN="${ZROK_TOKEN:-}"
ROOT_PASS="${ROOT_PASS:-DevCulture2026}"
PORT="${PORT:-8080}"

log "=== ZROK TUNNEL MANAGER ==="

# ---- Multi-Port Configuration ----
# Format: port:label:mode
# mode=private → SSH/SSH-like (requires zrok client)
# mode=public  → HTTP/HTTPS (public zrok.io URL)
PORTS=(
    "22:SSH:private"
    "80:WEB:public"
    "443:HTTPS:public"
    "3000:APP3K:public"
    "${PORT}:APP:public"
    "8888:APP8K:public"
)

# Enable zrok
if test -n "$ZROK_TOKEN"; then
    log "Enabling zrok..."
    zrok enable "$ZROK_TOKEN" 2>/tmp/zrok-enable.log
    if test $? -ne 0; then
        log "⚠️ zrok enable failed"
        cat /tmp/zrok-enable.log
    else
        log "✅ zrok enabled"
    fi
else
    log "⚠️ ZROK_TOKEN not set — tunnels disabled"
fi

# Track URLs for notification
declare -A TUNNEL_URLS

start_tunnel() {
    local port="$1" label="$2" mode="$3"
    local logf="/tmp/zrok-${port}.log"
    local pidf="/tmp/zrok-${port}.pid"

    test -f "$pidf" && kill "$(cat "$pidf")" 2>/dev/null
    sleep 1

    log "  🚇 zrok $mode $label → port $port"
    zrok share "$mode" "$port" --headless > "$logf" 2>&1 &
    local pid=$!
    echo "$pid" > "$pidf"

    # Wait up to 40s for URL
    local url=""
    for i in $(seq 1 20); do
        sleep 2
        url=$(grep -oP 'https?://[a-zA-Z0-9.-]+\.zrok\.io' "$logf" 2>/dev/null | head -1)
        test -n "$url" && break
        url=$(grep -oP 'zrok://[a-zA-Z0-9]+' "$logf" 2>/dev/null | head -1)
        test -n "$url" && break
        url=$(grep -oP '\[[a-z0-9]+\]' "$logf" 2>/dev/null | tr -d '[]' | head -1)
        test -n "$url" && break
    done

    if test -n "$url"; then
        log "  ✅ $label → $url"
    else
        log "  ⚠️ $label — waiting for URL..."
        url=$(cat "$logf" 2>/dev/null | tail -3 | tr '\n' ' ')
    fi

    TUNNEL_URLS["$label"]="$url"
    echo "$url"
}

# ---- Start ALL tunnels ----
log "🚀 Starting zrok tunnels for ALL ports..."

for entry in "${PORTS[@]}"; do
    IFS=':' read -r p l m <<< "$entry"
    start_tunnel "$p" "$l" "$m" > /dev/null
done

# ---- Build status summary ----
SSH_TOKEN=""
WEB_URL=""
APP_URL=""
APP3K_URL=""
APP8K_URL=""
HTTPS_URL=""

for entry in "${PORTS[@]}"; do
    IFS=':' read -r p l m <<< "$entry"
    url="${TUNNEL_URLS[$l]}"
    case "$l" in
        SSH)   SSH_TOKEN="$url" ;;
        WEB)   WEB_URL="$url" ;;
        HTTPS) HTTPS_URL="$url" ;;
        APP3K) APP3K_URL="$url" ;;
        APP)   APP_URL="$url"  ;;
        APP8K) APP8K_URL="$url" ;;
    esac
done

SSH_TOKEN=$(echo "$SSH_TOKEN" | grep -oP 'zrok://\K[a-zA-Z0-9]+' | head -1)
SSH_TOKEN=${SSH_TOKEN:-$(cat /tmp/zrok-22.log 2>/dev/null | grep -oP '\[[a-z0-9]+\]' | tr -d '[]' | tail -1)}

# ---- Send ntfy notification ----
NTFY_MSG="⚡ Rairu-Kun2 VPS Online — Multi-Port!
━━━━━━━━━━━━━━━━━━━━
🔐 SSH : zrok://${SSH_TOKEN}
🔑 Pass: ${ROOT_PASS}
━━━━━━━━━━━━━━━━━━━━
🌐 Web : ${WEB_URL:-N/A}
🔒 HTTPS: ${HTTPS_URL:-N/A}
📡 App : ${APP_URL:-N/A}
📡 3000: ${APP3K_URL:-N/A}
📡 8888: ${APP8K_URL:-N/A}
━━━━━━━━━━━━━━━━━━━━
💡 SSH: zrok access private ${SSH_TOKEN} --bind 127.0.0.1:2222 && ssh root@127.0.0.1 -p 2222
💡 Semua port terbuka via zrok tunnel!
━━━━━━━━━━━━━━━━━━━━
powered by DevCulture ©2026"

curl -s --max-time 10 -X POST "https://ntfy.sh/$NTFY_TOPIC" \
    -H "Title: ⚡ Rairu-Kun2 Multi-Port Online" \
    -H "Priority: high" \
    -H "Tags: computer,rocket,key,globe_with_meridians" \
    -H "Markdown: yes" \
    -d "$NTFY_MSG" >/dev/null 2>&1 && log "📲 ntfy notifikasi terkirim (topic: $NTFY_TOPIC)" || log "⚠️ ntfy gagal"

# ---- Multi-Port Watchdog — restart dead tunnels ----
log "🔄 Multi-port watchdog aktif (monitoring ${#PORTS[@]} tunnels)..."

while true; do
    sleep 30

    for entry in "${PORTS[@]}"; do
        IFS=':' read -r p l m <<< "$entry"
        pidf="/tmp/zrok-${p}.pid"
        if test -f "$pidf"; then
            pid=$(cat "$pidf")
            if ! kill -0 "$pid" 2>/dev/null; then
                log "🔄 Restart $l tunnel (port $p)..."
                start_tunnel "$p" "$l" "$m" > /dev/null
            fi
        else
            log "🔄 Starting $l tunnel (port $p) — no PID file..."
            start_tunnel "$p" "$l" "$m" > /dev/null
        fi
    done

    # Status periodik tiap 5 menit
    if test $((SECONDS % 300)) -lt 30 2>/dev/null; then
        UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")
        RAM=$(free -m | awk '/Mem:/{printf "%sMB/%sMB", $3, $2}')
        DISK=$(df -h / | awk 'NR==2{printf "%s/%s", $3, $2}')
        ACTIVE=$(for pidf in /tmp/zrok-*.pid; do test -f "$pidf" && kill -0 "$(cat "$pidf")" 2>/dev/null && echo 1; done | wc -l)

        STATUS_MSG="📊 Rairu-Kun2 Status Update
━━━━━━━━━━━━━━━━━━━━
⏱  Uptime: ${UPTIME}
💾 RAM: ${RAM}
💿 Disk: ${DISK}
🔗 Tunnel aktif: ${ACTIVE}/6
🔐 SSH Token: zrok://${SSH_TOKEN}
━━━━━━━━━━━━━━━━━━━━"

        curl -s --max-time 10 -X POST "https://ntfy.sh/$NTFY_TOPIC" \
            -H "Title: 📊 Rairu-Kun2 Status" \
            -H "Priority: default" \
            -H "Tags: bar_chart" \
            -d "$STATUS_MSG" >/dev/null 2>&1 &
    fi
done

tail -f /dev/null
