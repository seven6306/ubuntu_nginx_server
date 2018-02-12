#!/bin/bash
# Script for ubuntu 14.04 LTS
. lib/declare_variables.sh

python lib/checkPermission.py || exit 1
python lib/checkInstall.py nginx --remove "/usr/sbin/nginx,/etc/nginx,/usr/local/nginx" || exit 1
printf "Remove nginx server will ${RED}terminate each web service dependent on it${NC}, \n"
python lib/notification.py "Are you sure? [y/N]: " "\n${PURPLE}Start removing nginx server...${NC}\n${LINE}\n" || exit 0
[ `dpkg -l | grep -c nginx` -ne 0 ] && service nginx stop && apt-get remove nginx nginx-core -y
[ `ps -ef | grep -c nginx` -gt 1 ] && /usr/local/nginx/sbin/nginx -s stop
[ -f /usr/sbin/nginx ] && rm -f /usr/sbin/nginx
[ -d /usr/local/nginx ] && rm -rf /usr/local/nginx
# clear offline packages
for rm_pkg in 'nginx-1.4.6' 'pcre-8.40' 'openssl-1.0.1c' 'zlib-1.2.11'
do  [ -d /usr/src/${rm_pkg} ] && rm -rf /usr/src/${rm_pkg}
    [ -f /usr/src/${rm_pkg}.tar.gz ] && rm -f /usr/src/${rm_pkg}.tar.gz
done
printf "${LINE}\n\n ${GREEN}*${NC} Remove nginx server completed.\n\n"
