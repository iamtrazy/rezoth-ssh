#!/bin/bash

#font colors

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

#add users

echo -ne "Enter the username : "; read username
while true; do
    read -p "Do you want to genarate a random password ? (Y/N) " yn
    case $yn in
        [Yy]* ) password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-9};echo;); break;;
        [Nn]* ) echo -ne "Enter password (please use a strong password) : "; read password; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo -ne "Enter No. of Days till expiration : ";read nod
exd=$(date +%F  -d "$nod days")
useradd -e $exd -M -N -s /bin/false $username && echo "$username:$password" | chpasswd &&
clear &&
echo -e "${GREEN}User Details ${ENDCOLOR}" &&
echo -e "${RED}------------ ${ENDCOLOR}" &&
echo -e "${GREEN}\nUsername : $username${ENDCOLOR}" &&
echo -e "${GREEN}\nPassword : $password${ENDCOLOR}" &&
echo -e "${GREEN}\nExpire Date : $exd${ENDCOLOR}" ||
echo -e "${RED}\nFailed to add user $username please try again.${ENDCOLOR}"

#return to panel

echo -e "\nPress Enter Key to return to main menu"; read
