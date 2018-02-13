#!/bin/bash
# Script for ubuntu 14.04 LTS
. lib/declare_variables.sh
retry_time=10
exe_path=$PWD

python lib/checkInstall.py nginx --install "/usr/sbin/nginx,/etc/nginx,/usr/local/nginx"
python lib/checkCurrentdir.py $exe_path || exit 1
python lib/checkPermission.py || exit 1
python lib/notification.py "Setup nginx server will take 15-20 minutes, Are you sure? [y/N]: " "${PURPLE}Start installing nginx server...${NC}\n${LINE}\n" || exit 0
for pkg in 'nginx-1.4.6.tar.gz' 'pcre-8.40.tar.gz' 'openssl-1.0.1c.tar.gz' 'zlib-1.2.11.tar.gz'
do  printf "${PURPLE}Extract package $pkg${NC}\n"
    rm -rf /usr/src/$pkg /usr/src/`echo $pkg | awk -F\.tar '{print $1}'`
    cp -r ${exe_path}/packages/$pkg /usr/src/
    tar -C /usr/src/ -zxf /usr/src/$pkg
done

#sudo apt-get install build-essential libssl-dev -y
printf "${LINE}\n${PURPLE}Install deb packages starting:${NC}\n${LINE}\n"
[ `lscpu | grep Architecture: | awk '{print $2}' | grep -c 64` -ne 0 ] && dpkg -i ${exe_path}/packages/deb_amd64/*.deb || dpkg -i ${exe_path}/packages/deb_i386/*.deb

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
printf "${LINE}\n\t\t\t${RED}Packages installed end line${NC}\n${LINE}\n"

python SSLgenerator.py /usr/local/nginx

[ `/usr/src/nginx-1.4.6/objs/nginx -V 2>&1 | grep -c with-ipv6` -ne 0 ] && printf "\033[0;32m * \033[0m%s\t%34s\033[0;32m %s \033[0m]\n" "Import ipv6 module to nginx server" "[" "OK" || printf "\033[0;31m * \033[0m%s\t%34s\033[0;31m%s\033[0m]\n" "Import ipv6 module to nginx server" "[" "Fail"
rm -f /usr/local/nginx/conf/nginx.conf && cp -f ${exe_path}/nginx.conf /usr/local/nginx/conf/nginx.conf
[ -f /usr/local/nginx/conf/nginx.conf ] && printf "\033[0;32m * \033[0m%s\t%34s\033[0;32m %s \033[0m]\n" "Move nginx server configuration file" "[" "OK" || printf "\033[0;31m * \033[0m%s\t%34s\033[0;31m%s\033[0m]\n" "Move nginx server configuration file" "[" "Fail"
[ `grep -c "/usr/local/nginx/sbin/nginx" /etc/init.d/rc.local` -eq 0 ] && sed -i "/### END INIT INFO/ a /usr/local/nginx/sbin/nginx" /etc/init.d/rc.local
ln -f /usr/local/nginx/sbin/nginx /usr/sbin/nginx
/usr/local/nginx/sbin/nginx && printf "\033[0;32m * \033[0m%s\t%34s\033[0;32m %s \033[0m]\n" "Starting nginx server plug-in is" "[" "OK" || printf "\033[0;31m * \033[0m%s\t%34s\033[0;31m%s\033[0m]\n" "Starting nginx server plug-in is" "[" "Fail"
printf "\n${PURPLE}Nginx server info:${NC}\n * version - ${GREEN}v1.4.6${NC}\n * site - ${GREEN}https://`python lib/gethostIPaddr.py`${NC} \n * port - ${RED}443 (SSL)${NC}\n * config - /usr/local/nginx/conf/nginx.conf\n * command - nginx -s ${RED}stop${NC}|${RED}quit${NC}|${GREEN}reopen${NC}|${GREEN}reload${NC}\n\n"

