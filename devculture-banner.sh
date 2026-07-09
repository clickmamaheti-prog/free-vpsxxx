#!/bin/bash
# DevCulture Pro — Premium SSH VPS Banner

# ─── ANSI Colors ───
CY='\e[0;36m'      # Cyan
BCY='\e[1;36m'     # Bold Cyan
WH='\e[1;37m'      # Bold White
GR='\e[0;32m'      # Green
YL='\e[1;33m'      # Yellow
DM='\e[2;36m'      # Dim Cyan
RS='\e[0m'         # Reset

# ─── System Info ───
RAM=$(free -m | awk '/Mem:/{printf "%sMB / %sMB  (%d%%)", $3, $2, $3*100/$2}' 2>/dev/null || echo "N/A")
DISK=$(df -h / | awk 'NR==2{printf "%s / %s  (%s)", $3, $2, $5}' 2>/dev/null || echo "N/A")
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")
LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs 2>/dev/null || echo "N/A")
IP_PUB=$(curl -s --max-time 3 ifconfig.me 2>/dev/null || echo "N/A")

# ─── Bore Tunnel Info ───
BORE_SERVER="${BORE_SERVER:-bore.pub}"
SSH_ADDR="○ Offline"
APP_ADDR="○ Offline"
APP3K_ADDR="○ Offline"

for port in 22 "${PORT:-8080}" 3000; do
  pidf="/tmp/bore-${port}.pid"
  logf="/tmp/bore-${port}.log"
  if test -f "$pidf" && kill -0 "$(cat "$pidf" 2>/dev/null)" 2>/dev/null; then
    BADDR=$(grep -oP "${BORE_SERVER}:\K[0-9]+" "$logf" 2>/dev/null | head -1)
    BTEXT="${BCY}● ${BORE_SERVER}:${BADDR:-?}${RS}"
  else
    BTEXT="${DM}○ Offline${RS}"
  fi
  case "$port" in
    22) SSH_ADDR="$BTEXT" ;;
    "${PORT:-8080}") APP_ADDR="$BTEXT" ;;
    3000) APP3K_ADDR="$BTEXT" ;;
  esac
done

# ─── Banner ───────────────────────────────────────────
echo -e ""
echo -e "${BCY}  ╔══════════════════════════════════════════════════════╗${RS}"
echo -e "${BCY}  ║${RS}  ${DM}┌──────────────────────────────────────────────────┐${RS}  ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}  ${DM}│${RS}                                                  ${DM}│${RS}  ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}  ${DM}│${RS}   ${BCY}██████╗ ███████╗██╗   ██╗ ██████╗              ${DM}│${RS}  ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}  ${DM}│${RS}   ${BCY}██╔══██╗██╔════╝██║   ██║██╔════╝              ${DM}│${RS}  ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}  ${DM}│${RS}   ${BCY}██║  ██║█████╗  ██║   ██║██║                   ${DM}│${RS}  ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}  ${DM}│${RS}   ${BCY}██║  ██║██╔══╝  ╚██╗ ██╔╝██║                   ${DM}│${RS}  ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}  ${DM}│${RS}   ${BCY}██████╔╝███████╗ ╚████╔╝ ╚██████╗   ${WH}PRO ✦${RS}       ${DM}│${RS}  ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}  ${DM}│${RS}   ${BCY}╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝              ${DM}│${RS}  ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}  ${DM}│${RS}          ${CY}C U L T U R E  —  P R E M I U M  V P S${RS}   ${DM}│${RS}  ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}  ${DM}└──────────────────────────────────────────────────┘${RS}  ${BCY}║${RS}"
echo -e "${BCY}  ╠══════════════════════════════════════════════════════╣${RS}"
echo -e "${BCY}  ║${RS}                                                      ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}   ${YL}◈  SYSTEM${RS}                                          ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}   ${DM}├─${RS} ${CY}OS    ${RS}: ${WH}Ubuntu 20.04 LTS${RS}                          ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}   ${DM}├─${RS} ${CY}RAM   ${RS}: ${WH}${RAM}${RS}"
echo -e "${BCY}  ║${RS}   ${DM}├─${RS} ${CY}Disk  ${RS}: ${WH}${DISK}${RS}"
echo -e "${BCY}  ║${RS}   ${DM}├─${RS} ${CY}Uptime${RS}: ${WH}${UPTIME}${RS}"
echo -e "${BCY}  ║${RS}   ${DM}└─${RS} ${CY}Load  ${RS}: ${WH}${LOAD}${RS}"
echo -e "${BCY}  ║${RS}                                                      ${BCY}║${RS}"
echo -e "${BCY}  ╠══════════════════════════════════════════════════════╣${RS}"
echo -e "${BCY}  ║${RS}                                                      ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}   ${YL}◈  BORE TUNNELS${RS}                                    ${BCY}║${RS}"
echo -e "${BCY}  ║${RS}   ${DM}├─${RS} ${CY}SSH  :22  ${RS}→  ${SSH_ADDR}"
echo -e "${BCY}  ║${RS}   ${DM}├─${RS} ${CY}APP  :${PORT:-8080}  ${RS}→  ${APP_ADDR}"
echo -e "${BCY}  ║${RS}   ${DM}└─${RS} ${CY}APP3K:3000${RS}→  ${APP3K_ADDR}"
echo -e "${BCY}  ║${RS}                                                      ${BCY}║${RS}"
echo -e "${BCY}  ╠══════════════════════════════════════════════════════╣${RS}"
echo -e "${BCY}  ║${RS}  ${DM}powered by ${BCY}DevCulture${RS} ${DM}©2026${RS}  ${CY}bore.pub tunnel${RS}          ${BCY}║${RS}"
echo -e "${BCY}  ╚══════════════════════════════════════════════════════╝${RS}"
echo -e ""
