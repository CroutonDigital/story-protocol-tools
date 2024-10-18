
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' 

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    tput civis  
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    tput cnorm  
    printf "    \b\b\b\b"
}


clear_line() {
    printf "\r\033[K"  
}


display_progress() {
    local action="$1"
    local command="$2"


    echo -ne "${YELLOW}$action in progress...${NC}"
    eval "$command" > /dev/null 2>&1 &
    local pid=$!

    spinner $pid  
    wait $pid 

    if [ $? -eq 0 ]; then
        clear_line
        echo -e "${GREEN}$action completed successfully!${NC}"
    else
        clear_line
        echo -e "${RED}$action failed.${NC}"
        exit 1
    fi
}


display_progress "Installing required dependencies" "sudo apt-get install wget lz4 -y"


display_progress "Stopping Geth service if running" "sudo systemctl stop story-geth || true"
display_progress "Stopping Story service if running" "sudo systemctl stop story || true"

display_progress "Backing up validator state" "sudo cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup"

display_progress "Deleting previous geth chaindata" "sudo rm -rf $HOME/.story/geth/iliad/geth/chaindata"
display_progress "Deleting previous story data folders" "sudo rm -rf $HOME/.story/story/data"


echo -ne "${YELLOW}Downloading story-geth snapshot: [${NC}"
wget -q --show-progress -O geth_snapshot.lz4 https://snapshots2.mandragora.io/story/geth_snapshot.lz4 2>&1 | while read -r line; do
    progress=$(echo "$line" | grep -o '[0-9]*%' | tail -1)
    printf "\r${YELLOW}Downloading story-geth snapshot: [%s${NC}" "$progress"
done
echo -e "${YELLOW}] Completed!${NC}"

echo -ne "${YELLOW}Downloading story snapshot: [${NC}"
wget -q --show-progress -O story_snapshot.lz4 https://snapshots2.mandragora.io/story/story_snapshot.lz4 2>&1 | while read -r line; do
    progress=$(echo "$line" | grep -o '[0-9]*%' | tail -1)
    printf "\r${YELLOW}Downloading story snapshot: [%s${NC}" "$progress"
done
echo -e "${YELLOW}] Completed!${NC}"


display_progress "Decompressing story-geth snapshot" "lz4 -c -d geth_snapshot.lz4 | tar -xv -C $HOME/.story/geth/iliad/geth"
display_progress "Decompressing story snapshot" "lz4 -c -d story_snapshot.lz4 | tar -xv -C $HOME/.story/story"


display_progress "Deleting downloaded story-geth snapshot" "sudo rm -v geth_snapshot.lz4"
display_progress "Deleting downloaded story snapshot" "sudo rm -v story_snapshot.lz4"

display_progress "Restoring validator state" "sudo cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json"


display_progress "Reloading and enabling services" "sudo systemctl daemon-reload && sudo systemctl enable story-geth story"


display_progress "Starting Geth service" "sudo systemctl start story-geth"
display_progress "Starting Story service" "sudo systemctl start story"
