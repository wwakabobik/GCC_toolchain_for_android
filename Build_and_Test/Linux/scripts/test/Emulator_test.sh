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
bit=$3

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
	echo "Copying emulator  $localDir/${cur_date}_4.6/AOSP_$bit/ to $SDKDir/system-images/android-17/x86..."
	cp $localDir/${cur_date}_4.6/AOSP_$bit/* $SDKDir/system-images/android-17/x86/
else
    echo "Copying emulator  $localDir/${cur_date}_${version}/AOSP_$bit/ to $SDKDir/system-images/android-17/x86..."
    cp $localDir/${cur_date}_${version}/AOSP_$bit/* $SDKDir/system-images/android-17/x86/
fi

echo "Run emulator..."


/users/${USER}/AndroidTesting/repositories/AOSP/out/host/linux-x86/bin/emulator-x86  -avd x86 -noaudio  -no-audio -gpu off -no-window \
-kernel $baseDir/repositories/AOSP/prebuilts/qemu-kernel/x86/kernel-qemu \
-system $baseDir/builds/images/${cur_date}_${version}/AOSP_$bit/system.img \
-ramdisk $baseDir/builds/images/${cur_date}_${version}/AOSP_$bit/ramdisk.img \
-data $baseDir/builds/images/${cur_date}_${version}/AOSP_$bit/userdata.img \
-sdcard $baseDir/scripts/test/emulatorSD.img  -no-window & pid=$!

echo "pid=$pid"


sleep 90
echo "Run NDK tests..."
NDK_test.sh $version emulator-5554 $cur_date $bit
if [[ $bit == "64" ]] ; then
	parse_NDK_test_log.sh ${version} emulator-5554 ${cur_date}_$bit
else
	parse_NDK_test_log.sh ${version} emulator-5554 ${cur_date}
fi

sleep 60
echo "Run Bionic tests..."

./Bionic_test.sh ${version} $bit

echo "Bionic tests finished"
sleep 20

kill -15 $pid
echo "emulator stopped"

exit 0

