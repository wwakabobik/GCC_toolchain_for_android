#!/bin/bash

source  %path_file_path%

export DISPLAY=$(ps x | grep `whoami` | grep 'Xvnc' | grep `hostname` | sed -e 's/\(.*\)\(['`hostname`':].*\)\((.*\)/\2/')

version=$1
device_in=$2
cur_date=$3
export ANDROID_SERIAL=$device_in

hour=`date +%H`
hour=${hour//0} #remove leading zero

if [ "$cur_date" == ""  ]; then
if  [[ "$hour" -le 14 ]]; then
    cur_date=`date +%Y%m%d -d "yesterday"`
  else
    cur_date=`date +%Y%m%d`
fi
fi


NDKPath=$localDirNDK
testResults="$testResults/Devices"
resPath=$testResults/$cur_date/$device_in/$version
mkdir -p $resPath
chmod 777 $testResults/$cur_date
chmod 777 $testResults/$cur_date/$device_in
chmod 777 $resPath


device=`adb devices | grep $device_in | sed -e 's/[\t].*//g'`
echo "Found Phone is : $device"
    
if [ "$device_in" == "$device" ]; then
export ANDROID_SERIAL="$device_in"
    echo " "
    echo "Launch tests for device:"
    echo " env|grep ANDROID = "
    echo     `env | grep ANDROID`
    echo " " 
    sleep 5
    cd $NDKPath/$cur_date-linux/android-ndk-$cur_date-$cur_date/tests
    echo "$NDKPath/$cur_date-linux/android-ndk-$cur_date-$cur_date/tests"
    NDK_TOOLCHAIN_VERSION=$version timeout 400 ./run-tests.sh  --abi=x86 --continue-on-build-fail --full  >> $resPath/NDK_linux_tests_$version.log
    NDK_TOOLCHAIN_VERSION=$version timeout 400 ./run-tests.sh --verbose --verbose --verbose --abi=x86 --continue-on-build-fail --full  >> $resPath/NDK_linux_tests_verbosed_$version.log
else
    echo " "
    echo "###############################"
    echo "# Phone(medfield) not found   #"
    echo "###############################"
    echo " "
fi



