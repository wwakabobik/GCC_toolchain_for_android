#!/bin/bash
if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi
source  $baseDir/scripts/path.sh

export ANDROID_SERIAL=emulator-5554
DISPLAY=$(ps x | grep $USER | grep 'Xvnc' | grep $HOSTNAME | awk '{print $8}' | cut -d: -f2)
if [ -z $DISPLAY ] ; then
    echo "VNC server isn't runned! Running..."
    ~/.vnc/startvnc
    DISPLAY=$(ps x | grep $USER | grep 'Xvnc' | grep $HOSTNAME | awk '{print $8}' | cut -d: -f2)
fi
export DISPLAY=":$DISPLAY"

version=$1
bit=$2

if [ -z $version ] ; then
    echo "Compiler version doesn't specified! Setup it as first argument"
    exit 1
fi

hour=`date +%_H`
if [ -z $cur_date ]; then
if  [[ "$hour" -le 16 ]]; then
    cur_date=`date +%Y%m%d -d "yesterday"`
    else
    cur_date=`date +%Y%m%d`
fi
fi

testResults="$testResults/Bionic"
resPath="$testResults/${cur_date}_$version"
mkdir -p $resPath
device="0"
device=`adb devices | grep emulator-5554 | sed -e 's/[\t].*//g'`
echo "Found emulator is : $device"

cd $androidExternal

if [[ $bit == 64 ]]; then
    bitcp="_"$bit
    echo "$bit"
    else
    bitcp=""
fi

#exit 0;
##Build Tests##
. build/envsetup.sh >> $resPath/linux_bionic_tests_build_$version$bit.log
lunch full_x86-eng >> $resPath/linux_bionic_tests_build_$version$bit.log
make clean
make -j8 no-elf-hash-table-library bionic-unit-tests bionic-unit-tests-static  TARGET_TOOLS_PREFIX=ndk/toolchains/x86-$version/prebuilt/linux-x86$bitcp/bin/i686-linux-android-  1>$resPath/linux_bionic_tests_build_$version$bit.log 2>&1
##Run Static Tests##




##Run Dynamic Tests if phone is alive##
if [ "emulator-5554" == "$device" ]; then
	export ANDROID_SERIAL="$device"
    echo
    echo "Launch tests for phone"
    echo " env|grep ANDROID = "
    echo     `env | grep ANDROID`
    echo
    sleep 5
    ##Run Dynamic Tests##
    adb push out/target/product/generic_x86/data/nativetest/bionic-unit-tests-static/bionic-unit-tests-static /data
    adb push ${androidExternal}/out/target/product/generic_x86/system/lib/no-elf-hash-table-library.so /data/
    adb shell "EXTERNAL_STORAGE=/tmp /data/bionic-unit-tests-static" >> $resPath/linux_bionic_tests_static_$version$bit.log
    adb push out/target/product/generic_x86/data/nativetest/bionic-unit-tests/bionic-unit-tests /data
    adb shell "LD_LIBRARY_PATH=/data EXTERNAL_STORAGE=/tmp /data/bionic-unit-tests" > $resPath/linux_bionic_tests_dynamic_$version$bit.log
else
    echo "Device $ANDROID_SERIAL not found!"
fi

exit 0

