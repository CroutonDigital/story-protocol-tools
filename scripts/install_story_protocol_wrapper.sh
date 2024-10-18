#!/bin/bash

# Download the main installation script
TEMP_SCRIPT=$(mktemp)
wget -O "$TEMP_SCRIPT" https://raw.githubusercontent.com/CroutonDigital/story-protocol-tools/refs/heads/main/scripts/install_story_protocol.sh

# Make the script executable
chmod +x "$TEMP_SCRIPT"

# Execute the script
bash "$TEMP_SCRIPT"

# Clean up
rm "$TEMP_SCRIPT"
