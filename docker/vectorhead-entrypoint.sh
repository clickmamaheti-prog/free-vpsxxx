#!/bin/bash
# ============================================================================
# VectorHead server — entrypoint overlay
# 1) Restore operasional dari repo PRIVATE vectorhead-ops (via GH_TOKEN)
# 2) Pastikan vectorhead-ai versi sesuai version.txt
# 3) Jalankan base entrypoint (set ROOT_PASS, SSH keys, nginx, start supervisord)
# ============================================================================
set -u

log() { echo "[$(date '+%H:%M:%S')] [vectorhead] $*"; }

OPS_URL="https://github.com/clickmamaheti-prog/vectorhead-ops.git"

if [ -n "${GH_TOKEN:-}" ]; then
  log "Restore ops dari vectorhead-ops (GH_TOKEN)..."
  rm -rf /tmp/ops-secrets
  if git clone --depth 1 "https://x-access-token:${GH_TOKEN}@github.com/clickmamaheti-prog/vectorhead-ops.git" /tmp/ops-secrets >/dev/null 2>&1; then
    # Binary (cloudflared + bore)
    install -m 755 /tmp/ops-secrets/bin/cloudflared /usr/local/bin/cloudflared 2>/dev/null || true
    install -m 755 /tmp/ops-secrets/bin/bore /usr/local/bin/bore 2>/dev/null || true
    # Script operasional
    install -m 755 /tmp/ops-secrets/current/scripts/* /usr/local/bin/ 2>/dev/null || true
    # Konfigurasi supervisord (program confs, berisi secret dari repo private)
    mkdir -p /etc/supervisor/conf.d
    cp -f /tmp/ops-secrets/current/supervisor/*.conf /etc/supervisor/conf.d/ 2>/dev/null || true
    rm -f /etc/supervisor/conf.d/supervisord.conf   # hindari konflik [supervisord]
    # Kredensial Cloudflare tunnel
    rm -rf /root/.cloudflared
    mkdir -p /root/.cloudflared
    cp -f /tmp/ops-secrets/current/cloudflared/config.yml /root/.cloudflared/ 2>/dev/null || true
    cp -f /tmp/ops-secrets/current/cloudflared/*.json /root/.cloudflared/ 2>/dev/null || true
    # Healthcheck config
    [ -f /tmp/ops-secrets/current/vectorhead-healthcheck.conf ] && install -m 600 /tmp/ops-secrets/current/vectorhead-healthcheck.conf /etc/vectorhead-healthcheck.conf
    # Landing page statis (landing.jokichannel.eu.org)
    if [ -f /tmp/ops-secrets/current/landing/index.html ]; then
      mkdir -p /var/www/landing
      cp -f /tmp/ops-secrets/current/landing/index.html /var/www/landing/ 2>/dev/null || log "⚠️ salin landing gagal"
      log "✅ Landing page siap di /var/www/landing"
    fi
    # cron dibutuhkan service backup otomatis (tidak ada di base image)
    if ! command -v cron >/dev/null 2>&1 && [ ! -x /usr/sbin/cron ]; then
      log "Install cron..."
      apt-get update -qq >/dev/null 2>&1 || true
      DEBIAN_FRONTEND=noninteractive apt-get install -y -qq cron >/dev/null 2>&1 || log "⚠️ apt install cron gagal"
    fi
    # Versi vectorhead-ai sesuai version.txt
    VH_VER=$(cat /tmp/ops-secrets/current/version.txt 2>/dev/null || echo "")
    if [ -n "$VH_VER" ]; then
      CUR=$(vectorhead --version 2>/dev/null | tail -1 || echo "")
      if [ "$CUR" != "$VH_VER" ]; then
        log "Install vectorhead-ai@${VH_VER} (sekarang: ${CUR:-kosong})..."
        npm install -g --no-fund --no-audit "vectorhead-ai@${VH_VER}" >/dev/null 2>&1 || log "⚠️ npm install gagal — lanjut dengan versi yang ada"
      fi
    fi
    log "✅ Restore selesai"
  else
    log "⚠️ Gagal clone vectorhead-ops (GH_TOKEN salah?) — lanjut dengan base"
  fi
  rm -rf /tmp/ops-secrets
else
  log "⚠️ GH_TOKEN kosong — skip restore ops (jalankan base saja)"
fi

# Jalankan base entrypoint (memulai supervisord dengan /etc/supervisor/supervisord.conf)
exec /entrypoint.sh
