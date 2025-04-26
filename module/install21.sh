#!/bin/bash

# Colors
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check if input is a number
is_number() {
    [[ $1 =~ ^[0-9]+$ ]]
}

# Root Check
if [ "$(whoami)" != "root" ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

cd /root
clear

# Menu
echo -e "$YELLOW
💚 HTTP CUSTOM UDP INSTALLER 💚      
 ╰┈➤ 💚 Resleeved Net 💚               
$NC
Select an option:"
echo "1. Install HTTP CUSTOM UDP"
echo "0. Exit"

read -p "$(echo -e "\033[1;33mSelect a number from 0 to 1: \033[0m")" input

if ! is_number "$input"; then
    echo -e "$YELLOW Invalid input. Please enter a number. $NC"
    exit 1
fi

selected_option=$input
clear

case $selected_option in
1)
    echo -e "$YELLOW"
    echo "     💚 HTTP CUSTOM UDP AUTO INSTALLATION 💚      "
    echo "        ╰┈➤💚 Installing Packages 💚           "
    echo -e "$NC"

    # Install dependencies
    apt update -y
    apt install -y curl wget dos2unix neofetch screen

    # Stop previous services
    systemctl stop custom-server.service 2>/dev/null
    systemctl disable custom-server.service 2>/dev/null
    rm -rf /etc/systemd/system/custom-server.service
    systemctl stop udpgw.service 2>/dev/null
    systemctl disable udpgw.service 2>/dev/null
    rm -rf /etc/systemd/system/udpgw.service

    # Clean old files
    rm -rf /root/udp /usr/bin/udp /usr/bin/udpgw
    rm -rf /root/.config /root/.cache /root/.ssh /root/snap

    # Create udp folder
    mkdir -p /root/udp
    cd /root/udp

    echo -e "$YELLOW Downloading server files...$NC"

    # Download files from YOUR GitHub
    wget -O custom-linux-amd64 https://github.com/Hyper-21-stack/udp/releases/download/V1/custom-linux-amd64
    chmod 755 custom-linux-amd64

    wget -O module.sh https://raw.githubusercontent.com/Hyper-21-stack/udp/main/module/module.sh
    chmod +x module.sh

    wget -O limiter.sh https://raw.githubusercontent.com/Hyper-21-stack/udp/main/module/limiter.sh
    chmod +x limiter.sh

    wget -O udp.sh https://raw.githubusercontent.com/Hyper-21-stack/udp/main/module/udp.sh
    chmod +x udp.sh

    # Install 'udp' command
    wget -O /usr/bin/udp https://raw.githubusercontent.com/Hyper-21-stack/udp/main/module/udp.sh
    chmod +x /usr/bin/udp

    # Create config file
    echo -e "$YELLOW Setting up config.json...$NC"
    cat <<EOF >/root/udp/config.json
{
    "listen": ":443",
    "stream_buffer": 16777216,
    "receive_buffer": 83886080,
    "auth": {
        "mode": "passwords"
    }
}
EOF

    chmod 755 /root/udp/config.json

    # Create custom-server.service
    echo -e "$YELLOW Setting up systemd service for custom-server...$NC"
    cat <<EOF >/etc/systemd/system/custom-server.service
[Unit]
Description=UDP Custom by Resleeved Net

[Service]
User=root
Type=simple
ExecStart=/root/udp/custom-linux-amd64 server -c /root/udp/config.json
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2
StandardOutput=file:/root/udp/custom.log

[Install]
WantedBy=default.target
EOF

    # Start and enable custom-server
    systemctl daemon-reload
    systemctl enable custom-server.service
    systemctl start custom-server.service

    # Install BadVPN (udpgw)
    echo -e "$YELLOW Installing BadVPN (udpgw)...$NC"
    wget -O /usr/bin/udpgw https://github.com/Hyper-21-stack/udp/releases/download/V1/udpgw
    chmod +x /usr/bin/udpgw

    # Create udpgw service
    cat <<EOF >/etc/systemd/system/udpgw.service
[Unit]
Description=UDPGW Gateway Service by Resleeved Net
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/screen -dmS udpgw /usr/bin/udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 1000
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

    # Start and enable udpgw
    systemctl daemon-reload
    systemctl enable udpgw.service
    systemctl start udpgw.service

    echo -e "$YELLOW"
    echo "     💚 P2P SERVICE INITIALIZED 💚     "
    echo "     ╰┈➤💚 Badvpn Activated 💚         "
    echo " ╰┈➤ 💚 HTTP CUSTOM UDP SUCCESSFULLY INSTALLED 💚       "
    echo -e "$NC"
    ;;

*)
    echo -e "$YELLOW Welcome To Resleeved Net! $NC"
    exit 1
    ;;
esac
