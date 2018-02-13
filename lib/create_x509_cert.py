#!/usr/bin/python
from sys import argv
from OpenSSL import crypto
from os import remove
from os.path import isfile, join

def create_self_signed_cert(fileName):
    try:
        CERT_FILE, KEY_FILE = fileName + ".crt", fileName + ".key"
        for c in [CERT_FILE, KEY_FILE]:
            if isfile(c):
                remove(c)
        # create a key pair
        key = crypto.PKey()
        key.generate_key(crypto.TYPE_RSA, 2048)

        # create a self-signed cert
        cert = crypto.X509()
        cert.get_subject().C = "TW"
        cert.get_subject().ST = "TAIPEL"
        cert.get_subject().L = "Stockholm"
        cert.get_subject().O = "A"
        cert.get_subject().OU = "vivotek"
        cert.get_subject().CN = "C"
        cert.set_serial_number(1000)
        cert.gmtime_adj_notBefore(0)
        cert.gmtime_adj_notAfter(10*365*24*60*60)
        cert.set_issuer(cert.get_subject())
        cert.set_pubkey(key)
        cert.sign(key, 'sha256')
        open(CERT_FILE, "wt").write(crypto.dump_certificate(crypto.FILETYPE_PEM, cert))
        open(KEY_FILE, "wt").write(crypto.dump_privatekey(crypto.FILETYPE_PEM, key))
    except Exception as err:
        print str(err)
        raise SystemExit(59)

if __name__ == '__main__':
    if len(argv) == 2:
        KeyName = argv[1]
        create_self_signed_cert(KeyName)
    else:
        print 'Usage: python create_x509_cert.py [KeyName]'
