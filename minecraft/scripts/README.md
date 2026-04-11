### installer.sh
Interactive installer menu for managing the setup process. This is the main entry point that provides a user-friendly interface to install the server, view script documentation and some realtime system hardware details.

### setup.sh
The script that handles the technical backend. It automatically detects and installs the Docker Engine (if missing), configures the necessary directory permissions and generates a Minecraft Docker Compose stack in `/opt/minecraft`
