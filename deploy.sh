#!/usr/bin/env bash
# ============================================================================
#  DevCulture free-vpsxxx — Deploy Helper (CLI & GHCR)
# ----------------------------------------------------------------------------
#  Cara pakai:
#    ./deploy.sh cli    [ROOT_PASS]   Deploy ke Railway via Railway CLI (dari repo ini)
#    ./deploy.sh ghcr   [ROOT_PASS]   Jalankan image GHCR dengan Docker (local/VPS)
#    ./deploy.sh pull                 Tarik image GHCR terbaru
#    ./deploy.sh help                 Bantuan ini
#
#  ROOT_PASS bisa dikirim sebagai argumen, atau via env ROOT_PASS.
#  Jika kosong, script akan men-generate password acak yang kuat.
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="ghcr.io/clickmamaheti-prog/free-vpsxxx:latest"

say()  { printf '\033[1;36m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m⚠️  %s\033[0m\n' "$*"; }
die()  { printf '\033[1;31m❌ %s\033[0m\n' "$*"; exit 1; }

gen_password() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 18 | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c 20
    else
        echo "Dev$(date +%s)Pro!2026"
    fi
}

resolve_root_pass() {
    # Prioritas: argumen > env ROOT_PASS > generate acak
    local pass="${1:-}"
    if test -z "$pass"; then pass="${ROOT_PASS:-}"; fi
    if test -z "$pass"; then
        pass="$(gen_password)"
        warn "ROOT_PASS tidak diberikan — password acak dibuat: ${pass}"
        warn "Simpan password ini baik-baik! (atau set env ROOT_PASS / argumen)"
    fi
    printf '%s' "$pass"
}

# ─── Mode: Railway CLI ──────────────────────────────────────────────────────
deploy_cli() {
    local pass
    pass="$(resolve_root_pass "$1")"

    say "🚂 Mode: Railway CLI deploy"
    cd "$SCRIPT_DIR"

    # Mode cli WAJIB dijalankan dari checkout repo ini (bukan via one-liner/pipe),
    # karena railway up meng-upload isi folder saat ini.
    if ! test -f "$SCRIPT_DIR/Dockerfile"; then
        die "Mode 'cli' harus dijalankan dari repo yang sudah di-clone." \
            "   git clone https://github.com/clickmamaheti-prog/free-vpsxxx.git && cd free-vpsxxx && ./deploy.sh cli"
    fi

    if ! command -v railway >/dev/null 2>&1; then
        warn "Railway CLI belum terinstall — menginstall via npm..."
        command -v npm >/dev/null 2>&1 || die "npm tidak ditemukan. Install Node.js dulu."
        npm install -g @railway/cli
    fi

    # Cek autentikasi
    if ! railway whoami --json >/dev/null 2>&1; then
        die "Belum login Railway. Jalankan:  railway login   (atau set env RAILWAY_API_TOKEN)"
    fi

    say "➡️  Deploy dari folder repo ini (buat project + service otomatis)..."
    railway up -y -m "deploy free-vpsxxx (Ubuntu 24.04)"

    # Set variabel wajib (trigger redeploy otomatis)
    say "➡️  Set variabel ROOT_PASS..."
    if railway variable set "ROOT_PASS=$pass" 2>/dev/null; then
        say "✅ ROOT_PASS terset"
    else
        warn "Gagal set variabel otomatis. Link dulu, lalu set manual:"
        echo "   railway link"
        echo "   railway variable set ROOT_PASS='$pass'"
    fi
    if test -n "${NTFY_TOPIC:-}"; then
        railway variable set "NTFY_TOPIC=$NTFY_TOPIC" 2>/dev/null || true
    fi

    say "✅ Selesai! Pantau status:"
    echo "   railway deployment list --json"
    echo "   railway logs --lines 200"
    echo ""
    echo "🔐 SSH  : tunggu notifikasi ntfy (jika NTFY_TOPIC diset) → ssh root@bore.pub -p <PORT>"
}

# ─── Mode: GHCR (Docker) ────────────────────────────────────────────────────
deploy_ghcr() {
    local pass
    pass="$(resolve_root_pass "$1")"

    say "🐳 Mode: GHCR image ($IMAGE)"
    command -v docker >/dev/null 2>&1 || die "Docker tidak ditemukan. Install Docker dulu: https://docs.docker.com/get-docker/"

    say "➡️  Menarik image terbaru..."
    docker pull "$IMAGE"

    say "➡️  Menjalankan container free-vpsxxx..."
    docker rm -f free-vpsxxx >/dev/null 2>&1 || true
    docker run -d \
        --name free-vpsxxx \
        --restart unless-stopped \
        -e "ROOT_PASS=$pass" \
        -e "NTFY_TOPIC=${NTFY_TOPIC:-}" \
        -e "BORE_SERVER=${BORE_SERVER:-bore.pub}" \
        -e "TZ=${TZ:-Asia/Jakarta}" \
        -e "PORT=${PORT:-8080}" \
        -p "${PUBLIC_HTTP_PORT:-${PORT:-8080}}:${PORT:-8080}" \
        "$IMAGE"

    say "✅ Container jalan! Lihat log:"
    echo "   docker logs -f free-vpsxxx"
    echo ""
    echo "🌐 Web UI : http://localhost:${PUBLIC_HTTP_PORT:-8080}"
    echo "🔐 SSH    : tunggu log bore → ssh root@bore.pub -p <PORT>"
}

# ─── Mode: pull saja ────────────────────────────────────────────────────────
pull_only() {
    say "📥 Menarik $IMAGE"
    docker pull "$IMAGE" 2>/dev/null || warn "Docker tidak tersedia — pull lewat docker/registri lain, atau gunakan mode 'ghcr'."
}

usage() {
    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

case "${1:-help}" in
    cli)   deploy_cli "${2:-}" ;;
    ghcr)  deploy_ghcr "${2:-}" ;;
    pull)  pull_only ;;
    help|-h|--help) usage ;;
    *)     warn "Mode tidak dikenal: $1"; echo ""; usage ;;
esac
