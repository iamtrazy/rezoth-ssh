#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

spinner()
{
    #Loading spinner
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

remove_script()
{
apt-get remove --purge -y dropbear
apt-get remove --purge -y stunnel4
apt-get remove --purge -y squid
sed -i 's/Banner \/etc\/banner/#Banner none/' /etc/ssh/sshd_config
rm -f /etc/banner
rm -f /etc/default/dropbear
rm -f /etc/default/dropbear.backup
rm -rf /etc/stunnel
rm -f /etc/stunnel
rm -f /etc/stunnel.backup
rm -rf /etc/squid
rm -f /usr/local/bin/badvpn-udpgw
systemctl stop udpgw
systemctl disable udpgw
userdel udpgw
rm -f /etc/systemd/system/udpgw.service
systemctl daemon-reload
systemctl restart sshd
rm -rf /etc/rezoth-ssh
rm -f /usr/local/bin/menu
sed -i ':a;N;$!ba;s/\n\/bin\/false//g' /etc/shells
}

remove_confirm()
{
echo -ne "${RED}Removing Script ............."
remove_script >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo -e "${ENDCOLOR}"
}

clear
while true; do
    read -p "Do you want to remove the script? (Y/N) " yn
    case $yn in
        [Yy]* ) remove_confirm;echo -e "Remove Complete. Press Enter key to exit";read;break;;
        [Nn]* ) echo -e "${RED}Remove aborted !!. Press Enter key to return to main menu${ENDCOLOR}";read;menu;break;;
        * ) echo "Please answer yes or no.";;
    esac
done
