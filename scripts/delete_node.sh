#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' 

echo -e "${YELLOW}Deleting Story Protocol Node...${NC}"

# Stop services
echo -e "${YELLOW}Stopping services...${NC}"
sudo systemctl stop story story-geth

# Disable services
echo -e "${YELLOW}Disabling services...${NC}"
sudo systemctl disable story story-geth

# Remove service files
echo -e "${YELLOW}Removing service files...${NC}"
sudo rm /etc/systemd/system/story.service
sudo rm /etc/systemd/system/story-geth.service

# Remove binaries and data
echo -e "${YELLOW}Removing binaries and data...${NC}"
sudo rm -rf $HOME/.story
sudo rm -rf $HOME/story
sudo rm -rf $HOME/story-geth

# Remove Go installation (optional, uncomment if you want to remove Go as well)
# echo -e "${YELLOW}Removing Go installation...${NC}"
# sudo rm -rf /usr/local/go

# Clean up .bash_profile
echo -e "${YELLOW}Cleaning up .bash_profile...${NC}"
sed -i '/export PATH=.*story.*/d' $HOME/.bash_profile
sed -i '/export GOPATH=.*/d' $HOME/.bash_profile

echo -e "${GREEN}Story Protocol Node has been deleted.${NC}"
echo -e "${YELLOW}Please note that Go installation was not removed. If you want to remove it, please do so manually.${NC}"
