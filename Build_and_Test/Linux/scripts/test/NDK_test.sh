#!/bin/bash

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi
source $baseDir/scripts/path.sh

DISPLAY=$(ps x | grep $USER | grep 'Xvnc' | grep $HOSTNAME | awk '{print $8}' | cut -d: -f2)
if [ -z $DISPLAY ] ; then
    echo "VNC server isn't runned! Running..."
    ~/.vnc/startvnc
    DISPLAY=$(ps x | grep $USER | grep 'Xvnc' | grep $HOSTNAME | awk '{print $8}' | cut -d: -f2)
fi
export DISPLAY=":$DISPLAY"

export ANDROID_SERIAL=$2
if [ -z $ANDROID_SERIAL ] ; then
    echo "Device serial doesn't specified! Setup it as second argument"
    exit 1
fi
if [ "$ANDROID_SERIAL" == 0146AFFC18020012 ] ; then
    abi="armeabi-v7a"
else
    abi="x86"
fi

cur_date=$3
if [ -z $cur_date ]; then
    hour=`date +%_H`
    if  [[ "$hour" -le 14 ]]; then
        cur_date=`date +%Y%m%d -d "yesterday"`
    else
        cur_date=`date +%Y%m%d`
    fi
fi

version=$1
NDKPath=$localDirNDK
testResults="$testResults/Devices"
resPath=$testResults/$cur_date/$ANDROID_SERIAL/$version
if [ -z $version ] ; then
    echo "Compiler version doesn't specified! Setup it as first argument"
    exit 1
elif [[ $version == 4.9 ]] && [[ $4 != 64 ]] ; then
	echo "Preparing 4.9 32bit..."
	if  [ ! -d $baseDir/builds/ndk/$cur_date-linux-32/android-ndk-$cur_date-$cur_date ] ; then
		tar xjf $baseDir/builds/ndk/$cur_date-linux-32/android-ndk-$cur_date-$cur_date-linux-x86.tar.bz2 -C $baseDir/builds/ndk/$cur_date-linux-32/
	fi
	
	if [[ $abi == x86 ]] ; then
	    cp $baseDir/scripts/test/config_x86_4.9.mk $NDKPath/$cur_date-linux-32/android-ndk-$cur_date-$cur_date/toolchains/x86-4.9/config.mk
	    cp $baseDir/scripts/test/setup_x86_4.9.mk $NDKPath/$cur_date-linux-32/android-ndk-$cur_date-$cur_date/toolchains/x86-4.9/setup.mk
	else
	    cp $baseDir/scripts/test/config_arm_4.9.mk $NDKPath/$cur_date-linux-32/android-ndk-$cur_date-$cur_date/toolchains/arm-linux-androideabi-4.9/config.mk
	    cp $baseDir/scripts/test/setup_arm_4.9.mk $NDKPath/$cur_date-linux-32/android-ndk-$cur_date-$cur_date/toolchains/arm-linux-androideabi-4.9/setup.mk
	fi
	cd $NDKPath/$cur_date-linux-32/android-ndk-$cur_date-$cur_date/tests
    export FOO_PATH=$NDKPath/$cur_date-linux-32/android-ndk-$cur_date-$cur_date/tests/build/absolute-src-file-paths
    echo "$NDKPath/$cur_date-linux-32/android-ndk-$cur_date-$cur_date/tests"

	# 64 bit
elif [[ $4 == 64 ]] ; then
	echo "Preparing 64bit..."
	resPath=$testResults/${cur_date}_64/$ANDROID_SERIAL/$version
	echo "$NDKPath/$cur_date-linux-64/android-ndk-$cur_date-$cur_date/tests"
	if  [ ! -d $baseDir/builds/ndk/$cur_date-linux-64/android-ndk-$cur_date-$cur_date ]; then
	    tar xjf $baseDir/builds/ndk/$cur_date-linux-64/android-ndk-$cur_date-$cur_date-linux-x86_64.tar.bz2 -C $baseDir/builds/ndk/$cur_date-linux-64/
	fi
	
	if [[ $version == 4.9 ]] ; then
		echo "Preparing 4.9 64bit..."
	    if [[ $abi == x86 ]] ; then
		NDK_copy_path=$NDKPath/$cur_date-linux-64/android-ndk-$cur_date-$cur_date"/toolchains/x86-4.9"
	        cp $baseDir/scripts/test/config_x86_4.9.mk $NDK_copy_path/config.mk
	        cp $baseDir/scripts/test/setup_x86_4.9.mk $NDK_copy_path/setup.mk
	    else
	    	NDK_copy_path=$NDKPath/$cur_date-linux-64/android-ndk-$cur_date-$cur_date"/toolchains/arm-linux-androideabi-4.9/"
	        cp $baseDir/scripts/test/config_arm_4.9.mk $NDK_copy_path/config.mk
	        cp $baseDir/scripts/test/setup_arm_4.9.mk  $NDK_copy_path/setup.mk #$ NDKPath/$cur_date-linux-64/android-ndk-$cur_date-$cur_date/toolchains/arm-linux-androideabi-4.9/setup.mk
	    fi
	fi
    cd $NDKPath/$cur_date-linux-64/android-ndk-$cur_date-$cur_date/tests
    export FOO_PATH=$NDKPath/$cur_date-linux-64/android-ndk-$cur_date-$cur_date/tests/build/absolute-src-file-paths
    echo "$NDKPath/$cur_date-linux-64/android-ndk-$cur_date-$cur_date/tests"
else
	echo "Preparing 32bit..."
	cd $NDKPath/$cur_date-linux-32/android-ndk-$cur_date-$cur_date/tests
	export FOO_PATH=$NDKPath/$cur_date-linux-32/android-ndk-$cur_date-$cur_date/tests/build/absolute-src-file-paths
	echo "$NDKPath/$cur_date-linux/android-ndk-$cur_date-$cur_date/tests"
fi

mkdir -p $resPath
chmod 777 $testResults/$cur_date
chmod 777 $testResults/$cur_date/$ANDROID_SERIAL
chmod 777 $resPath

device="$(adb devices | grep $ANDROID_SERIAL)"
echo "Found Phone is : $device"
if [[ "$device" =~ "device" ]] ; then
	echo "Starting NDK tests..."
	if [[ $4 == 64 ]]; then 
	    bit32=0
	else
	    bit32=1
	fi    
	
NDK_HOST_32BIT=$bit32   NDK_TOOLCHAIN_VERSION=$version timeout 900 ./run-tests.sh --abi=$abi --continue-on-build-fail --full  > $resPath/${cur_date}_${version}_${abi}_NDK_linux_tests.log
NDK_HOST_32BIT=$bit32   TARGET_ABI_SUBDIR="x86" NDK_TOOLCHAIN_VERSION=$version timeout 900 ./run-tests.sh --verbose --verbose --verbose --abi=$abi --continue-on-build-fail --full  > $resPath/${cur_date}_${version}_${abi}_NDK_linux_tests_verbosed.log
	echo "See results in $resPath"
else
    echo "Device $ANDROID_SERIAL not found or offline!"
fi

exit 0

