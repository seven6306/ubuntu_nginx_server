#!/bin/bash
CheckInstall()
{
    if [ -d /etc/nginx -o -d /usr/local/nginx ]; then
        printf "\033[0;31mERROR: Nginx server is already installed.\033[0m\n"
        exit 1
    else
        printf "%s\t%31s\033[0;32m %s \033[0m]\n" " * Check if nginx is installed      " "[" "OK"
        return 0
    fi
}
