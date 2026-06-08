#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify it.
# https://github.com/Lovinoes/autoinstallers/tree/main/minecraft
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Must run as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR: Run as root or sudo.${NC}"
    exit 1
fi

echo -e "${CYAN}Minecraft Setup Starting...${NC}"
echo ""
sleep 1

# Install Docker if not present
if command -v docker &> /dev/null; then
    echo -e "${GREEN}Docker already installed. Skipping installation.${NC}"
    sleep 1
else
    echo -e "${CYAN}Docker is required for this setup. Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    CHANNEL=stable bash /tmp/get-docker.sh
    rm -f /tmp/get-docker.sh
    echo ""
    echo -e "${GREEN}Docker installation completed.${NC}"
    sleep 1
fi

echo ""
echo -e "${CYAN}Setting up /opt/minecraft ...${NC}"
sleep 1

mkdir -p /opt/minecraft

# Fix ownership so the invoking user can manage the files
if [[ -n "$SUDO_USER" ]]; then
    chown "$SUDO_USER":"$SUDO_USER" /opt/minecraft
fi

# Write the Docker Compose stack
cat > /opt/minecraft/docker-compose.yml <<'EOF'
# For more Configuration Options:
# https://docker-minecraft-server.readthedocs.io/en/latest/
# For custom JVM flags:
# https://docker-minecraft-server.readthedocs.io/en/latest/configuration/jvm-options/
# For more Project Types:
# https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/
# Versioning:
# https://docker-minecraft-server.readthedocs.io/en/latest/versions/minecraft/

services:
  minecraft:
    image: itzg/minecraft-server
    container_name: minecraft
    restart: unless-stopped
    tty: true
    stdin_open: true
    ports:
      - "25565:25565"
      # Uncomment the line below and set a strong password before exposing RCON to the internet.
      # In most cases, exposing RCON publicly is NOT recommended!
      # - "25575:25575"
    environment:
      EULA: "FALSE"              # Set to "TRUE" to accept the Minecraft EULA
      TYPE: "PAPER"              # Project type (defaults to PaperMC)
      VERSION: "LATEST"          # Minecraft version (e.g. "1.12.2"). "latest" uses the newest available version for the selected project type.
      # JVM configuration
      USE_AIKAR_FLAGS: "true"    # Aikar flags for improved performance
      USE_SIMD_FLAGS: "true"     # Disable if SIMD causes issues
      MEMORY: "2G"               # Amount of RAM allocated to the server
      # RCON access
      ENABLE_RCON: "true"        # Set to "false" if you don't need RCON
      RCON_PASSWORD: "minecraft" # CHANGE THIS BEFORE EXPOSING RCON TO THE INTERNET!

    volumes:
      - '/etc/localtime:/etc/localtime:ro'
      - './data:/data'
EOF

# Fix ownership of the compose file too
if [[ -n "$SUDO_USER" ]]; then
    chown "$SUDO_USER":"$SUDO_USER" /opt/minecraft/docker-compose.yml
fi

echo ""
echo -e "${GREEN}Setup complete.${NC}"
echo ""
echo -e "${CYAN}Quick reference:${NC}"
echo ""
echo "  Server directory:  /opt/minecraft"
echo ""
echo "  Start server:"
echo "    cd /opt/minecraft"
echo "    docker compose up -d"
echo ""
echo "  Stop server:"
echo "    docker compose down"
echo ""
echo "  Console (recommended):"
echo "    docker exec -it minecraft rcon-cli"
echo ""
echo "  Attach live console:"
echo "    docker attach minecraft"
echo ""
echo "  Detach safely (live console):"
echo "    Ctrl+P then Ctrl+Q"
echo ""
echo "  Full configuration docs:"
echo "    https://docker-minecraft-server.readthedocs.io/en/latest"
echo -e "    ${GRAY}Compose dir: /opt/minecraft/${NC}"
echo ""
echo -e "${RED}REMINDER: Change the RCON_PASSWORD in /opt/minecraft/docker-compose.yml!${NC}"
echo ""
echo -e "${GREEN}All set.${NC}"
