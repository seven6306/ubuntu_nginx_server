#!/usr/bin/python
from sys import argv
from os import makedirs
from os.path import isfile, isdir, join
from create_x509_cert import create_self_signed_cert

if __name__ == '__main__':
    if len(argv) == 2:
        cert_name, nginx_dir = 'nginx', argv[1]
        ssl_dir = join(nginx_dir, 'ssl')
        if not isdir(ssl_dir):
            makedirs(ssl_dir)
        print '\033[1;35mGenerate SSL Certification:\033[0m'
        create_self_signed_cert(join(ssl_dir, cert_name))
        if not isfile(join(ssl_dir, cert_name + '.key')) or not isfile(join(ssl_dir, cert_name + '.crt')):
            print "\033[0;31m * \033[0m%s\t%26s\033[0;31m%s\033[0m]\n" % ("Generate SSL certification encrypt: sha256", "[", "Fail")
            raise SystemExit(3)
        print "\033[0;32m * \033[0m%s\t%26s\033[0;32m %s \033[0m]\n" % ("Generate SSL certification encrypt: sha256", "[", "OK")
    else:
        print 'Usage: python SSLgenerator.py [PATH]'
