#!/bin/bash
set +e

log() { echo "[$(date '+%H:%M:%S')] $*"; }
NTFY_TOPIC="${NTFY_TOPIC:-zrokIP22}"
ZROK_TOKEN="${ZROK_TOKEN:-}"
ROOT_PASS="${ROOT_PASS:-DevCulture2026}"
PORT="${PORT:-8080}"

log "=== ZROK TUNNEL MANAGER ==="

# Enable zrok if token is provided
if test -n "$ZROK_TOKEN"; then
    log "Enabling zrok..."
    zrok enable "$ZROK_TOKEN" 2>/tmp/zrok-enable.log
    ZROK_OK=$?
    if test $ZROK_OK -ne 0; then
        log "⚠️ zrok enable failed (see /tmp/zrok-enable.log)"
        cat /tmp/zrok-enable.log
    else
        log "✅ zrok enabled successfully"
    fi
else
    log "⚠️ ZROK_TOKEN not set — zrok tunnels disabled. Set env ZROK_TOKEN to enable."
fi

SSH_SHARE=""
WEB_SHARE=""
APP_SHARE=""

# Start tunnels in background with auto-retry
start_tunnel() {
    local port="$1" label="$2" mode="$3"
    local logf="/tmp/zrok-${port}.log"
    local pidf="/tmp/zrok-${port}.pid"
    local url_var
    
    test -f "$pidf" && kill "$(cat "$pidf")" 2>/dev/null
    sleep 1
    
    log "Starting zrok share $mode $label on port $port..."
    
    if test "$mode" = "private"; then
        zrok share private "$port" --headless > "$logf" 2>&1 &
    else
        zrok share public "$port" --headless > "$logf" 2>&1 &
    fi
    local pid=$!
    echo "$pid" > "$pidf"
    
    # Wait for URL
    for i in $(seq 1 20); do
        sleep 2
        local url=""
        url=$(grep -oP 'https?://[a-zA-Z0-9.-]+\.zrok\.io' "$logf" 2>/dev/null | head -1)
        test -n "$url" && break
        url=$(grep -oP 'zrok://[a-zA-Z0-9]+' "$logf" 2>/dev/null | head -1)
        test -n "$url" && break
    done
    
    if test -n "$url"; then
        log "  ✅ $label → $url"
    else
        log "  ⚠️ $label URL not found yet (will retry later)"
        url=$(cat "$logf" 2>/dev/null | tail -5)
    fi
    
    echo "$url"
}

# Start all tunnels
log "🚀 Starting zrok tunnels..."
SSH_URL=$(start_tunnel 22 "SSH" "private")
WEB_URL=$(start_tunnel 80 "WEB" "public")
APP_URL=$(start_tunnel "${PORT:-8080}" "APP" "public")

# ---- Extract SSH token ----
SSH_TOKEN=$(echo "$SSH_URL" | grep -oP 'zrok://\K[a-zA-Z0-9]+' | head -1)
SSH_TOKEN=${SSH_TOKEN:-$(cat /tmp/zrok-22.log 2>/dev/null | grep -oP '\[[a-z0-9]+\]' | tr -d '[]' | head -1)}
WEB_DOMAIN=$(echo "$WEB_URL" | grep -oP 'https?://\K[a-zA-Z0-9.-]+zrok\.io')

# ---- Send ntfy notification ----
NTFY_MSG="⚡ Rairu-Kun2 VPS Online!
━━━━━━━━━━━━━━━━━━━━
🔐 SSH: zrok://${SSH_TOKEN}
🔑 Password: ${ROOT_PASS}
🌐 Web UI: ${WEB_URL:-N/A}
📡 App: ${APP_URL:-N/A}
━━━━━━━━━━━━━━━━━━━━
💡 SSH Access:
   zrok access private ${SSH_TOKEN} --bind 127.0.0.1:2222
   ssh root@127.0.0.1 -p 2222

━━━━━━━━━━━━━━━━━━━━
powered by DevCulture ©2026"

curl -s --max-time 10 -X POST "https://ntfy.sh/$NTFY_TOPIC" \
    -H "Title: ⚡ Rairu-Kun2 VPS Online" \
    -H "Priority: high" \
    -H "Tags: computer,rocket,key" \
    -H "Markdown: yes" \
    -d "$NTFY_MSG" >/dev/null 2>&1 && log "📲 ntfy notification sent (topic: $NTFY_TOPIC)" || log "⚠️ ntfy send failed"

# ---- Watch tunnels — restart if dead ----
while true; do
    sleep 30
    
    for entry in "22:SSH:private" "80:WEB:public" "${PORT:-8080}:APP:public"; do
        IFS=':' read -r p l m <<< "$entry"
        pidf="/tmp/zrok-${p}.pid"
        if test -f "$pidf"; then
            pid=$(cat "$pidf")
            if ! kill -0 "$pid" 2>/dev/null; then
                log "🔄 Restarting $l tunnel (port $p)..."
                start_tunnel "$p" "$l" "$m" > /dev/null
            fi
        fi
    done
    
    # Periodic status update every 5 min
    if test $((SECONDS % 300)) -lt 30 2>/dev/null; then
        UPTIME=$(uptime -p 2>/dev/null | sed 's/up //')
        RAM=$(free -m | awk '/Mem:/{printf "%sMB/%sMB", $3, $2}')
        DISK=$(df -h / | awk 'NR==2{printf "%s/%s", $3, $2}')
        
        STATUS_MSG="📊 Rairu-Kun2 Status Update
━━━━━━━━━━━━━━━━━━━━
⏱  Uptime: ${UPTIME}
💾 RAM: ${RAM}
💿 Disk: ${DISK}
🔐 SSH Token: zrok://${SSH_TOKEN}
━━━━━━━━━━━━━━━━━━━━"
        
        curl -s --max-time 10 -X POST "https://ntfy.sh/$NTFY_TOPIC" \
            -H "Title: 📊 Rairu-Kun2 Status" \
            -H "Priority: default" \
            -H "Tags: bar_chart" \
            -d "$STATUS_MSG" >/dev/null 2>&1 &
    fi
done

# Keep alive (shouldn't reach here)
tail -f /dev/null
