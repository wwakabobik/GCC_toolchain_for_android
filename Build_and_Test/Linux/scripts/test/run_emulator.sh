#!/bin/bash

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi
source $baseDir/scripts/path.sh

SDKDir="${rootDir}/SDK/adt-bundle-linux-x86_64/sdk"
export ANDROID_SDK_HOME=${rootDir}/SDK

if [ -z $1 ] ; then
	echo "Example: $0 4.7 20130703 64"
	exit 1
fi

version=$1
if [ -z $version ] ; then
    echo "Compiler version doesn't specified! Setup it as first argument"
    exit 1
fi
cur_date=$2
hour=`date +%_H`

DISPLAY=$(ps x | grep $USER | grep 'Xvnc' | grep $HOSTNAME | awk '{print $8}' | cut -d: -f2)
if [ -z $DISPLAY ] ; then
    echo "VNC server isn't runned! Running..."
    ~/.vnc/startvnc
    DISPLAY=$(ps x | grep $USER | grep 'Xvnc' | grep $HOSTNAME | awk '{print $8}' | cut -d: -f2)
fi
export DISPLAY=":$DISPLAY"

if [ -z $cur_date ]; then
if  [[ "$hour" -le 14 ]]; then
    echo "test1"
      cur_date=`date +%Y%m%d -d "yesterday"`
    else
        echo "test2"
      cur_date=`date +%Y%m%d`
fi
fi

if [[ $version == 4.4.3 ]] ; then
	echo "Copying emulator  $localDir/${cur_date}_4.6/AOSP_32/ to $SDKDir/system-images/android-17/x86..."
	cp $localDir/${cur_date}_4.6/AOSP_32/* $SDKDir/system-images/android-17/x86/
else
    echo "Copying emulator  $localDir/${cur_date}_${version}/AOSP_32/ to $SDKDir/system-images/android-17/x86..."
#    cp $localDir/${cur_date}_${version}/AOSP_32/* $SDKDir/system-images/android-17/x86/
fi

echo "Run emulator..."

/users/${USER}/AndroidTesting/repositories/AOSP/out/host/linux-x86/bin/emulator-x86  -avd x86 -noaudio -verbose -no-audio -gpu off \
-kernel $baseDir/repositories/AOSP/prebuilts/qemu-kernel/x86/kernel-qemu \
-system $baseDir/builds/images/${cur_date}_${version}/AOSP_32/system.img \
-ramdisk $baseDir/builds/images/${cur_date}_${version}/AOSP_32/ramdisk.img \
-data $baseDir/builds/images/${cur_date}_${version}/AOSP_32/userdata.img \
-sdcard $baseDir/scripts/test/emulatorSD.img \
-qemu -enable-kvm




echo "pid=$pid"

bit=$3

exit 0

