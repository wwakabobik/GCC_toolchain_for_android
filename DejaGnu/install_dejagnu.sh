#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    install_dejagnu.sh
# Purpose: this script install local copy of DejaGnu including bridge method
#          provided by patch into specifyed folder.
#
# Author:      Iliya Vereshchagin
#
# Created:     30.10.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------

if [ -z $1 ]; then
    echo "no install_dir specified, will be used default"
    install_dir=$PWD/DejaGnu
else
    install_dir=$1
fi

if [ ! -d $install_dir ]; then
    mkdir -p $install_dir
fi

rootme=$PWD

cd $install_dir
git clone git://git.sv.gnu.org/dejagnu.git
if [ $? != 0 ]; then
    git clone git://repo.or.cz/dejagnu.git
fi
if [ $? != 0 ]; then
    echo "dejagnu git repos unavaliable, aborted"
    exit -1
fi

cd dejagnu 
mkdir ../lib && mkdir ../install && mkdir ../share && mkdir ../bin
./configure --prefix=$install_dir/install --bindir=$install_dir/bin --sbindir=$install_dir/bin --libexecdir=$install_dir/bin --libdir=$install_dir/lib --datadir=$install_dir/share
make && make install
if [ $? == 0 ]; then
    rc=0
else
    rc=-1
fi
cd $rootme

exit $rc
