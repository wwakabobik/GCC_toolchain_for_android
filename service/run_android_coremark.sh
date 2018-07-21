#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    run_android_coremark.sh
# Purpose: This script runs coremark testsuite on Android devices. You should
#          specify proper device, NDK, compiler version and platform. You should
#          have android board configured for coremark before run!
#
# Author:      Iliya Vereshchagin
#
# Created:     21.02.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

if [ -z $1 ]; then
    echo "NDK folder is not specified, aborted"
    exit -1
else
    if [ -d $1 ]; then
        NDK_dir=$1
    else
        "Wrong NDK folder specified, aborted"
        exit -1
    fi
fi

if [ -z $2 ]; then
    echo "No arch specified, aborted"
    exit -1
else
    if [ "$2" == "x86" ]; then
        ndk_arch="x86"
        compiler_arch="x86"
        binary="i686-linux-android"
        libs_alias="x86"
        if [ -z $ANDROID_SERIAL ]; then
            ANDROID_SERIAL="MedfieldB12636D7" #Medfield
            #ANDROID_SERIAL="Medfield2D7DC688" #CloverTrail
        fi
    elif [ "$2" == "mips" ]; then
        ndk_arch="mips"
        compiler_arch="mipsel-linux-android"
        binary="mipsel-linux-android"
        libs_alias="mips"
    elif [ "$2" == "arm" ]; then
        ndk_arch="arm"
        compiler_arch="arm-linux-androideabi"
        binary="arm-linux-androideabi"
        libs_alias="armeabi"
        if [ -z $ANDROID_SERIAL ]; then
            #ANDROID_SERIAL="0146A0CD1601301E" #GalaxyNexus
            ANDROID_SERIAL="0146AFFC18020012"
        fi
    elif [ "$2" == "arm7" ]; then
        ndk_arch="arm"
        compiler_arch="arm-linux-androideabi"
        binary="arm-linux-androideabi"
        libs_alias="armeabi-v7a"
    else
        echo "Wrong architecture specified, aborted"
        exit -1
    fi
fi

if [ -z $3 ]; then
    echo "Compiler is not specified, aborted"
    exit -1
else
    if [ -d $NDK_dir/toolchains/$compiler_arch-$3 ]; then
        NDK_binary="$NDK_dir/toolchains/$compiler_arch-$3/prebuilt/linux-x86/bin/$binary-gcc --sysroot=$NDK_dir/platforms/android-9/arch-$ndk_arch"
    else
        "Wrong compiler version specified, aborted"
        exit -1
    fi
fi

cur_date=`date +%d`
cur_date=$cur_date/`date +%m`
cur_date=$cur_date/`date +%Y`

cur_date_for_write=`date +%Y`_`date +%m`_`date +%d`

PORT_DIR="android"

export PORT_DIR
export NDK_binary
export ANDROID_SERIAL

adb -s $ANDROID_SERIAL shell "echo 42" 1>/dev/null 2>/dev/null
if [ $? != 0 ]; then
    "Wrong device specified, aborted"
    exit -1
fi

override_compiler=1
if [ $override_compiler ]; then
    COMPILER_VERSION="NDK $3 $2"
    cat >android/core_portme_android.h <<EOF
#ifndef __CORE_PORTME_ANDROID__
#define __CORE_PORTME_ANDROID__

#define COMPILER_VERSION "$COMPILER_VERSION"

#endif /* __CORE_PORTME_ANDROID__ */
EOF
else
    cat /dev/null >android/core_portme_android.h
fi

echo "proceeding Coremark test for Android $2 $3..."

results_dir="results"

make clean >$results_dir/coremark_$2\_$3\_$cur_date_for_write.log && make >>$results_dir/coremark_$2\_$3\_$cur_date_for_write.log
rm android/core_portme_android.h
mv run1.log $results_dir/run1_$2\_$3\_$cur_date_for_write.log
mv run2.log $results_dir/run2_$2\_$3\_$cur_date_for_write.log
mv coremark.exe $results_dir/coremark_$2\_$3.exe

echo "completed, you can find results in: "
echo "  $results_dir/run1_$2_$3_$cur_date_for_write.log"
echo "  $results_dir/run2_$2_$3_$cur_date_for_write.log"
echo "for build messages refer to $results_dir/coremark_$2_$3_$cur_date_for_write.log"
