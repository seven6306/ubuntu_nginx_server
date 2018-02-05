#!/bin/bash
SSLGenerator()
{
    local nginx_dir=$1
    [ ! -d ${nginx_dir}/ssl ] && sudo mkdir -p ${nginx_dir}/ssl || rm -rf ${nginx_dir}/ssl/*
    printf "\n\033[1;35mGenerate SSL Certification:\033[0m\n${LINE}\n"
    openssl req -x509 -nodes -sha256 -days 365 -newkey rsa:2048 -keyout ${nginx_dir}/ssl/nginx.key -out ${nginx_dir}/ssl/nginx.crt -subj "/C=TW/ST=TAIPEI/L=Stockholm /O=A/OU=B/CN=C/emailAddress=xxx@xxx.com"
    if [ -f /usr/local/nginx/ssl/nginx.key -a -f /usr/local/nginx/ssl/nginx.crt ]; then
        printf "${LINE}\n\n\033[0;32m * \033[0m%s\t%24s\033[0;32m %s \033[0m]\n" "Generate SSL certification encrypt: sha256" "[" "OK"
        return 0
    else
        printf "${LINE}\n\n\033[0;31m * \033[0m%s\t%24s\033[0;31m %s \033[0m]\n" "Generate SSL certification encrypt: sha256" "[" "Fail"
        return 1
    fi
}
