#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify it.
# https://github.com/Lovinoes/autoinstallers/tree/main/minecraft
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -eq 0 ]]; then IS_ROOT=true; else IS_ROOT=false; fi

print_banner() {
    echo -e "Minecraft Installer Menu"
    echo ""
    echo -e "${GRAY}Copyright (c) 2026 Lovinoes"
    echo "This program is free software: you can redistribute it and/or modify it."
    echo "Github: https://github.com/Lovinoes/autoinstallers/tree/main/minecraft"
    echo -e "${NC}"
}

run_setup() {
    clear
    print_banner

    echo -e "${BLUE}Select an option:${NC}"
    echo ""
    echo "Do you really want to install the Minecraft Server?"
    echo -e "${GRAY}This will automatically install the Docker Engine."
    echo -e "The Docker Compose stack will live under /opt/minecraft.${NC}"
    echo ""

    read -p "Continue? [Y/n] " confirm

    case "$confirm" in
        [Yy]|"")
            echo ""
            echo -e "${CYAN}Starting Minecraft installation...${NC}"
            curl -fsSL "https://raw.githubusercontent.com/Lovinoes/autoinstallers/main/minecraft/scripts/setup.sh" | sudo bash
            return 0
            ;;
        [Nn]|[Qq])
            echo -e "${RED}Installation cancelled.${NC}"
            sleep 1
            return 1
            ;;
        *)
            echo -e "${RED}Invalid option. Aborted.${NC}"
            sleep 1
            return 1
            ;;
    esac
}

info() {
    clear -x
    print_banner

    echo -e "${BLUE}Information about this script${NC}"
    echo ""
    echo "This installer sets up a Minecraft server using Docker."
    echo ""
    echo -e "${CYAN}Includes:${NC}"
    echo "  - Docker setup (if missing)"
    echo "  - Docker Compose stack"
    echo "  - (Optional) RCON server"
    echo ""
    echo -e "${CYAN}Server directory:${NC}"
    echo "  /opt/minecraft"
    echo ""
    echo -e "${CYAN}Start server:${NC}"
    echo "  cd /opt/minecraft"
    echo "  docker compose up -d"
    echo ""
    echo -e "${CYAN}Stop server:${NC}"
    echo "  docker compose down"
    echo ""
    echo -e "${CYAN}Attach live console:${NC}"
    echo "  docker attach minecraft"
    echo ""
    echo -e "${CYAN}Detach live console safely:${NC}"
    echo "  Press Ctrl+P then Ctrl+Q"
    echo ""
    echo -e "${CYAN}Configuration:${NC}"
    echo "  https://docker-minecraft-server.readthedocs.io/en/latest"
    echo -e "  ${GRAY}Compose dir: /opt/minecraft/${NC}"
    echo ""
    echo -e "${GRAY}Press ENTER to return...${NC}"
    read
}

system_info() {
    clear -x

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$PRETTY_NAME
    else
        OS_NAME="Unknown Linux"
    fi

    print_banner

    echo -e "${BLUE}System Information${NC}"
    echo ""
    echo "OS:           $OS_NAME"
    echo "Hostname:     $(hostname)"
    echo "Kernel:       $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime:       $(uptime -p 2>/dev/null || uptime)"
    echo ""

    # Parse lscpu and free once
    LSCPU=$(lscpu 2>/dev/null)
    MEMINFO=$(free -h 2>/dev/null)

    echo "CPU:"
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|i*86)
            MODEL=$(echo "$LSCPU" | awk -F: '/Model name/ {gsub(/^[ \t]+/,"",$2); print $2; exit}')
            CORES=$(echo "$LSCPU" | awk -F: '
                /Core\(s\) per socket/ {gsub(/ /,"",$2); c=$2}
                /Socket\(s\)/          {gsub(/ /,"",$2); s=$2}
                END {print c*s}
            ')
            THREADS=$(echo "$LSCPU" | awk -F: '
                /Thread\(s\) per core/ {gsub(/ /,"",$2); t=$2}
                /Core\(s\) per socket/ {gsub(/ /,"",$2); c=$2}
                /Socket\(s\)/          {gsub(/ /,"",$2); s=$2}
                END {print t*c*s}
            ')
            ;;
        aarch64|armv*|arm64)
            MODEL=$(echo "$LSCPU" | awk -F: '/Model name/ {gsub(/^[ \t]+/,"",$2); print $2; exit}')
            if [ -z "$MODEL" ]; then
                MODEL=$(awk -F: '/^Model\s*:/ {gsub(/^[ \t]+/,"",$2); print $2; exit}' /proc/cpuinfo)
            fi
            CORES=$(echo "$LSCPU" | awk -F: '
                /Core\(s\) per cluster/ {gsub(/ /,"",$2); c=$2}
                /Cluster\(s\)/          {gsub(/ /,"",$2); s=$2}
                END {print c*s}
            ')
            THREADS=$(echo "$LSCPU" | awk -F: '/^CPU\(s\):/ {gsub(/ /,"",$2); print $2; exit}')
            ;;
        *)
            MODEL=$(echo "$LSCPU" | awk -F: '/Model name/ {gsub(/^[ \t]+/,"",$2); print $2; exit}')
            CORES=$(nproc --all)
            THREADS=$(nproc --all)
            ;;
    esac

    MODEL=${MODEL:-"Unknown"}
    CORES=${CORES:-$(nproc --all)}
    THREADS=${THREADS:-$(nproc --all)}

    echo "  Model:   $MODEL"
    echo "  Cores:   $CORES"
    echo "  Threads: $THREADS"
    echo ""

    echo "Memory:"
    echo "  Total:  $(echo "$MEMINFO" | awk '/Mem:/ {print $2}')"
    echo "  Used:   $(echo "$MEMINFO" | awk '/Mem:/ {print $3}')"
    echo "  Free:   $(echo "$MEMINFO" | awk '/Mem:/ {print $4}')"
    echo "  Cached: $(echo "$MEMINFO" | awk '/Mem:/ {print $6}')"
    echo ""

    echo "Disks:"
    df -h --output=source,size,used,avail,pcent,target | \
        awk 'NR==1 {print $0; next} /^\/dev/ {print $0}' | \
        column -t
    echo ""

    echo -e "${GRAY}Press ENTER to return...${NC}"
    read
}

check_root() {
    if ! $IS_ROOT; then
        echo -e "${RED}ERROR: You must run this as root (sudo).${NC}"
        echo -e "${GRAY}Press ENTER to return...${NC}"
        read
        return 1
    fi
    return 0
}

# Main loop
while true; do
    clear -x
    print_banner
    echo -e "${BLUE}Select an option:${NC}"
    echo ""

    if $IS_ROOT; then
        echo "[1] Install Minecraft Server"
    else
        echo -e "${RED}[1] Install Minecraft Server (requires root/sudo)${NC}"
    fi

    echo "[2] Information about this script"
    echo "[3] View system information"
    echo -e "${GRAY}[4] Exit${NC}"
    echo ""

    read -p "Option: " choice

    case "$choice" in
        1)
            if check_root; then
                if run_setup; then
                    echo ""
                    echo -e "${GREEN}Installation finished.${NC}"
                    echo -e "${GRAY}Press ENTER to return...${NC}"
                    read
                fi
            fi
            ;;
        2)
            info
            ;;
        3)
            system_info
            ;;
        4|[Qq])
            clear -x
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            sleep 1
            ;;
    esac
done