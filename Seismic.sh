#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[1;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Display header
display_header() {
    clear
    echo -e "${CYAN}"
    echo -e "    ${RED}██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ██╗${NC}"
    echo -e "    ${GREEN}██║  ██║██╔══██╗██╔════╝██╔══██╗████╗  ██║${NC}"
    echo -e "    ${BLUE}███████║███████║███████╗███████║██╔██╗ ██║${NC}"
    echo -e "    ${YELLOW}██╔══██║██╔══██║╚════██║██╔══██║██║╚██╗██║${NC}"
    echo -e "    ${MAGENTA}██║  ██║██║  ██║███████║██║  ██║██║ ╚████║${NC}"
    echo -e "    ${CYAN}╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
    echo -e "${BLUE}=======================================================${NC}"
    echo -e "${GREEN}       ✨ Seismic Node Installation Script ✨${NC}"
    echo -e "${BLUE}=======================================================${NC}"
    echo -e "${CYAN} Telegram Channel: CryptoAirdropHindi @CryptoAirdropHindi ${NC}"  
    echo -e "${CYAN} Follow us on social media for updates and more ${NC}"
    echo -e " 📱 Telegram: https://t.me/CryptoAirdropHindi6 "
    echo -e " 🎥 YouTube: https://www.youtube.com/@CryptoAirdropHindi6 "
    echo -e " 💻 GitHub Repo: https://github.com/CryptoAirdropHindi/ "
}

# Check and install dependencies
install_dependencies() {
    echo -e "${CYAN}Checking system dependencies...${NC}"
    
    # Check and install Rust
    if ! command -v rustc &> /dev/null; then
        echo -e "${YELLOW}Installing Rust...${NC}"
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        echo -e "${GREEN}✓ Rust already installed${NC}"
    fi
    
    # Check and install jq
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}Installing jq...${NC}"
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y jq
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq
        else
            echo -e "${RED}✗ Unsupported OS. Please install jq manually.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ jq already installed${NC}"
    fi
    
    # Check and install unzip
    if ! command -v unzip &> /dev/null; then
        echo -e "${YELLOW}Installing unzip...${NC}"
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y unzip
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install unzip
        fi
    else
        echo -e "${GREEN}✓ unzip already installed${NC}"
    fi
}

# Install Seismic Foundry
install_seismic() {
    echo -e "${CYAN}Installing Seismic Foundry...${NC}"
    
    # Download and install
    curl -L -H "Accept: application/vnd.github.v3.raw" \
        "https://api.github.com/repos/SeismicSystems/seismic-foundry/contents/sfoundryup/install?ref=seismic" | bash
    
    # Update PATH
    export PATH="$HOME/.seismic/bin:$PATH"
    source ~/.bashrc 2>/dev/null || source ~/.zshrc 2>/dev/null
    
    # Run sfoundryup
    echo -e "${YELLOW}Setting up Seismic Foundry (this may take a while)...${NC}"
    sfoundryup
    
    echo -e "${GREEN}✓ Seismic Foundry installed successfully!${NC}"
}

# Deploy contract
deploy_contract() {
    echo -e "${CYAN}Starting contract deployment...${NC}"
    
    # Clone repo if not exists
    if [ ! -d "try-devnet" ]; then
        echo -e "${YELLOW}Cloning try-devnet repository...${NC}"
        git clone --recurse-submodules https://github.com/SeismicSystems/try-devnet.git
    else
        echo -e "${GREEN}✓ try-devnet repository already exists${NC}"
    fi
    
    # Deploy
    cd try-devnet/packages/contract/ || { echo -e "${RED}✗ Failed to enter contract directory${NC}"; return; }
    echo -e "${YELLOW}Deploying contract...${NC}"
    bash script/deploy.sh
    
    echo -e "${GREEN}✓ Contract deployed successfully!${NC}"
    cd ../../../
}

# Interact with contract
interact_contract() {
    echo -e "${CYAN}Preparing contract interaction...${NC}"
    
    if [ ! -d "try-devnet/packages/cli" ]; then
        echo -e "${RED}✗ Error: try-devnet not found. Deploy a contract first.${NC}"
        return
    fi
    
    cd try-devnet/packages/cli/ || { echo -e "${RED}✗ Failed to enter CLI directory${NC}"; return; }
    
    # Install Bun if needed
    if ! command -v bun &> /dev/null; then
        echo -e "${YELLOW}Installing Bun...${NC}"
        curl -fsSL https://bun.sh/install | bash
        export PATH="$HOME/.bun/bin:$PATH"
    else
        echo -e "${GREEN}✓ Bun already installed${NC}"
    fi
    
    # Install dependencies and run
    echo -e "${YELLOW}Installing dependencies...${NC}"
    bun install
    
    echo -e "${YELLOW}Executing transactions...${NC}"
    bash script/transact.sh
    
    echo -e "${GREEN}✓ Contract interaction complete!${NC}"
    cd ../../../
}

# Check logs
check_logs() {
    echo -e "${CYAN}Checking logs...${NC}"
    
    if [ -f "try-devnet/packages/contract/logs/deploy.log" ]; then
        echo -e "\n${YELLOW}=== Deployment Logs ===${NC}"
        tail -n 10 try-devnet/packages/contract/logs/deploy.log
    else
        echo -e "${RED}✗ No deployment logs found${NC}"
    fi
    
    if [ -f "try-devnet/packages/cli/logs/transactions.log" ]; then
        echo -e "\n${YELLOW}=== Transaction Logs ===${NC}"
        tail -n 10 try-devnet/packages/cli/logs/transactions.log
    else
        echo -e "${RED}✗ No transaction logs found${NC}"
    fi
}

# Show menu with box design
show_menu() {
    display_header
    echo -e "${CYAN}╔════════════════════════════════════════════╗"
    echo -e "║               M A I N   M E N U             ║"
    echo -e "╠════════════════════════════════════════════╣"
    echo -e "║${YELLOW} 1.${NC} Install Dependencies & Seismic Foundry ${CYAN}║"
    echo -e "║${YELLOW} 2.${NC} Deploy Contract                       ${CYAN}║"
    echo -e "║${YELLOW} 3.${NC} Interact with Contract                ${CYAN}║"
    echo -e "║${YELLOW} 4.${NC} Check Logs                            ${CYAN}║"
    echo -e "║${YELLOW} 5.${NC} Exit                                  ${CYAN}║"
    echo -e "╚════════════════════════════════════════════╝${NC}"
    echo -e ""
    echo -ne "${YELLOW}❯ Select an option [${GREEN}1-5${YELLOW}]: ${NC}"
}

# Main menu function
main_menu() {
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                install_dependencies
                install_seismic
                ;;
            2)
                deploy_contract
                ;;
            3)
                interact_contract
                ;;
            4)
                check_logs
                ;;
            5)
                echo -e "\n${GREEN}Exiting script. Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "\n${RED}✗ Invalid option. Please enter 1-5.${NC}"
                sleep 1
                ;;
        esac
        
        # Only pause if not exiting
        if [[ "$choice" != "5" ]]; then
            echo -e "\n${CYAN}Press Enter to return to menu...${NC}"
            read -r
        fi
    done
}

# Start script
main_menu
