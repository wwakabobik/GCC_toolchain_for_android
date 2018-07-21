#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    check_dejagnu.sh
# Purpose: this script will update local copy of dejagnu by demand for bridge
#          ndk testing methodology. Script uses pre-defined dejagnu local
#          delivery script.
#
# Author:      Iliya Vereshchagin
#
# Created:     30.10.2012
# Copyright:   (c) Ilya Vereshchagin 2012
# Licence:     GPL
#-------------------------------------------------------------------------------

if [ -z $1 ]; then
    echo " dejagnu will be updated by default"
    update_needed=1
else
    update_needed=$1
fi

if [ $update_needed != 1 ]; then
    exit 0
fi

if [ -z $2 ]; then
    echo " DejaGnu folder not specified, will be used default"
    dejagnu_folder="DejaGnu"
else
    dejagnu_folder=$2
fi

if [ -z $3 ]; then
    rootme=$PWD
else
    rootme=$3
fi

if [ -z $4 ]; then
    script_folder=$rootme
else
    script_folder=$4
fi

if [ ! -d  $dejagnu_folder ]; then
    mkdir -p $dejagnu_folder
    cd $dejagnu_folder
else
    cd $dejagnu_folder
    rm -r * 1>/dev/null 2>/dev/null
fi

if [ -f $script_folder/install_dejagnu.sh ] && [ -f $script_folder/dejagnu.patch ]; then
    cp -f $script_folder/install_dejagnu.sh ./install_dejagnu.sh
    cp -f $script_folder/dejagnu.patch ./dejagnu.patch
else
    cd $rootme
    exit -1
fi

abort=0

./install_dejagnu.sh $PWD 1>/dev/null 2>/dev/null

if [ $? != 0 ]; then
    #installation compromised
    abort=$?
fi

rm -f ./install_dejagnu.sh 1>/dev/null 2>/dev/null
rm -f ./dejagnu.patch 1>/dev/null 2>/dev/null
rm -rf ./dejagnu 1>/dev/null 2>/dev/null

cd $rootme

if [ $abort == 0 ]; then
    echo " DejaGnu was updated to most recent version"
    exit 0
else
    exit -1
fi