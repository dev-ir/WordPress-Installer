#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m' # No Color


install_jq() {
    if ! command -v jq &> /dev/null; then
        # Check if the system is using apt package manager
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}jq is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}

necessary_package(){
    install_jq
}


menu(){
    
    clear
    
    version='1.0'
    
    # Get server IP
    SERVER_IP=$(hostname -I | awk '{print $1}')
    
    # Fetch server country using ip-api.com
    SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')
    
    # Fetch server isp using ip-api.com
    SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')
    
    echo "+------------------------------------------------------------------------------------------------+"
    echo "| __          __           _ _____                      _____           _        _ _             |"
    echo "| \ \        / /          | |  __ \                    |_   _|         | |      | | |            |"
    echo "|  \ \  /\  / /__  _ __ __| | |__) | __ ___  ___ ___     | |  _ __  ___| |_ __ _| | | ___ _ __   |"
    echo "|   \ \/  \/ / _ \|  __/ _  |  ___/  __/ _ \/ __/ __|    | | |  _ \/ __| __/ _  | | |/ _ \  __|  |"
    echo "|    \  /\  / (_) | | | (_| | |   | | |  __/\__ \__ \   _| |_| | | \__ \ || (_| | | |  __/ |     |"
    echo "|     \/  \/ \___/|_|  \__,_|_|   |_|  \___||___/___/  |_____|_| |_|___/\__\__,_|_|_|\___|_|     |"
    echo "+------------------------------------------------------------------------------------------------+"
    echo -e "|  TELEGRSM CHANNEL: ${YELLOW}@DVHOST_CLOUD${NC}       |        YOUTUBE CHANNEL: ${YELLOW}@DVHOST_CLOUD${NC}                 |"
    echo -e "+------------------------------------------------------------------------------------------------+${NC}"
    echo -e "|${GREEN}Server Country    |${NC} $SERVER_COUNTRY"
    echo -e "|${GREEN}Server IP         |${NC} $SERVER_IP"
    echo -e "|${GREEN}Server ISP        |${NC} $SERVER_ISP"
    echo "+------------------------------------------------------------------------------------------------+"
    echo -e "|${YELLOW}Please choose an option:${NC}"
    echo "+------------------------------------------------------------------------------------------------+"
    echo -e $1
    echo "+------------------------------------------------------------------------------------------------+"
    echo -e "\033[0m"
}

loader(){
    
    menu "| 1  - Install WordPress \n| 2  - Unistall \n|  0  - Exit"
    read -p "Enter option number: " choice
    
    case $choice in
        1)
            install_wordpress
        ;;
        2)
            unistall_wordpress
        ;;
        0)
            echo -e "${GREEN}Exiting program...${NC}"
            exit 0
        ;;
        *)
            echo "Not valid"
        ;;
    esac
    
    
}

install_wordpress(){
    wget https://raw.githubusercontent.com/dev-ir/WordPress-Installer/master/wp_installer.sh
    bash wp_installer
}

unistall_wordpress() {
    echo -e "${RED}Removing WordPress...${NC}"
    
    sudo systemctl stop apache2
    
    sudo rm -rf /srv/www/wordpress
    
    mysql -u root -p <<EOF
DROP DATABASE wordpress;
DROP USER 'wordpress'@'localhost';
EOF
    sudo rm wp_installer
    sudo rm -rf /etc/apache2/sites-available/wordpress.conf
    sudo a2disconf wordpress.conf
    
    sudo systemctl start apache2
    
    echo "WordPress has been uninstalled."
}

necessary_package
loader