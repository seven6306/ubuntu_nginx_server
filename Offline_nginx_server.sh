#!/bin/bash
# Script for ubuntu 14.04 LTS
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[1;35m'
NC='\033[0m'
retry_time=10
exe_path=$PWD
LINE='============================================================================='

CheckPermission()
{
    local tmpfile=/etc/init.d/request.tmp
    touch $tmpfile >> /dev/null 2>&1
    [ $? -ne 0 ] && printf "\033[0;31mERROR: Permission denied, try \'sudo\' to execute the script.\033[0m\n" && exit 1
    printf "%s\t%31s\033[0;32m %s \033[0m]\n" " * Check root permission in executed" "[" "OK"
    rm -f $tmpfile
    return 0
}
Notification()
{
    read -p "$1" ans
    case $ans in
        y*|Y*) printf "$2";;
        *) exit 0;;
    esac
}
CheckPermission && Notification "Setup nginx server will take 15-20 minutes, Are you sure? [y/N]: " "${PURPLE}Start installing nginx server...${NC}\n${LINE}\n"
for pkg in 'nginx-1.4.6.tar.gz' 'pcre-8.40.tar.gz' 'openssl-1.0.1c.tar.gz' 'zlib-1.2.11.tar.gz'
do  printf "${PURPLE}Extract package $pkg${NC}\n"
    rm -rf /usr/src/$pkg /usr/src/`echo $pkg | awk -F\.tar '{print $1}'`
    cp -r ${exe_path}/packages/$pkg /usr/src/
    tar -C /usr/src/ -zxf /usr/src/$pkg
done

#sudo apt-get install build-essential libssl-dev -y
printf "${LINE}\n${PURPLE}Install deb packages starting:${NC}\n${LINE}\n"
[ `lscpu | grep Architecture: | awk '{print $2}' | grep -c 64` -ne 0 ] && dpkg -i ${exe_path}/packages/deb_amd64/*.deb

for dir in "/usr/src/pcre-8.40" "/usr/src/zlib-1.2.11" "/usr/src/openssl-1.0.1c"
do  cd $dir && printf "${LINE}\n${PURPLE}Configure `echo $dir | awk -F\/ '{print $4}'` starting:${NC}\n${LINE}\n"
    [ "$dir" = "/usr/src/openssl-1.0.1c" ] && sudo ./config shared zlib-dynamic || ./configure
    wait
	make
    [ "$dir" = "/usr/src/openssl-1.0.1c" ] && make install_sw || make install
done

cd /usr/src/nginx-1.4.6 && printf "${LINE}\n${PURPLE}Configure nginx-1.4.6 starting:${NC}\n${LINE}\n"
# loop make sure compiler is successfully
while [ $retry_time != 0 ]
do  sudo ./configure --with-openssl=/usr/local/ssl --with-http_ssl_module --with-pcre=/usr/src/pcre-8.40 --with-pcre-jit --without-http_autoindex_module --without-http_userid_module \
    --without-http_auth_basic_module --without-http_geo_module \
    --without-http_fastcgi_module --without-http_empty_gif_module \
    --with-poll_module --with-http_stub_status_module \
    --with-http_ssl_module --with-ipv6
    wait
    [ -f /usr/src/nginx-1.4.6/auto/lib/openssl/conf ] && [ `grep -c "\.openssl/" /usr/src/nginx-1.4.6/auto/lib/openssl/conf` -ne 0 ] && sed -i.bak 's,\.openssl/,,g' /usr/src/nginx-1.4.6/auto/lib/openssl/conf
    sudo make && sudo make install && break
    retry_time=$(($retry_time - 1))
	printf " ${RED}*${NC} Retry times remain: ${RED}${retry_time}${NC}\n"
done

printf "${LINE}\n\t\t\t${RED}Packages installed end line${NC}\n${LINE}\n\n${PURPLE}Generate SSL Certification:${NC}\n${LINE}\n"
[ ! -d /usr/local/nginx/ssl ] && mkdir -p /usr/local/nginx/ssl
openssl req -x509 -nodes -sha256 -days 365 -newkey rsa:2048 -keyout /usr/local/nginx/ssl/nginx.key -out /usr/local/nginx/ssl/nginx.crt -subj "/C=TW/ST=TAIPEI/L=Stockholm /O=A/OU=B/CN=C/emailAddress=xxx@xxx.com"

[ -f /usr/local/nginx/ssl/nginx.key -a -f /usr/local/nginx/ssl/nginx.crt ] && printf "${LINE}\n\n\033[0;32m * \033[0m%s\t%24s\033[0;32m %s \033[0m]\n" "Generate SSL certification encrypt: sha256" "[" "OK" || printf "${LINE}\n\n\033[0;31m * \033[0m%s\t%24s\033[0;31m %s \033[0m]\n" "Generate SSL certification encrypt: sha256" "[" "Fail"
[ `objs/nginx -V 2>&1 | grep -c with-ipv6` -ne 0 ] && printf "\033[0;32m * \033[0m%s\t%32s\033[0;32m %s \033[0m]\n" "Import ipv6 module to nginx server" "[" "OK" || printf "\033[0;31m * \033[0m%s\t%32s\033[0;31m %s \033[0m]\n" "Import ipv6 module to nginx server" "[" "Fail"
rm -f /usr/local/nginx/conf/nginx.conf && cp -f ${exe_path}/nginx.conf /usr/local/nginx/conf/nginx.conf
[ -f /usr/local/nginx/conf/nginx.conf ] && printf "\033[0;32m * \033[0m%s\t%32s\033[0;32m %s \033[0m]\n" "Move nginx server configuration file" "[" "OK" || printf "\033[0;31m * \033[0m%s\t%32s\033[0;31m %s \033[0m]\n" "Move nginx server configuration file" "[" "Fail"
[ `grep -c "/usr/local/nginx/sbin/nginx" /etc/init.d/rc.local` -eq 0 ] && sed -i "/### END INIT INFO/ a /usr/local/nginx/sbin/nginx" /etc/init.d/rc.local
ln -f /usr/local/nginx/sbin/nginx /usr/sbin/nginx
/usr/local/nginx/sbin/nginx && printf "\033[0;32m * \033[0m%s\t%32s\033[0;32m %s \033[0m]\n" "Starting nginx server plug-in is" "[" "OK" || printf "\033[0;31m * \033[0m%s\t%32s\033[0;31m %s \033[0m]\n" "Starting nginx server plug-in is" "[" "Fail"
host=`ip a | awk '{print $2}' | grep -v '127.0.0.1' | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}"`
printf "\n${PURPLE}Nginx server info:${NC}\n * version - ${GREEN}v1.4.6${NC}\n * site - ${GREEN}https://${host}${NC} \n * port - ${RED}443 (SSL)${NC}\n * config - /usr/local/nginx/conf/nginx.conf\n * command - nginx -s ${RED}stop${NC}|${RED}quit${NC}|${GREEN}reopen${NC}|${GREEN}reload${NC}\n\n"
