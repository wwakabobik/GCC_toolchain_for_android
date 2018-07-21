#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    prepare_patches.sh
# Purpose: this script prepares patches based on two parts - modified dejagnu
#          files and new files. This scripts generates proper git diff combined
#          from diff and new files.
#
# Author:      Iliya Vereshchagin
#
# Created:     19.11.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------

rootme=$PWD

if [ -z $1 ]; then
    source_folder=$rootme
else
    source_folder=$1
fi

if [ -z $2 ]; then
    dest_folder=$rootme/DejaGnu
else
    dest_folder=$2
fi

if [ ! -d $dest_folder/dejagnu ]; then
    echo "wrong destination specified!"
    exit -1
fi

if [ ! -f $source_folder/dejagnu_sources.patch ]; then
    #it's bad, we have no preparations here, try to obtain smthn
    cd $dest_folder/dejagnu
    git diff >$source_folder/dejagnu_sources.patch
    git apply -R $source_folder/dejagnu_sources.patch
    cd $rootme
    #we should hope that's ok and do not do revert
fi

if [ ! -f $source_folder/bridge.exp ]; then
    #panic! try to copy from dest
    cp $dest_folder/dejagnu/lib/bridge.exp $source_folder/bridge.exp
    if [ $? != 0 ]; then
	echo "no input files, therefore no sence to do anything"
    fi
    cd $dest_folder/dejagnu
    git rm -f lib/bridge.exp
    cd $rootme
fi

if [ ! -f $source_folder/exec.sh ]; then
    #panic! try to copy from dest
    cp $dest_folder/dejagnu/exec.sh $source_folder/exec.sh
    if [ $? != 0 ]; then
	echo "no input files, therefore no sence to do anything"
    fi
    cd $dest_folder/dejagnu
    git rm -f exec.sh
    cd $rootme
fi

#paranoid revert
cd $dest_folder/dejagnu
git apply -R $source_folder/dejagnu_sources.patch 1>/dev/null 2>/dev/null
git rm -f exec.sh 1>/dev/null 2>/dev/null
git rm -f lib/bridge.exp 1>/dev/null 2>/dev/null
rm -f exec.sh 1>/dev/null 2>/dev/null
rm -f lib/bridge.exp 1>/dev/null 2>/dev/null
git apply --whitespace=nowarn $source_folder/dejagnu_sources.patch 1>/dev/null 2>/dev/null
if [ $? != 0 ]; then
    echo "previous patch corrupt, aborted"
    exit -1
fi
#start update any file from source
cp $source_folder/bridge.exp $dest_folder/dejagnu/lib/bridge.exp 1>/dev/null 2>/dev/null
cp $source_folder/exec.sh $dest_folder/dejagnu/exec.sh 1>/dev/null 2>/dev/null
#ignore if no input
#or copy modified files directly
cp $source_folder/unix.exp $dest_folder/dejagnu/baseboards/unix.exp 1>/dev/null 2>/dev/null
cp $source_folder/framework.exp $dest_folder/dejagnu/lib/framework.exp 1>/dev/null 2>/dev/null
cp $source_folder/remote.exp $dest_folder/dejagnu/lib/remote.exp 1>/dev/null 2>/dev/null
cp $source_folder/dg.exp $dest_folder/dejagnu/lib/dg.exp 1>/dev/null 2>/dev/null
cp $source_folder/Makefile.am $dest_folder/dejagnu/Makefile.am 1>/dev/null 2>/dev/null
cp $source_folder/Makefile.in $dest_folder/dejagnu/Makefile.in 1>/dev/null 2>/dev/null
cp $source_folder/runtest.exp $dest_folder/dejagnu/runtest.exp 1>/dev/null 2>/dev/null
#we should assume on worst case, update revert patch
cd $dest_folder/dejagnu
git diff >$source_folder/dejagnu_sources.patch
git add exec.sh 1>/dev/null 2>/dev/null
git add lib/bridge.exp 1>/dev/null 2>/dev/null
git diff >$rootme/dejagnu.patch && git diff --cached >>$rootme/dejagnu.patch
#ok, now cleanup
git apply -R $source_folder/dejagnu_sources.patch 1>/dev/null 2>/dev/null
git rm -f exec.sh 1>/dev/null 2>/dev/null
git rm -f lib/bridge.exp 1>/dev/null 2>/dev/null
rm -f exec.sh 1>/dev/null 2>/dev/null
rm -f lib/bridge.exp 1>/dev/null 2>/dev/null
#total cleanup, do not remain this temp
#for further usage, update dejagnu_sources.patch
cp -f $rootme/dejagnu.patch $source_folder/dejagnu_sources.patch 1>/dev/null 2>/dev/null
cd $rootme