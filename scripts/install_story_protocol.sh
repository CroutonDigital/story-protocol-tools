#!/bin/bash
GO_VERSION='1.21.3'
GETH_VERSION='v0.9.4'
STORY_VERSION='v0.11.0'
GO_BIN="$HOME/go/bin"


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
    eval "$command" > /dev/null 2>&1
    local status=$?

    if [ $status -eq 0 ]; then
        clear_line
        echo -e "${GREEN}$action completed successfully!${NC}"
    else
        clear_line
        echo -e "${RED}$action failed.${NC}"
        exit 1
    fi
}


setup_go_env() {
    echo 'export PATH=/usr/local/go/bin:$HOME/go/bin:$HOME/.story/geth/bin:$HOME/.story/story/bin:$PATH' >> $HOME/.bash_profile
    echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
    source $HOME/.bash_profile
}

verify_go_installation() {
    if ! command -v go &> /dev/null; then
        echo -e "${RED}Go is not installed or not in PATH. Attempting to fix...${NC}"
        setup_go_env
        source $HOME/.bash_profile
        if ! command -v go &> /dev/null; then
            echo -e "${RED}Failed to set up Go. Please install Go manually.${NC}"
            return 1
        fi
    fi
    echo -e "${GREEN}Go is installed.${NC}"
}


display_summary() {
    echo -e "\n${GREEN}--- Installation Summary ---${NC}"
    echo -e "${YELLOW}Geth Version:${NC} ${GREEN}${GETH_VERSION}${NC}"
    echo -e "${YELLOW}Story Version:${NC} ${GREEN}${STORY_VERSION}${NC}"
    echo -e "${GREEN}All components have been installed and configured successfully!${NC}"
   
}


main() {
    echo -e "${YELLOW}--- Story Protocol Installation ---${NC}"


    display_progress "Updating system" "sudo apt-get update -y && sudo apt-get upgrade -y"
    display_progress "Installing necessary packages" "sudo apt-get install -y curl git make build-essential jq wget lz4 aria2"


    display_progress "Installing Go" "
        wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz &&
        sudo rm -rf /usr/local/go &&
        sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz &&
        rm go${GO_VERSION}.linux-amd64.tar.gz
    "
    

    setup_go_env
    verify_go_installation || exit 1


    # Остановка служб перед установкой новых бинарников
    display_progress "Stopping Story and Geth services" "
        sudo systemctl stop story-geth 2>/dev/null || true &&
        sudo systemctl stop story 2>/dev/null || true
    "

    display_progress "Installing Geth" "
        if [ ! -d "$HOME/story-geth" ]; then
            git clone https://github.com/piplabs/story-geth.git $HOME/story-geth
        else
            cd $HOME/story-geth && git fetch --all && git reset --hard origin/main
        fi &&
        cd $HOME/story-geth &&
        git fetch --tags &&
        git checkout refs/tags/$GETH_VERSION &&
        make geth &&
        mkdir -p $HOME/.story/geth/bin &&
        cp ./build/bin/geth $HOME/.story/geth/bin/
    "


    display_progress "Installing Story" "
        if [ ! -d "$HOME/story" ]; then
            git clone https://github.com/piplabs/story.git $HOME/story
        else
            cd $HOME/story && git fetch --all && git reset --hard origin/main
        fi &&
        cd $HOME/story &&
        git fetch --tags &&
        git checkout refs/tags/$STORY_VERSION &&
        go build -o story ./client &&
        mkdir -p $HOME/.story/story/bin &&
        cp ./story $HOME/.story/story/bin/
    "


    display_progress "Setting up Geth service" "
        sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
        [Unit]
        Description=ETH Node
        After=network.target

        [Service]
        User=$USER
        Type=simple
        WorkingDirectory=$HOME/.story/geth
        ExecStart=$HOME/.story/geth/bin/geth --iliad --syncmode full
        Restart=on-failure
        LimitNOFILE=65535

        [Install]
        WantedBy=multi-user.target
EOF
    "


    echo -e "${YELLOW}**Please enter a moniker for your Story node:**${NC}"
    read -r MONIKER
    display_progress "Initializing Story node" "
        $HOME/.story/story/bin/story init --network iliad --moniker \"$MONIKER\"
    "
    display_progress "Downloading addrbook" "
        wget -O $HOME/.story/story/config/addrbook.json https://storage.crouton.digital/testnet/story/files/addrbook.json
    "

    display_progress "Setting up Story node service" "
        sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
        [Unit]
        Description=Story Protocol Node
        After=network.target

        [Service]
        User=$USER
        WorkingDirectory=$HOME/.story/story
        Type=simple
        ExecStart=$HOME/.story/story/bin/story run
        Restart=on-failure
        LimitNOFILE=65535

        [Install]
        WantedBy=multi-user.target
EOF
    "


    # Перезагрузка и включение сервисов story-geth и story
    display_progress "Reloading and enabling services" "
        sudo systemctl daemon-reload &&
        sudo systemctl enable story-geth story
    "


    display_summary
}


main
