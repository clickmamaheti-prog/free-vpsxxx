#!/bin/bash
set +e

log() { echo "[$(date '+%H:%M:%S')] [watchdog] $*"; }

log "Watchdog started — monitoring services..."

while true; do
    sleep 30

    # SSH
    if ! pgrep -x sshd >/dev/null 2>&1; then
        log "⚠️ SSH down — restarting"
        /usr/sbin/sshd 2>/dev/null || true
    fi

    # Nginx
    if ! pgrep -x nginx >/dev/null 2>&1; then
        log "⚠️ Nginx down — restarting"
        /usr/sbin/nginx 2>/dev/null || true
    fi

    # bore tunnel manager (supervisord will restart it, just log)
    if ! pgrep -f "bore-setup.sh" >/dev/null 2>&1; then
        log "⚠️ bore manager down — supervisord will restart it"
    fi
done
