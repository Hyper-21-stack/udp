#!/bin/bash

is_number() {
    [[ $1 =~ ^[0-9]+$ ]]
}

YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$(whoami)" != "root" ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

cd /root
clear

echo -e "$YELLOW
💚 HTTP CUSTOM UDP INSTALLER 💚      
 ╰┈➤ 💚 Resleeved Net 💚               
$NC"

echo "Select an option"
echo "1. Install HTTP CUSTOM UDP"
echo "0. Exit"

read -p "$(echo -e "\033[1;33mSelect a number from 0 to 1: \033[0m")" input

if ! is_number "$input"; then
    echo -e "$YELLOW"
    echo "Invalid input. Please enter a valid number."
    echo -e "$NC"
    exit 1
fi

selected_option=$input

clear

case $selected_option in
    1)
        echo -e "$YELLOW"
        echo "     💚 HTTP CUSTOM UDP AUTO INSTALLATION 💚      "
        echo "        ╰┈➤💚 Installing Binaries 💚           "
        echo -e "$NC"

        apt install -y curl dos2unix neofetch wget screen

        # Stop old services if exist
        systemctl stop custom-server.service 2>/dev/null
        systemctl disable custom-server.service 2>/dev/null
        rm -rf /etc/systemd/system/custom-server.service

        systemctl stop udpgw.service 2>/dev/null
        systemctl disable udpgw.service 2>/dev/null
        rm -rf /etc/systemd/system/udpgw.service

        rm -rf /root/udp /usr/bin/udp /usr/bin/udpgw

        # Prepare working directory
        mkdir -p /root/udp
        cd /root/udp

        # Download necessary files from your GitHub
        wget -O custom-linux-amd64 'https://github.com/Hyper-21-stack/udp/releases/download/v1/custom-linux-amd64'
        chmod 755 custom-linux-amd64

        wget -O module 'https://raw.githubusercontent.com/Hyper-21-stack/udp/main/module/module'
        chmod 755 module

        wget -O limiter.sh 'https://raw.githubusercontent.com/Hyper-21-stack/udp/main/module/limiter.sh'
        chmod 755 limiter.sh

        cd /root
        wget -O /usr/bin/udp 'https://raw.githubusercontent.com/Hyper-21-stack/udp/main/module/udp'
        chmod 755 /usr/bin/udp

        # Config JSON
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

        # Create systemd service for custom-linux-amd64
        cat <<EOF >/etc/systemd/system/custom-server.service
[Unit]
Description=UDP Custom by ResleevedNet

[Service]
User=root
Type=simple
ExecStart=/root/udp/custom-linux-amd64 server -c /root/udp/config.json
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2
StandardOutput=file:/root/udp/custom.log

[Install]
WantedBy=multi-user.target
EOF

        # Start the UDP custom server
        systemctl daemon-reload
        systemctl enable custom-server.service
        systemctl start custom-server.service

        # Install BadVPN (UDPGW)
        wget -O /usr/bin/udpgw 'https://github.com/Hyper-21-stack/udp/releases/download/v1/udpgw'
        chmod 755 /usr/bin/udpgw

        cat <<EOF >/etc/systemd/system/udpgw.service
[Unit]
Description=UDPGW Gateway Service by ResleevedNet
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/screen -dmS udpgw /usr/bin/udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 1000
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

        systemctl daemon-reload
        systemctl enable udpgw.service
        systemctl start udpgw.service

        clear
        echo -e "$YELLOW"
        echo "     💚 P2P SERVICE INITIALIZED 💚     "
        echo "     ╰┈➤💚 Badvpn Activated 💚         "
        echo " ╰┈➤ 💚 HTTP CUSTOM UDP SUCCESSFULLY INSTALLED 💚       "
        echo -e "$NC"
        exit 0
        ;;
    *)
        echo -e "$YELLOW"
        echo "Welcome To Resleeved Net"
        echo -e "$NC"
        exit 1
        ;;
esac
