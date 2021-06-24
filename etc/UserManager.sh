#!/bin/bash
echo -n "Enter the  username : "
read username
echo -n "Enter  password (please use a strong password) : "
read password
echo -n "Enter  No. of Days till expiration : "
read nod
exd=$(date +%F  -d "$nod days")
useradd -e $exd -s /bin/true -p $password $username && echo User $username added to the system successfully || echo Failed to add user $username please try again.
echo returned
