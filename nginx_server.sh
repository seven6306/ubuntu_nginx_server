#!/bin/bash
# Script for ubuntu 14.04 LTS
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[1;35m'
NC='\033[0m'

touch /etc/init.d/request.tmp >> /dev/null 2>&1
[ $? -ne 0 ] && printf "${RED}ERROR: Permission denied, try \'sudo\' to execute the script.${NC}\n" && exit 1
rm -f /etc/init.d/request.tmp
[ `dpkg -l | awk '{print $2}' | grep -co nginx >> /dev/null 2>&1` -ne 0 ] && printf "${RED}ERROR: Service nginx is already installed.${NC}\n" && exit 1
printf "${PURPLE}Start installing nginx server...${NC}\n"
printf "===================================================================\n"
apt-get update
apt-get install nginx -y
printf "===================================================================\n\n"
[ ! -d /etc/nginx/ssl ] && sudo mkdir -p /etc/nginx/ssl || rm -rf /etc/nginx/ssl/*
printf "\n${PURPLE}Generate SSL Certification:${NC}\n"
printf "===================================================================\n"
openssl req -x509 -nodes -sha256 -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=TW/ST=TAIPEI/L=Stockholm /O=A/OU=B/CN=C/emailAddress=xxx@xxx.com"
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 4096
printf "===================================================================\n\n"
for each_line in 'ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";' 'ssl_protocols TLSv1 TLSv1.1 TLSv1.2;' 'ssl_certificate_key /etc/nginx/ssl/nginx.key;' 'ssl_certificate /etc/nginx/ssl/nginx.crt;' 'ssl_dhparam /etc/nginx/ssl/dhparam.pem;' 'ssl_prefer_server_ciphers on;' 'ssl on;' 'listen 443 ssl;' '#SSL Part' ''
do
	sed -i "/# Make site accessible from/ a \ \ \ \ \ \ \ \ ${each_line}" /etc/nginx/sites-enabled/default
done
service nginx reload && service nginx restart
[ `service nginx status | grep -co not` -eq 0 ] && printf "${GREEN}Nginx server is running${NC} (Protocol: ${RED}Https 443 port${NC})\n" || printf "${RED}Sorry, nginx server is unavailable...${NC}\n"

