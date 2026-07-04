#!/bin/bash
# DevCulture Rairu-Kun2 SSH Banner

TITLE=""
TITLE+="╔══════════════════════════════════════════════════════════════╗\n"
TITLE+="║                                                              ║\n"
TITLE+="║    ██████╗  █████╗ ██╗██████╗ ██╗   ██╗   ██╗  ██╗██╗   ██╗███╗   ██╗ ║\n"
TITLE+="║    ██╔══██╗██╔══██╗██║██╔══██╗██║   ██║   ██║ ██╔╝██║   ██║████╗  ██║ ║\n"
TITLE+="║    ██████╔╝███████║██║██║  ██║██║   ██║   █████╔╝ ██║   ██║██╔██╗ ██║ ║\n"
TITLE+="║    ██╔══██╗██╔══██║██║██║  ██║██║   ██║   ██╔═██╗ ██║   ██║██║╚██╗██║ ║\n"
TITLE+="║    ██║  ██║██║  ██║██║██████╔╝╚██████╔╝██╗██║  ██╗╚██████╔╝██║ ╚████║ ║\n"
TITLE+="║    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ║\n"
TITLE+="║                                                              ║\n"
TITLE+="║              ★  RAIRU-KUN2 PREMIUM VPS  ★                  ║\n"
TITLE+="╠═══════════════════════════════════════════════════════════════╣\n"
TITLE+="║  OS    │ Ubuntu 20.04 LTS                                     ║\n"

RAM=$(free -m | awk '/Mem:/{printf "%sMB/%sMB (%d%%)", $3, $2, $3*100/$2}' 2>/dev/null || echo "N/A")
DISK=$(df -h / | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}' 2>/dev/null || echo "N/A")
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")

TITLE+="║  RAM   │ ${RAM}                ║\n"
TITLE+="║  Disk  │ ${DISK}               ║\n"
TITLE+="║  Uptime│ ${UPTIME}                    ║\n"

# Check zrok tunnels (multi-port)
TLIST="22:SSH 80:WEB 443:HTTPS 3000:APP3K ${PORT:-8080}:APP 8888:APP8K"
for entry in $TLIST; do
    IFS=':' read -r p l <<< "$entry"
    ZPID="/tmp/zrok-${p}.pid"
    if test -f "$ZPID" && kill -0 "$(cat "$ZPID" 2>/dev/null)" 2>/dev/null; then
        ZURL=$(grep -oP 'https?://[a-z0-9.-]+\.zrok\.io' /tmp/zrok-${p}.log 2>/dev/null | head -1)
        ZTEXT="${ZURL:-● Running}"
    else
        ZTEXT="○ Stopped"
    fi
    TITLE+="║  ${l}  │ ${ZTEXT}   ║\n"
done

TITLE+="╚═══════════════════════════════════════════════════════════════╝\n"
TITLE+="              powered by: DevCulture ©2026 linux\n"

echo -e "$TITLE"

echo ""
echo -e "  📊 \e[36mSystem Info\e[0m"
echo -e "  ─────────────────────────────────────────────"
echo -e "  \e[33mOS\e[0m        Ubuntu 20.04 LTS"
echo -e "  \e[33mRAM\e[0m       ${RAM}"
echo -e "  \e[33mDisk\e[0m      ${DISK}"
echo -e "  \e[33mUptime\e[0m    ${UPTIME}"
echo ""
