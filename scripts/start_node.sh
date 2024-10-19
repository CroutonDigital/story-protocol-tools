#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' 

echo -e "${YELLOW}Starting Story Protocol Node...${NC}"

# Start Geth service
if sudo systemctl restart story-geth; then
    echo -e "${GREEN}Geth service started successfully.${NC}"
else
    echo -e "${RED}Failed to start Geth service.${NC}"
    exit 1
fi

# Start Story service
if sudo systemctl restart story; then
    echo -e "${GREEN}Story service started successfully.${NC}"
else
    echo -e "${RED}Failed to start Story service.${NC}"
    exit 1
fi

echo -e "${GREEN}Story Protocol Node has been started.${NC}"
