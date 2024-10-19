#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' 

show_menu() {
    echo -e "${YELLOW}=== View Logs ===${NC}"
    echo "1) View Geth logs"
    echo "2) View Story logs"
    echo "3) Exit"
}

view_logs() {
    local service=$1
    if systemctl is-active --quiet $service; then
        journalctl -u $service -f
    else
        echo -e "${RED}${service} is not running.${NC}"
    fi
}

while true; do
    show_menu
    read -p "Enter your choice: " choice
    case $choice in
        1)
            echo -e "${GREEN}Viewing Geth logs...${NC}"
            view_logs story-geth
            ;;
        2)
            echo -e "${GREEN}Viewing Story logs...${NC}"
            view_logs story
            ;;
        3)
            echo -e "${YELLOW}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
done
