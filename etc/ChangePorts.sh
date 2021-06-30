#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"

old_db_port=$(grep "DROPBEAR_PORT=" /etc/default/dropbear | sed 's/=/= /'  | awk '{print$2}')

old_db_ssl=$(grep "accept =" /etc/stunnel/stunnel.conf | sed ':a;N;$!ba;s/\n/ /g' | sed 's/accept =//g' | awk '{print$1}')

old_op_ssl=$(grep "accept =" /etc/stunnel/stunnel.conf | sed ':a;N;$!ba;s/\n/ /g' | sed 's/accept =//g' | awk '{print$2}')

old_squid_port=$(sed /^#/d /etc/squid/squid.conf | grep "http_port" | awk '{print$2}')

old_udpgw_port=$(cat /etc/systemd/system/udpgw.service | sed 's/ /\n/g'  | grep "127.0.0.1:" | sed 's/:/ /' | awk '{print$2}')

clear

echo -e "${YELLOW}-------- Server Details -----------\n"
echo -e "${GREEN}Dropbear port : $old_db_port"
echo -e "Dropbear + SSL port : $old_db_ssl"
echo -e "Openssh +  SSL port : $old_op_ssl"
echo -e "Squid port : $old_squid_port"
echo -e "BadVPN UDP Gateway port : $old_udpgw_port\n"
echo -e "${RED}-----------------------------------\n"
echo -e "${CYAN}  1)Change Dropbear port"
echo -e "  2)Change Dropear + SSL port"
echo -e "  3)Change Openssh + SSL port"
echo -e "  4)Change Squid port"
echo -e "  5)Change BadVPN UDPGW port"
echo -e "  6)Return to main Menu"

echo -ne "${GREEN}\nSelect Operation : ${ENDCOLOR}" ;read n

fail_db()
{
echo -e "\n${RED}Failed to change port please recheck the port you entered and try again" &&
mv  /etc/default/dropbear.cbackup /etc/default/dropbear &&
ufw allow $old_db_port/tcp > /dev/null &&
systemctl restart dropbear
}

change_db()
{
clear
echo -e "${GREEN}Current Dropbear port is $old_db_port\n"
echo  -ne "${YELLOW}Please enter new Dropbear port: ";read new_db_port
cp /etc/default/dropbear /etc/default/dropbear.cbackup
sed -i "0,/\b$old_db_port\b/s//$new_db_port/" /etc/default/dropbear &&
ufw delete allow $old_db_port/tcp > /dev/null &&
ufw allow $new_db_port/tcp > /dev/null &&
systemctl restart dropbear &&
rm -f /etc/default/dropbear.cbackup &&
echo -e "\n${GREEN}New Dropbear port is $new_db_port ${ENDCOLOR} " ||
fail_db
echo -e "\nPress Enter to return back" ;read && /etc/rezoth-ssh/ChangePorts.sh
}

fail_db_ssl()
{
echo -e "\n${RED}Failed to change port please recheck the port you entered and try again" &&
mv /etc/stunnel/stunnel.conf.cbackup /etc/stunnel/stunnel.conf &&
ufw allow $old_db_ssl/tcp > /dev/null &&
systemctl restart stunnel4
}

change_db_ssl()
{
clear
echo -e "${GREEN}Current Dropbear + SSL port is $old_db_ssl\n"
echo  -ne "${YELLOW}Please enter new Dropbear + SSL port: ";read new_db_ssl
cp /etc/stunnel/stunnel.conf /etc/stunnel/stunnel.conf.cbackup
sed -i "0,/\b$old_db_ssl\b/s//$new_db_ssl/" /etc/stunnel/stunnel.conf &&
ufw delete allow $old_db_ssl/tcp > /dev/null &&
ufw allow $new_db_ssl/tcp > /dev/null &&
systemctl restart stunnel4 &&
rm -f /etc/stunnel/stunnel.conf.cbackup &&
echo -e "\n${GREEN}New Dropbear + SSL port is $new_db_ssl ${ENDCOLOR} " ||
fail_db_ssl
echo -e "\nPress Enter to return back" ;read && /etc/rezoth-ssh/ChangePorts.sh
}

fail_op_ssl()
{
echo -e "\n${RED}Failed to change port please recheck the port you entered and try again" &&
mv /etc/stunnel/stunnel.conf.cbackup /etc/stunnel/stunnel.conf &&
ufw allow $old_op_ssl/tcp > /dev/null &&
systemctl restart stunnel4
}

change_op_ssl()
{
clear
echo -e "${GREEN}Current Openssh + SSL port is $old_op_ssl\n"
echo  -ne "${YELLOW}Please enter new Openssh + SSL port: ";read new_op_ssl
cp /etc/stunnel/stunnel.conf /etc/stunnel/stunnel.conf.cbackup
sed -i "0,/\b$old_op_ssl\b/s//$new_op_ssl/" /etc/stunnel/stunnel.conf &&
ufw delete allow $old_op_ssl/tcp > /dev/null &&
ufw allow $new_op_ssl/tcp > /dev/null &&
systemctl restart stunnel4 &&
rm -f /etc/stunnel/stunnel.conf.cbackup &&
echo -e "\n${GREEN}New Openssh + SSL port is $new_op_ssl ${ENDCOLOR} " ||
fail_db_ssl
echo -e "\nPress Enter to return back" ;read && /etc/rezoth-ssh/ChangePorts.sh
}

fail_squid()
{
echo -e "\n${RED}Failed to change port please recheck the port you entered and try again" &&
mv /etc/squid/squid.conf.cbackup /etc/squid/squid.conf &&
ufw allow $old_squid_port/tcp > /dev/null &&
systemctl restart squid
}

change_squid()
{
clear
echo -e "${GREEN}Current Squid port is $old_squid_port\n"
echo  -ne "${YELLOW}Please enter new Squid port: ";read new_squid_port
cp /etc/squid/squid.conf /etc/squid/squid.conf.cbackup
sed -i "/^#/!s/$old_squid_port/$new_squid_port/g" /etc/squid/squid.conf &&
ufw delete allow $old_squid_port/tcp > /dev/null &&
ufw allow $new_squid_port/tcp > /dev/null &&
systemctl restart squid &&
rm -f squid.conf.cbackup &&
echo -e "\n${GREEN}New Squid port is $new_squid_port ${ENDCOLOR} " ||
fail_squid
echo -e "\nPress Enter to return back" ;read && /etc/rezoth-ssh/ChangePorts.sh
}

fail_udpgw()
{
echo -e "\n${RED}Failed to change port please recheck the port you entered and try again" &&
mv /etc/systemd/system/udpgw.service.cbackup /etc/systemd/system/udpgw.service &&
ufw allow $old_udpgw_port/tcp > /dev/null &&
ufw allow $old_udpgw_port/udp > /dev/null &&
systemctl daemon-reload
systemctl restart udpgw.service
}

change_udpgw()
{
clear
echo -e "${GREEN}Current BadVPN UDPGW port is $old_udpgw_port\n"
echo  -ne "${YELLOW}Please enter new BadVPN UDPGW: ";read new_udpgw_port
cp /etc/systemd/system/udpgw.service /etc/systemd/system/udpgw.service.cbackup
sed -i "0,/\b$old_udpgw_port\b/s//$new_udpgw_port/" /etc/systemd/system/udpgw.service &&
ufw delete allow $old_udpgw_port/tcp > /dev/null &&
ufw delete allow $old_udpgw_port/udp > /dev/null &&
ufw allow $new_udpgw_port/tcp > /dev/null &&
ufw allow $new_udpgw_port/udp > /dev/null &&
systemctl daemon-reload
systemctl restart udpgw.service
rm -f squid.conf.cbackup &&
echo -e "\n${GREEN}New BadVPN UDPGW is $new_udpgw_port ${ENDCOLOR} " ||
fail_udpgw
echo -e "\nPress Enter to return back" ;read && /etc/rezoth-ssh/ChangePorts.sh
}

case $n in
  1)change_db;;
  2)change_db_ssl;;
  3)change_op_ssl;;
  4)change_squid;;
  5)change_udpgw;;
  6)menu;;
  *) echo -e "${RED}\nInvalid Option. Press Enter to return back to the menu${ENDCOLOR}";read && /etc/rezoth-ssh/ChangePorts.sh;;
esac
