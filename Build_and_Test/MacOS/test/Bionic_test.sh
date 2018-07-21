#!/bin/bash

source  %path_file_path%

export ANDROID_SERIAL=emulator-5554
export DISPLAY=$(ps x | grep `whoami` | grep 'Xvnc' | grep `hostname` | sed -e 's/\(.*\)\(['`hostname`':].*\)\((.*\)/\2/')

version=$1
hour=`date +%H`

cur_date_=`date +%Y%m%d `
testResults="$testResults/Bionic"
resPath="$testResults/$cur_date_/$version"
mkdir -p $resPath
device="0"
device=`adb devices | grep emulator-5554 | sed -e 's/[\t].*//g'`
echo "Found emulator is : $device"

cd $androidExternal

##Build Tests##
. build/envsetup.sh >> $resPath/linux_bionic_tests_build_$version.log
lunch full_x86-eng >> $resPath/linux_bionic_tests_build_$version.log
make -j8 no-elf-hash-table-library bionic-unit-tests bionic-unit-tests-static  TARGET_TOOLS_PREFIX=ndk/toolchains/x86-$version/prebuilt/linux-x86/bin/i686-linux-android-  1>$resPath/linux_bionic_tests_build_$version.log 2>&1
##Run Static Tests##


##Run Dynamic Tests if phone is alive##
if [ "emulator-5554" == "$device" ]; then
export ANDROID_SERIAL="$device"
    echo " "
    echo "Launch tests for phone"
    echo " env|grep ANDROID = "
    echo     `env | grep ANDROID`
    echo " " 
    sleep 5
    ##Run Dynamic Tests##
    adb push  out/target/product/generic_x86/data/nativetest/bionic-unit-tests-static/bionic-unit-tests-static /data
    adb push /users/abantonx/AndroidBuild/repos/1028/external/out/target/product/generic_x86/system/lib/no-elf-hash-table-library.so /data/
    adb shell "EXTERNAL_STORAGE=/tmp /data/bionic-unit-tests-static" >> $resPath/linux_bionic_tests_static_$version.log
    adb push out/target/product/generic_x86/data/nativetest/bionic-unit-tests/bionic-unit-tests /data
    adb shell "LD_LIBRARY_PATH=/data EXTERNAL_STORAGE=/tmp /data/bionic-unit-tests" > $resPath/linux_bionic_tests_dynamic_$version.log
else
    echo " "
    echo "###############################"
    echo "# Phone(medfield) not found   #"
    echo "###############################"
    echo " "
fi



