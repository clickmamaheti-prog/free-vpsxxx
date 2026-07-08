#!/bin/bash
set -e

log() { echo "[$(date '+%H:%M:%S')] $*"; }

log "╔═══════════════════════════════════════╗"
log "║   Rairu-Kun2 — DevCulture VPS v5.0   ║"
log "╚═══════════════════════════════════════╝"

# ---- Environment defaults ----
ROOT_PASS="${ROOT_PASS:-DevCulture2026}"
NTFY_TOPIC="${NTFY_TOPIC:-Rosma-vps}"
PORT="${PORT:-8080}"
TZ="${TZ:-Asia/Jakarta}"
BORE_SERVER="${BORE_SERVER:-bore.pub}"

log "➡️ PORT=$PORT"
log "➡️ NTFY TOPIC=$NTFY_TOPIC"
log "➡️ BORE_SERVER=$BORE_SERVER"
log "➡️ ROOT_PASS=${ROOT_PASS:0:4}****"

# ---- Set root password ----
echo "root:${ROOT_PASS}" | chpasswd 2>/dev/null || true
log "➡️ Root password set"

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
log "➡️ Nginx config updated for PORT=$PORT"

# ---- Ensure SSH host keys exist ----
ssh-keygen -A 2>/dev/null || true

# ---- Ensure /run/sshd exists ----
mkdir -p /run/sshd

# ---- Start supervisord (manages everything) ----
log "➡️ Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
