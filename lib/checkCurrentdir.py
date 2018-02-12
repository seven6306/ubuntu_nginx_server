#!/usr/bin/python
from sys import argv
from re import search
from os import listdir
from os.path import join, isfile, isdir

def getfileSummary(dir, regx):
    tmp_list = []
    if not isdir(dir):
        return -1
    for e in listdir(dir):
        if search(regx, e):
            tmp_list.append(e)
    return (len(tmp_list), tmp_list)
if __name__ == '__main__':
    try:
        if len(argv) == 2:
            x, exe_dir = 0, argv[1]
            for each_file in ['nginx.conf', 'packages', 'packages/deb_amd64', 'packages/deb_i386']:
                if isfile(join(exe_dir, each_file)) or isdir(join(exe_dir, each_file)):
                    x = x + 1
            try:
                x = x+getfileSummary(join(exe_dir, 'packages/deb_amd64'), '\w+.deb$')[0]+getfileSummary(join(exe_dir, 'packages/deb_i386'), '\w+.deb$')[0]+getfileSummary(join(exe_dir, 'packages'), '\w+.tar.gz$')[0]
            except:
                raise SyntaxError
            if x != 34:
                raise SyntaxError
            print "%s\t%34s\033[0;32m %s \033[0m]" % (" * Check currently path is effective", "[", "OK")
        else:
            raise ImportError
    except SyntaxError:
        print "\033[0;31mERROR: Currently path is not allow to execute script.\033[0m"
        raise SystemExit(12)
    except ImportError:
        print 'Usage: python checkCurrentdir.py $PWD'
