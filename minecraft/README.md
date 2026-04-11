## Minecraft Server Autoinstaller
A lightweight shell-based installer that deploys a Minecraft Java Edition server using Docker and Docker Compose. It provides a fast, repeatable setup for running a PaperMC server with sane defaults, RCON access, and container-based deployment.

Unlike traditional manual setups, this tool removes the need to install Docker, configure directories, or create a compose file manually.

![Termius_wtjQ8ZFAOV](https://github.com/user-attachments/assets/29ff3047-a8bb-4a5c-b5dc-97b2cf000bb9)

## Prerequisites
- Linux system (tested on Debian 13 and Fedora 43)
- Root or sudo access
- At least 2 GB RAM (4 GB recommended)
- Internet connection

## What It Does
The installer automates the full setup process:

1. Checks for root/sudo privileges  
2. Detects and installs Docker if missing  
3. Creates a Minecraft server directory at `/opt/minecraft/`
4. Generates a preconfigured `docker-compose.yml`  
5. Sets up:
   - PaperMC server
   - Aikar + SIMD JVM optimizations
   - RCON console access
   - Persistent world storage via Docker volumes

### Under the Hood
This installer uses the official `itzg/minecraft-server` Docker image, which provides a flexible and well-maintained Minecraft server environment.

It runs PaperMC by default, with Aikar JVM flags enabled and SIMD optimizations turned on for improved performance on modern CPUs.

## Installation
Run the installer with:

```bash
curl -fsSL https://raw.githubusercontent.com/Lovinoes/autoinstallers/main/minecraft/scripts/installer.sh -o installer.sh
sudo bash installer.sh
```

After that, your server becomes reachable from the internet (or LAN, depending on setup), and players can join using: `your-server-ip:25565`

enjoy  ( ͡° ͜ʖ ͡°)
