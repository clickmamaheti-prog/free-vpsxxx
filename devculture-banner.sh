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

# Check zrok tunnels
for port in 22 80 8080; do
    ZPID="/tmp/zrok-${port}.pid"
    if test -f "$ZPID" && kill -0 "$(cat "$ZPID" 2>/dev/null)" 2>/dev/null; then
        ZURL=$(grep -oP 'https?://[a-z0-9.-]+\.zrok\.io' /tmp/zrok-${port}.log 2>/dev/null | head -1)
        ZTEXT="${ZURL:-● Running}"
    else
        ZTEXT="○ Stopped"
    fi
    case $port in
        22) TITLE+="║  SSH  │ ${ZTEXT}   ║\n" ;;
        80) TITLE+="║  Web  │ ${ZTEXT}   ║\n" ;;
        8080) TITLE+="║  App  │ ${ZTEXT}   ║\n" ;;
    esac
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
