#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to display the menu
show_menu() {
    clear
    echo -e "${YELLOW}=== Story Protocol Tools ===${NC}"
    echo "1) Install Story Protocol"
    echo "2) Update Story Protocol"
    echo "3) Check Node Status"
    echo "4) View Logs"
    echo "5) Exit"
}

# Function to execute a script
execute_script() {
    local script_url=$1
    local temp_script=$(mktemp)
    if wget -q -O "$temp_script" "$script_url"; then
        chmod +x "$temp_script"
        bash "$temp_script"
        rm "$temp_script"
    else
        echo -e "${RED}Failed to download the script.${NC}"
    fi
    read -p "Press enter to continue"
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice: " choice
    case $choice in
        1)
            echo -e "${GREEN}Installing Story Protocol...${NC}"
            execute_script "https://raw.githubusercontent.com/CroutonDigital/story-protocol-tools/refs/heads/main/scripts/install_story_protocol.sh"
            ;;
        2)
            echo -e "${GREEN}Updating Story Protocol...${NC}"
            execute_script "https://raw.githubusercontent.com/CroutonDigital/story-protocol-tools/refs/heads/main/scripts/update_story_protocol.sh"
            ;;
        3)
            echo -e "${GREEN}Checking Node Status...${NC}"
            execute_script "https://raw.githubusercontent.com/CroutonDigital/story-protocol-tools/refs/heads/main/scripts/check_node_status.sh"
            ;;
        4)
            echo -e "${GREEN}Viewing Logs...${NC}"
            execute_script "https://raw.githubusercontent.com/CroutonDigital/story-protocol-tools/refs/heads/main/scripts/view_logs.sh"
            ;;
        5)
            echo -e "${YELLOW}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            read -p "Press enter to continue"
            ;;
    esac
done
