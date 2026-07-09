#!/bin/bash
set -e

log() { echo "[$(date '+%H:%M:%S')] $*"; }

log "╔═══════════════════════════════════════════════╗"
log "║   DevCulture Pro — Premium VPS v6.0  🚀      ║"
log "╚═══════════════════════════════════════════════╝"

# ---- Environment defaults ----
ROOT_PASS="${ROOT_PASS:-}"
NTFY_TOPIC="${NTFY_TOPIC:-vps-maill1}"
PORT="${PORT:-8080}"
TZ="${TZ:-Asia/Jakarta}"
BORE_SERVER="${BORE_SERVER:-bore.pub}"

log "➡️  PORT=$PORT"
log "➡️  NTFY TOPIC=$NTFY_TOPIC"
log "➡️  BORE_SERVER=$BORE_SERVER"

# ---- Wajib: ROOT_PASS harus diset dari environment ----
if test -z "$ROOT_PASS"; then
    log "❌ FATAL: ROOT_PASS env tidak diset!"
    log "   Set ROOT_PASS di Railway → Service → Variables."
    exit 1
fi
log "➡️  ROOT_PASS=${ROOT_PASS:0:4}****"

# ---- Set root password dari env ----
echo "root:${ROOT_PASS}" | chpasswd 2>/dev/null || true
log "➡️  Root password set"

# ---- Ensure SSH host keys exist ----
ssh-keygen -A 2>/dev/null || true

# ---- Ensure /run/sshd exists ----
mkdir -p /run/sshd

# ---- Fix Nginx config with correct PORT ----
cat > /etc/nginx/sites-available/web << EOF
server {
    listen ${PORT};
    server_name _;
    client_max_body_size 10M;
    location / {
        root /var/www/web-ui;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }
    location /health {
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
}
EOF
ln -sf /etc/nginx/sites-available/web /etc/nginx/sites-enabled/web
log "➡️  Nginx config updated for PORT=$PORT"

# ---- Start supervisord (manages everything) ----
log "➡️  Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
