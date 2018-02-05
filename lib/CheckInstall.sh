#!/bin/bash
CheckInstall()
{
    local action=$1
    if [ -d /etc/nginx -o -d /usr/local/nginx ]; then
        case $action in
            --install) printf "\033[0;31mERROR: Nginx server is already installed.\033[0m\n" && exit 1;;
	    --remove)  printf "%s\t%31s\033[0;32m %s \033[0m]\n" " * Check if nginx is installed      " "[" "OK";;
        esac
    else
        case $action in
            --install) printf "%s\t%31s\033[0;32m %s \033[0m]\n" " * Check if nginx is installed      " "[" "OK" && return 0;;
	    --remove)  printf "\033[0;31mERROR: Nginx server is not installed.\033[0m\n" && exit 1;;
        esac
    fi
}
