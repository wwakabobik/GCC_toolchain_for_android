#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    collect_android_profile.sh
# Purpose: This script collects profile data from Android devices.
#
# Author:      Iliya Vereshchagin
#
# Created:     21.02.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

if [ ! `which adb` ]; then
    echo "No adb found, aborted"
    exit -1
fi

if [ ! -z $1 ]; then
    if [ $1 == 1 ]; then
        post_perf=1;
    else
        post_perf=0;
    fi
else
    post_perf=0;
fi

if [ -z $2 ]; then
    binary="coremark.exe"
else
    binary=$2
fi

if [ -z $3 ]; then
    params=""
else
    params=$3
fi

if [ -z $4 ]; then
    rootme=$PWD
else
    rootme=$4
fi

if [ -z $5 ]; then
    perf_name="perf"
else
    perf_name=$5
fi

if [ -z $6 ]; then
    if [ -z $ANDROID_SERIAL ]; then
        adb shell "exit 0"
        if [ $? != 0 ]; then
            echo "No device specified, aborted"
            exit -1
        fi
    fi
else
    ANDROID_SERIAL=$6
fi

profile_script="android_profile.sh"

if [ ! -f $profile_script ]; then
    "native script missed, aborted"
    exit -1
fi

cur_date=`date +%d`
cur_date=$cur_date/`date +%m`
cur_date=$cur_date/`date +%Y`

cur_date_for_write=`date +%Y`_`date +%m`_`date +%d`

export PATH=$rootme:.:/nfs/ims/proj/icl/gcc_cw/ARM/bin:$PATH

device_folder=/data/local/`whoami`/profile

adb shell "mkdir -p $device_folder"
adb push $binary $device_folder/$binary
adb push $profile_script $device_folder/$profile_script
adb shell "chmod 777 $device_folder/$profile_script"
adb shell "chmod 777 $device_folder/$binary"
if [ $post_perf == 1 ]; then
    adb push `which perf` $device_folder/$perf_name
    adb shell "chmod 777 $device_folder/$perf_name"
fi
adb shell "cd $device_folder && $device_folder/$profile_script $binary $params $device_folder $device_folder $device_folder"
adb pull $device_folder/$binary\_$cur_date_for_write.log
adb pull $device_folder/$binary\_$cur_date_for_write\_perf.log
