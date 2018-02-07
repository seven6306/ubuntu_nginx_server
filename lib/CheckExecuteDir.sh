#!/bin/bash
CheckExecuteDir()
{
    # check currently execute directory
    [ ! -d ${exe_path}/packages -a ! -d ${exe_path}/packages/deb_amd64 ] && return 0
    [ ! -f ${exe_path}/nginx.conf ] && return 0
    [ `ls ${exe_path}/packages | grep -cE *.tar.gz` -lt 4 ] && return 0
    [ `ls ${exe_path}/packages/deb_amd64 | grep -cE *.deb` -lt 13 ] && return 0
    [ `ls ${exe_path}/packages/deb_i386 | grep -cE *.deb` -lt 13 ] && return 0
    return 1
}
