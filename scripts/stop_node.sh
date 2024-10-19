#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' 

echo -e "${YELLOW}Stopping Story Protocol Node...${NC}"

# Stop Story service
if sudo systemctl stop story; then
    echo -e "${GREEN}Story service stopped successfully.${NC}"
else
    echo -e "${RED}Failed to stop Story service.${NC}"
fi

# Stop Geth service
if sudo systemctl stop story-geth; then
    echo -e "${GREEN}Geth service stopped successfully.${NC}"
else
    echo -e "${RED}Failed to stop Geth service.${NC}"
fi

echo -e "${GREEN}Story Protocol Node has been stopped.${NC}"
