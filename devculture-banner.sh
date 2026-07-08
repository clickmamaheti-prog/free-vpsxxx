#!/bin/bash
# DevCulture Rairu-Kun2 SSH Banner

TITLE=""
TITLE+="╔═══════════════════════════════════════════════╗\n"
TITLE+="║                                               ║\n"
TITLE+="║        ★  RAIRU-KUN2 PREMIUM VPS  ★          ║\n"
TITLE+="║         powered by bore tunnel               ║\n"
TITLE+="╠═══════════════════════════════════════════════╣\n"

RAM=$(free -m | awk '/Mem:/{printf "%sMB/%sMB (%d%%)", $3, $2, $3*100/$2}' 2>/dev/null || echo "N/A")
DISK=$(df -h / | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}' 2>/dev/null || echo "N/A")
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")

TITLE+="║  OS    : Ubuntu 20.04 LTS                     ║\n"
TITLE+="║  RAM   : ${RAM}                    ║\n"
TITLE+="║  Disk  : ${DISK}               ║\n"
TITLE+="║  Uptime: ${UPTIME}                     ║\n"
TITLE+="╠═══════════════════════════════════════════════╣\n"

# Check bore tunnels
BORE_SERVER="${BORE_SERVER:-bore.pub}"
for port in 22 "${PORT:-8080}" 3000; do
    pidf="/tmp/bore-${port}.pid"
    logf="/tmp/bore-${port}.log"
    if test -f "$pidf" && kill -0 "$(cat "$pidf" 2>/dev/null)" 2>/dev/null; then
        BADDR=$(grep -oP "${BORE_SERVER}:\K[0-9]+" "$logf" 2>/dev/null | head -1)
        BTEXT="${BORE_SERVER}:${BADDR:-?} ● Running"
    else
        BTEXT="○ Stopped"
    fi
    TITLE+="║  :${port}  : ${BTEXT}              ║\n"
done

TITLE+="╚═══════════════════════════════════════════════╝\n"
TITLE+="         powered by: DevCulture ©2026 linux\n"

echo -e "$TITLE"

echo ""
echo -e "  📊 \e[36mSystem Info\e[0m"
echo -e "  ─────────────────────────────────────────────"
echo -e "  \e[33mOS\e[0m        Ubuntu 20.04 LTS"
echo -e "  \e[33mRAM\e[0m       ${RAM}"
echo -e "  \e[33mDisk\e[0m      ${DISK}"
echo -e "  \e[33mUptime\e[0m    ${UPTIME}"
echo ""
