#!/bin/bash
# VECTOR — Premium SSH VPS Banner (responsive center)

# ─── ANSI Colors ───
ORG='\e[38;2;255;165;0m'      # Orange (#FFA500)
BORG='\e[1;38;2;255;165;0m'   # Bold Orange
LGR='\e[1;38;2;127;255;0m'    # Light Green stabilo (#7FFF00)
RS='\e[0m'                    # Reset

# ─── Center helper (responsif terhadap lebar terminal) ───
# Menghitung lebar terminal (tput cols), lalu memberi padding spasi
# di kiri sehingga setiap baris selalu presisi di tengah layar.
center() {
    local text="$1"
    local cols plain pad
    cols=$(tput cols 2>/dev/null || echo 80)
    plain=$(printf '%b' "$text" | sed -r 's/\x1B\[[0-9;]*[mK]//g')
    pad=$(( (cols - ${#plain}) / 2 ))
    [ "$pad" -lt 0 ] && pad=0
    printf "%${pad}s%b\n" "" "$text"
}

# ─── Banner ───────────────────────────────────────────
echo ""
center "${BORG}██╗   ██╗ ███████╗  ██████╗   ████████╗ ██████╗   ██████╗  ${RS}"
center "${BORG}██║   ██║ ██╔════╝  ██╔═══╝   ╚══██╔══╝ ██╔═══██╗ ██╔═══██╗${RS}"
center "${BORG}██║   ██║ █████╗    ██║          ██║    ██║   ██║ ██████╔╝ ${RS}"
center "${BORG}╚██╗ ██╔╝ ██╔══╝    ██║          ██║    ██║   ██║ ██╔══██╗ ${RS}"
center "${BORG} ╚████╔╝  ███████╗  ╚██████╗     ██║    ╚██████╔╝ ██║  ██║ ${RS}"
center "${BORG}  ╚═══╝   ╚══════╝   ╚═════╝     ╚═╝     ╚═════╝  ╚═╝  ╚═╝ ${RS}"
echo ""
center "${LGR}[copyright by facebook florezha.id]${RS}"
echo ""
