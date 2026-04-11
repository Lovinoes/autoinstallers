#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify it.
# https://github.com/Lovinoes/autoinstallers/tree/main/minecraft
#
# cool colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# check if we are running the script as root
if [[ $EUID -eq 0 ]]; then IS_ROOT=true; else IS_ROOT=false; fi

# super cool banner
print_banner() {
    echo "Minecraft Installer Menu"
    echo ""
    echo -e "${GRAY}Copyright (c) 2026 Lovinoes"
    echo "This program is free software: you can redistribute it and/or modify it."
    echo "Github: https://github.com/Lovinoes/autoinstallers/tree/main/minecraft"
    echo -e "${NC}"
}

# some menu functions
# cool menu that opens if we choose option 1
run_setup() {
    clear
    print_banner
    
    echo -e "${BLUE}Select an option:${NC}"
    echo ""
    echo "[1] Install Minecraft Server"
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
            # download and fetch our setup script from github - this URL will never change!
            curl -fsSL "https://raw.githubusercontent.com/Lovinoes/autoinstallers/main/minecraft/scripts/setup.sh" | sudo bash
            return 0
            ;;
        # cancel the installation if user chooses N/n or Q/q
        [Nn]|[Qq])
            echo -e "${RED}Installation cancelled.${NC}"
            sleep 1
            return 1
            ;;
        # cancels the installation if user inputs anything else than Y/y, N/n or Q/q
        *)
            echo -e "${RED}Invalid option. Aborted.${NC}"
            sleep 1
            return 1
            ;;
    esac
}

# super duper cool info screen that lists some useful stuff the user might need
info() {
    clear -x
    print_banner

    echo -e "${BLUE}Information about this script${NC}"
    echo ""
    echo "This installer sets up a Minecraft server using Docker."
    echo ""
    echo -e "${CYAN}Includes:${NC}"
    echo "- Docker setup (if missing)"
    echo "- Docker Compose stack"
    echo "- RCON enabled server"
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
    echo -e "${CYAN}Console Access${NC}"
    echo "Recommended:"
    echo "  docker exec -it minecraft rcon-cli"
    echo ""
    echo -e "${CYAN}Attach live console:${NC}"
    echo "  docker attach minecraft"
    echo ""
    echo -e "${CYAN}Detach safely: (when using live console)${NC}"
    echo "  Ctrl + P then Ctrl + Q"
    echo ""
    echo -e "${CYAN}Configuration${NC}"
    echo "  For Configuration, take a look at:"
    echo "  https://docker-minecraft-server.readthedocs.io/en/latest"
    echo -e "  ${GRAY}Compose Dir: /opt/minecraft/${NC}"
    echo ""
    echo -e "${GRAY}Press ENTER to return...${NC}"
    read
}

# another super duper cool info screen that shows some information about our system!
system_info() {
    clear -x

    # check what linux distro we are running
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$PRETTY_NAME
    else
        OS_NAME="Unknown Linux"
    fi

    print_banner

    echo -e "${BLUE}System Information${NC}"
    echo ""
    echo "OS: $OS_NAME"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo ""
    # show cpu stuff
    echo "CPU:"
    # our cpu logic
    MODEL=$(lscpu | awk -F: '/Model name/ {gsub(/^ +/,"",$2); print $2; exit}')
    CORES=$(lscpu | awk -F: '
        /Core\(s\) per socket/ {gsub(/ /,"",$2); c=$2}
        /Socket\(s\)/ {gsub(/ /,"",$2); s=$2}
        END {print c*s}
    ')
    THREADS=$(lscpu | awk -F: '
        /Thread\(s\) per core/ {gsub(/ /,"",$2); t=$2}
        /Core\(s\) per socket/ {gsub(/ /,"",$2); c=$2}
        /Socket\(s\)/ {gsub(/ /,"",$2); s=$2}
        END {print t*c*s}
    ')
    CORES=${CORES:-$(nproc --all)}
    THREADS=${THREADS:-$(nproc --all)}
    echo "  Model: $MODEL"
    echo "  Cores: $CORES"
    echo "  Threads: $THREADS"
    echo ""
    # show memory stuff
    echo "Memory:"
    TOTAL_MEM=$(free -h | awk '/Mem:/ {print $2}')
    USED_MEM=$(free -h | awk '/Mem:/ {print $3}')
    FREE_MEM=$(free -h | awk '/Mem:/ {print $4}')
    CACHED_MEM=$(free -h | awk '/Mem:/ {print $6}')
    echo "  Total:  $TOTAL_MEM"
    echo "  Used:   $USED_MEM"
    echo "  Free:   $FREE_MEM"
    echo "  Cached: $CACHED_MEM"
    echo ""
    # show disk and partition stuff
    echo "Disks:"
    df -h --output=source,size,used,avail,pcent,target | awk 'NR==1 {print $0; next} /^\/dev/ {print $0}'
    echo ""
    echo -e "${GRAY}Press ENTER to return...${NC}"
    read
}

# simple root check so the script doesn't explode
check_root() {
    if ! $IS_ROOT; then
        echo -e "${RED}ERROR: You must run this as root (sudo).${NC}"
        echo -e "${GRAY}Press ENTER to return...${NC}"
        read
        return 1
    fi
    return 0
}

# our main loop function
# this keeps the menu running until we actually want to exit
while true; do
    clear -x
    print_banner
    echo -e "${BLUE}Select an option:${NC}"
    echo ""

    # only show the install option as white if we are root
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

    # handle the user input for the main menu
    case "$choice" in
        1)
            if check_root; then
                if run_setup; then
                    echo ""
                    echo "Press ENTER to return..."
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
        # exit the script if User chooses 4 or Q/q
        4|[Qq])
            clear -x
            exit 0
            ;;
        # show error if User inputs something that isn't on the list
        *)
            echo -e "${RED}Invalid option. Aborted.${NC}"
            sleep 1
            ;;
    esac
done
# end