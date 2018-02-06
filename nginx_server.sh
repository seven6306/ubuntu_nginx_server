#!/bin/bash
# Script for ubuntu 14.04 LTS
. lib/CheckInstall.sh
. lib/Notification.sh
. lib/SSLGenerator.sh
. lib/GethostIPAddr.sh
. lib/NetworkConnTest.sh
. lib/CheckPermission.sh
. lib/declare_variables.sh

CheckPermission && CheckInstall --install && NetworkConnTest www.google.com
Notification "Setup nginx server will take 30-60 minutes, Are you sure? [y/N]: " "${PURPLE}Start installing nginx server...${NC}\n${LINE}\n"
[ `dpkg -l | awk '{print $2}' | grep -co nginx` -ne 0 ] && printf "${RED}ERROR: Server nginx is already installed.${NC}\n" && exit 1
apt-get update
apt-get install nginx -y
printf "${LINE}\n\n"
[ `grep -c "# Make site accessible from" /etc/nginx/sites-enabled/default` -eq 0 ] && printf "${RED}ERROR: Configuration file of nginx is incompatible, No keyword \"# Make site accessible from\".${NC}\n" && exit 1
SSLGenerator /etc/nginx
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 4096
printf "${LINE}\n\n${PURPLE}Backup config /etc/nginx/sites-enabled/default${NC}\n\n${PURPLE}Restart nginx service & config:${NC}\n"
mkdir -p /etc/nginx/bakeup && cp -r /etc/nginx/sites-enabled/default /etc/nginx/bakeup/default.bak
for each_line in 'ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";' 'ssl_protocols TLSv1 TLSv1.1 TLSv1.2;' 'ssl_certificate_key /etc/nginx/ssl/nginx.key;' 'ssl_certificate /etc/nginx/ssl/nginx.crt;' 'ssl_dhparam /etc/nginx/ssl/dhparam.pem;' 'ssl_prefer_server_ciphers on;' 'ssl on;' 'listen 443 ssl;' '#SSL Part' ''
do  sed -i "/# Make site accessible from/ a \ \ \ \ \ \ \ \ ${each_line}" /etc/nginx/sites-enabled/default
done
service nginx reload && service nginx restart
[ `service nginx status | grep -co not` -eq 0 ] && printf "\nNginx server is running (Site: ${GREEN}https://`GethostIPAddr`${NC} Protocol: ${RED}Https 443 port${NC})\n\n" || printf "\n${RED}Sorry, nginx server is unavailable...${NC}\n\n"

