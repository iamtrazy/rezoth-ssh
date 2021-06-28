#!/bin/bash

GREEN="\e[32m"
ENDCOLOR="\e[0m"

clear

allusers=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody)
echo -e "${GREEN}$allusers${ENDCOLOR}"

echo -e "\nPress Enter key to return to main menu"; read
menu
