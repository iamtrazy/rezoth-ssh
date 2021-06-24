#!/bin/bash
echo -ne "Enter the username : "; read username
echo -ne "Enter password (please use a strong password) : "; read password
echo -ne "Enter No. of Days till expiration : ";read nod
exd=$(date +%F  -d "$nod days")
useradd -e $exd -M -N -s /bin/false $username && echo "$username:$password" | chpasswd && echo User $username added to the system successfully || echo Failed to add user $username please try again.
echo returned
