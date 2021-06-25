#!/bin/bash

#font colors

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

#installing pre-requirements and adding port rules to ubuntu firewall

apt update -y && apt upgrade -y

apt-get install -y dropbear && apt-get install -y stunnel4 && apt-get install -y squid && apt-get install -y cmake

ufw allow 443/tcp
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 110/tcp
ufw allow 8080/tcp
ufw allow 7300/tcp
ufw allow 7300/udp

#configuring openssh

sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#Banner none/Banner \/etc\/banner/' /etc/ssh/sshd_config

#configuring dropbear

rm -rf /etc/default/dropbear
cat << EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_PORT=80
DROPBEAR_EXTRA_ARGS="-p 110"
DROPBEAR_BANNER="/etc/banner"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
EOF

#Adding the banner

cat << EOF > /etc/banner
<br>
<font>ೋ˚❁ೃೀ๑۩۞۩๑ೃೀ❁ೋ˚</font><br>
<font>┊┊┊┊ <b><font color="#ff5079">&nbsp;Rezoth</font>™</b></font><br>
<font>┊┊┊✧ </font><br>
<font>┊┊✦ <font color="#A52A2A">&nbsp;NO HACKING !!!</font></font><br>
<font>┊✧ <font color="#8A2BE2">&nbsp;NO CARDING !!!</font></font><br>
<font>✦ <font color="#FF7F50">&nbsp;NO TORRENT !!!</font></font><br>
<font>.   ✫   .  ˚  ✦  · </font><br>
<font> .  +  · · <font color="#33a6ff"></font></font><br>
<font>    ✹   . <font color="#008080">&nbsp;Your privacy is our number one priority</font></font><br>
<font>✦  · </font><br>
<b>&nbsp;Powered by <font color="#ff5079">Rezoth™</font></b><br>
<font>     .  +  · </font>
EOF

#Configuring stunnel

mkdir /etc/stunnel
cat << EOF > /etc/stunnel/stunnel.conf
cert = /etc/stunnel/stunnel.pem
client = no
sslVersion = all
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
TIMEOUTclose = 0

[dropbear]
accept = 443
connect = 127.0.0.1:110

[openssh]
accept = 444
connect = 127.0.0.1:22
EOF

#Genarating a self signed certificate for stunnel

openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
    -out stunnel.pem  -keyout stunnel.pem

cp stunnel.pem /etc/stunnel/stunnel.pem
chmod 644 /etc/stunnel/stunnel.pem

#Enable overide stunnel default

sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4

# Configuring squid

sed -i 's/http_access deny !Safe_ports/#http_access deny !Safe_ports/'  /etc/squid/squid.conf
sed -i 's/http_access deny CONNECT !SSL_ports/#http_access deny CONNECT !SSL_ports/' /etc/squid/squid.conf
sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf
sed -i 's/http_port 3128/http_port 8080/' /etc/squid/squid.conf

#build and install badvpn-udpgw

git clone https://github.com/ambrop72/badvpn
cd badvpn
cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make install

#creating badvpn systemd service unit

cat << EOF > /etc/systemd/system/udpgw.service
[Unit]
Description=UDP forwarding for badvpn-tun2socks
After=nss-lookup.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --loglevel none --listen-addr 127.0.0.1:7300
User=udpgw

[Install]
WantedBy=multi-user.target
EOF

#enabling and starting all services

sudo useradd -m udpgw

systemctl restart sshd
systemctl enable dropbear
systemctl restart dropbear
systemctl enable stunnel4
systemctl restart stunnel4
systemctl enable squid
systemctl restart squid
sudo systemctl enable udpgw
sudo systemctl restart udpgw

#configure user shell to /bin/false
echo /bin/false >> /etc/shells
clear

#Adding the default user
echo -ne "Enter the default username : "; read username
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
echo -e "${GREEN}Default User Details ${ENDCOLOR}" &&
echo -e "${RED}------------ ${ENDCOLOR}" &&
echo -e "${GREEN}\nUsername : $username${ENDCOLOR}" &&
echo -e "${GREEN}\nPassword : $password${ENDCOLOR}" &&
echo -e "${GREEN}\nExpire Date : $exd${ENDCOLOR}" ||
echo -e "${RED}\nFailed to add default user $username please try again.${ENDCOLOR}"

#exit script
echo -e "\nPress Enter Key to exit"; read
