#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

clear

echo -ne "${YELLOW}Enter the username : "; read username
while true; do
    read -p "Do you want to Delete The User $username ? (Y/N) " yn
    case $yn in
        [Yy]* ) userdel $username && echo -e "${RED}User $username deleted ${ENDCOLOR}" || echo -e "${RED}Failed to delete user  $username ${ENDCOLOR}"; break;;
        [Nn]* ) echo -e "${RED}\nDelete cancelled.${ENDCOLOR}"&&break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e "\nPress Enter key to return to main menu"; read
menu
