#!/bin/bash
source  %path_file_path%

version=$1
cur_date=$2
hour=`date +%H`
hour=${hour//0} #remove leading zero

if [ "$cur_date" == ""  ]; then
if  [[ "$hour" -le 14 ]]; then
    echo "test1"
      cur_date=`date +%Y%m%d -d "yesterday"`
    else
        echo "test2"
      cur_date=`date +%Y%m%d`
fi
fi


cp -rf $localDir/${cur_date}_${version}/AOSP/* $SDKDir/system-images/android-17/x86/

$SDKDir/tools/emulator -avd x86 -sdcard emulatorSD.img &
pid=$!

sleep 30
./NDK_test.sh $version emulator-5554 $cur_date
sleep 5

#kill $pid
echo "test"
