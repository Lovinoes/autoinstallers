#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify it.
# https://github.com/Lovinoes/autoinstallers/tree/main/minecraft
#
# our super cool setup script that does the heavy lifting

# cool colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# check if we are root, if not, we ball out
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR: Run as root or sudo.${NC}"
    exit 1
fi

echo -e "${CYAN}Minecraft Setup Starting...${NC}"
echo ""
sleep 1

# check if docker is already there so we don't waste time
if command -v docker &> /dev/null; then
    echo -e "${GREEN}Docker already installed. Skipping installation.${NC}"
    sleep 1
else
    echo -e "${CYAN}Docker is required for this setup. Installing Docker...${NC}"

    # get the official docker install script and run it
    curl -fsSL https://get.docker.com/ -o /tmp/get-docker.sh
    CHANNEL=stable bash /tmp/get-docker.sh

    echo ""
    echo -e "${GREEN}Docker installation completed.${NC}"
    sleep 1
fi

echo ""
echo -e "${CYAN}Setting up /opt/minecraft ...${NC}"
sleep 1
# make the directory where our server will live
mkdir -p /opt/minecraft

# fix permissions so the regular user can touch the files too
if [[ -n "$SUDO_USER" ]]; then
    chown "$SUDO_USER":"$SUDO_USER" /opt/minecraft
fi

# create cool docker compose stack in /opt/minecraft
cat > /opt/minecraft/docker-compose.yml <<'EOF'
# For more Configuration Options:
# https://docker-minecraft-server.readthedocs.io/en/latest/
# For custom JVM flags:
# https://docker-minecraft-server.readthedocs.io/en/latest/configuration/jvm-options/#extra-jvm-options
# For more Project Types
# https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/

services:
  minecraft:
    image: itzg/minecraft-server
    container_name: minecraft
    restart: unless-stopped
    tty: true
    stdin_open: true
    ports:
      - "25565:25565"
    environment:
      EULA: "TRUE"
      # Project (defaults to PaperMC)
      TYPE: "PAPER"
      # Some custom JVM Flags below for better performance
      USE_AIKAR_FLAGS: "true"
      USE_SIMD_FLAGS: "true" # Disable if your CPU doesn't support SIMD or it causes issues.
      MEMORY: "4G" # Set the amount of memory you want to allocate. 
      # RCON Access
      ENABLE_RCON: "true"
      RCON_PASSWORD: "minecraft" # you should definitely change this!

    volumes:
      - '/etc/localtime:/etc/localtime:ro'
      - './data:/data'
EOF

# make sure the compose file also has the right owner
if [[ -n "$SUDO_USER" ]]; then
    chown "$SUDO_USER":"$SUDO_USER" /opt/minecraft/docker-compose.yml
fi

echo ""
echo -e "${GREEN}Setup complete.${NC}"
echo ""

# show some useful info for the user after the setup
echo "Server directory:"
echo "  /opt/minecraft"
echo ""
echo "Start server:"
echo "  cd /opt/minecraft"
echo "  docker compose up -d"
echo ""
echo "Stop server:"
echo "  docker compose down"
echo ""
echo -e "${CYAN}Console Access${NC}"
echo "Recommended:"
echo "  docker exec -it minecraft rcon-cli"
echo ""
echo "Attach live console:"
echo "  docker attach minecraft"
echo ""
echo "Detach safely: (when using live console)"
echo "  Ctrl + P then Ctrl + Q"
echo ""
echo -e "${CYAN}Configuration${NC}"
echo "  For Configuration, take a look at:"
echo "  https://docker-minecraft-server.readthedocs.io/en/latest"
echo -e "  ${GRAY}Compose Dir: /opt/minecraft/${NC}"
echo ""
echo -e "${GREEN}All set.${NC}"
# end