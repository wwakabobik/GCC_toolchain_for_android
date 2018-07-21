#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    Make_Check_Android.sh
# Purpose: main configuration and test script for ndk compilers make check,
#          using gcc testsuite, for test_installed via adb method, which contains
#          integral setup of Android enviroment, call child scripts and saving results
#
# Author:      Iliya Vereshchagin
#
# Created:     25.10.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------

build_folder=$1
rootme=$PWD
y=`basename $0`
$ndebug echo "$y started with parameters:"
$ndebug echo "   $1"
$ndebug echo "   $2"
$ndebug echo "   $3  $4  $5  $6  $7  $8  $9"
#Check parameters
$ndebug echo " current folder: $rootme"
#Check for requested sources
if [ ! -d $1 ]; then
   echo " source folder missed, aborting!"
   exit -1
fi
#Check destination
if [ -z $2 ]; then
    echo " destination is not specified, use default"
    dest_folder=$rootme
else
    dest_folder=$2
fi

#Check NDK
if [ -z $3 ]; then
    echo " NDK folder is not specified, use default"
    ndk_dir="NDK_current"
else
    ndk_dir=$3
fi

#Check device
if [ -z $4 ]; then
    ADB_DEVICE="MedfieldE906493B"
    echo " No adb device specified, will be use default $ADB_DEVICE"
else
    ADB_DEVICE=$4
fi
adb devices | grep $ADB_DEVICE $debug 1>/dev/null 2>/dev/null
if [ $? != 0 ]; then
    echo "$ADB_DEVICE is not found, aborted"
    exit -1
fi

if [ -z $5 ]; then
    compiler="4.7"
    echo " No compiler specified, will be used $compiler"
else
    compiler=$5
fi

if [ -z $6 ]; then
    test_arch="x86"
    echo " No architecture specified, will be used $test_arch"
else
    test_arch=$6
fi

if [ -z $7 ]; then
    platform="9"
    echo " No platform specified, will be used $platform"
else
    platform=$7
fi

if [ -z $8 ]; then
    rooted=1 #device rooted - can we call su and mount for system, is /data accessable? 1 - rooted, 0 - not rooted
else
    rooted=$8
fi

if [ -z $9 ]; then
    device_alias=""
else
    device_alias=$9
fi

if [ -z ${10} ]; then
    bits=32
else
    bits=${10}
fi

$ndebug echo "$y: compiler=$compiler"

compiler_for_file=`echo $compiler |  sed -e 's/[.]//g'`
$ndebug echo "$y: compiler_for_file=$compiler_for_file"

missing_rsrc=""
rsrc="Android_MC_Bridge.sh"
if [ ! -f "$rsrc" ]; then
  missing_rsrc=$rsrc
fi
rsrc="$dest_folder"
if [ ! -d "$rsrc" ]; then
  missing_rsrc=$rsrc
fi
rsrc="$build_folder/contrib/test_installed"
if [ ! -f "$rsrc" ]; then
  missing_rsrc=$rsrc
fi
rsrc="$rootme/$ndk_dir"
if [ ! -d "$rsrc" ]; then
  missing_rsrc=$rsrc
fi
if [ ! -z ${missing_rsrc} ]; then
  echo " at least, ${missing_rsrc} IS ABSENT"
  exit -1
fi

#define environment
if [ "$test_arch" == "x86" ]; then
    $ndebug echo " arch is $test_arch"
    ndk_arch="x86"
    compiler_arch="x86"
    binary="i686-linux-android"
    libs_alias="x86"
else
    if [ "$test_arch" == "mips" ]; then
        $ndebug echo " arch is $test_arch"
        ndk_arch="mips"
        compiler_arch="mipsel-linux-android"
        binary="mipsel-linux-android"
        libs_alias="mips"
    else
        if [ "$test_arch" == "arm" ]; then
            $ndebug echo " arch is $test_arch"
            ndk_arch="arm"
            compiler_arch="arm-linux-androideabi"
            binary="arm-linux-androideabi"
            libs_alias="armeabi"
        else
            if [ "$test_arch" == "arm7" ]; then
                $ndebug echo " arch is $test_arch"
                ndk_arch="arm"
                compiler_arch="arm-linux-androideabi"
                binary="arm-linux-androideabi"
                libs_alias="armeabi-v7a"
            else
                if [ "$test_arch" == "x86_64" ]; then
                    $ndebug echo " arch is $test_arch"
                    ndk_arch="x86"
                    compiler_arch="x86_64"
                    binary="x86_64-linux-android"
                    libs_alias="x86"
                else
                    echo "Wrong architecture specified, aborted"
                    exit -1
                fi
            fi
        fi
    fi
fi

if [ ! -f  $rootme/test_installed_adb_bridge_${test_arch}_${device_alias}.patch ]; then
    echo "infrastructure problem: test installed patch missed";
    cd $rootme
    exit -1
fi

#Patch exp and sources
echo "Patching exp and sources in $build_folder"
#echo " patches..."
cd $build_folder
patch -p0 -i $rootme/test_installed_adb_bridge_${test_arch}_${device_alias}.patch --forward $debug 1>/dev/null 2>/dev/null

#apply patches for testsuite
patch -p0 -i $rootme/bridge_gcc_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
patch -p0 -i $rootme/make_check_adb_bridge_united_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null

#echo " temp files..."
#apply temporary patches
#echo " hacks..."
cp -f $rootme/1_target.exp $rootme/$build_folder/gcc/testsuite/g++.dg/pch/1_target.exp $debug 1>/dev/null 2>/dev/null
if [ $test_arch="x86" ]; then
    #patch for 4.6 google compiler, if other version is used, ignore
    cd $rootme/$ndk_dir/toolchains/x86-$compiler/prebuilt/linux-x86/lib/gcc/i686-linux-android/4.6.x-google/include-fixed/sys $debug 1>/dev/null 2>/dev/null
    patch -p0 -i $rootme/types.patch --forward $debug 1>/dev/null 2>/dev/null
fi
cd $rootme

#Set correct permissions
echo "Setting correct permissions"
chmod ug+rw ./Android_MC_Bridge.sh $debug 1>/dev/null 2>/dev/null

#Set correct Android phone environment
echo "Setting phone environment"
if [ -z $device_temp ]; then
    android_temp_dir="/data/local/MC_Temp"
else
    android_temp_dir=$device_temp
fi

adb_command="mount -o remount"

stl_lib_name=""
stl_type=""
if [ -z $android_stl_type ] || [ $android_stl_type == "gnustl" ]; then
    stl_lib_name="libgnustl_shared.so"
    stl_type="gnu-libstdc++/$compiler"
elif [ $android_stl_type == "stlport" ]; then
    stl_lib_name="libstlport_shared.so"
    stl_type=$android_stl_type
elif [ $android_stl_type == "gabi++" ]; then
    stl_lib_name="libgabi++_shared.so"
    stl_type=$android_stl_type
else
    echo "environment variable android_stl_type=\"$android_stl_type\" has wrong value, aborted"
    cd $build_folder
    patch -p0 -R -i $rootme/make_check_adb_bridge_united_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
    patch -p0 -R -i $rootme/bridge_gcc_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
    patch -p0 -R -i $rootme/test_installed_adb_bridge_${test_arch}_${device_alias}.patch --forward $debug 1>/dev/null 2>/dev/null
    cd $rootme
    exit -1
fi

if [ -z $device_disk ]; then
    device_drive="/dev/block/mmcblk0p8"
else
    device_drive=$device_disk
fi

if [ -z $device_fs ]; then
    fs_type="ext4"
else
    fs_type=$device_fs
fi

adb_crash=0
$ndebug echo `which adb`
if [ $rooted ]; then
    adb -s "$ADB_DEVICE" shell "mkdir -p $android_temp_dir" $debug 1>/dev/null 2>/dev/null
    adb -s "$ADB_DEVICE" shell "rm $android_temp_dir/$stl_lib_name" $debug 1>/dev/null 2>/dev/null
    $ndebug echo "$y: adb -s \"$ADB_DEVICE\" push $rootme/$ndk_dir/sources/cxx-stl/$stl_type/libs/$libs_alias/$stl_lib_name $android_temp_dir/$stl_lib_name $debug 1>/dev/null 2>/dev/null"
    adb -s "$ADB_DEVICE" push $rootme/$ndk_dir/sources/cxx-stl/$stl_type/libs/$libs_alias/$stl_lib_name $android_temp_dir/$stl_lib_name $debug 1>/dev/null 2>/dev/null
    if [ $? != 0 ]; then
        ls -la $rootme/$ndk_dir/sources/cxx-stl/$stl_type/ $debug 1>/dev/null 2>/dev/null
        if [ $? != 0 ]; then
            echo "Folder $rootme/$ndk_dir/sources/cxx-stl/$stl_type/  IS ABSENT"
            $ndebug echo "$y: the above push FAILED ! Dropping of the above patches (patch -R):"
            cd $build_folder
            patch -p0 -R -i $rootme/make_check_adb_bridge_united_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
            patch -p0 -R -i $rootme/bridge_gcc_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
            patch -p0 -R -i $rootme/test_installed_adb_bridge_${test_arch}_${device_alias}.patch --forward $debug 1>/dev/null 2>/dev/null
            cd $rootme
            $ndebug echo "$y: abnormal exit"
            echo "adb crashed, aborted"
            cd $rootme
            exit -1
        fi
    fi
    adb -s "$ADB_DEVICE" shell "su -c '$adb_command,rw -t $fs_type $device_drive /system && rm /system/lib/$stl_lib_name && $adb_command,ro -t $fs_type $device_drive /system'" $debug 1>/dev/null 2>/dev/null
    if [ $? != 0 ]; then
        #crashed? try without root
        adb -s "$ADB_DEVICE" shell "$adb_command,rw -t $fs_type $device_drive /system && rm /system/lib/$stl_lib_name && $adb_command,ro -t $fs_type $device_drive /system" $debug 1>/dev/null 2>/dev/null
    fi
    adb -s "$ADB_DEVICE" shell "$adb_command,rw -t $fs_type $device_drive /system && cp $android_temp_dir/$stl_lib_name /system/lib/$stl_lib_name && $adb_command,ro -t $fs_type $device_drive /system" $debug 1>/dev/null 2>/dev/null
    if [ $? != 0 ]; then
        #crashed? try with root
        adb -s "$ADB_DEVICE" shell "su -c '$adb_command,rw -t $fs_type $device_drive /system && cp $android_temp_dir/$stl_lib_name /system/lib/$stl_lib_name && $adb_command,ro -t $fs_type $device_drive /system'" $debug 1>/dev/null 2>/dev/null
        if [ $ != 0 ]; then
            adb_crash=1
        fi
    fi
    adb -s "$ADB_DEVICE" pull /system/lib/$stl_lib_name . $debug 1>/dev/null 2>/dev/null
    if [ $? != 0 ]; then
        adb_crash=1
    fi
    rm ./$stl_lib_name $debug 1>/dev/null 2>/dev/null
    if [ $? != 0 ] || [ $adb_crash == 1 ]; then
        #try once more - create symbolic link
        adb -s "$ADB_DEVICE" shell "su -c '$adb_command,rw -t $fs_type $device_drive /system && ln -s $android_temp_dir/$stl_lib_name /system/lib/$stl_lib_name && $adb_command,ro -t $fs_type $device_drive /system'" $debug 1>/dev/null 2>/dev/null
        if [ $? != 0 ]; then
            #crashed? try without root
            $rootme/adb -s "$ADB_DEVICE" shell "$adb_command,rw -t $fs_type $device_drive /system && ln -s $android_temp_dir/$stl_lib_name /system/lib/$stl_lib_name && $adb_command,ro -t $fs_type $device_drive /system" $debug 1>/dev/null 2>/dev/null
            if [ $? != 0 ]; then
                echo " adb crashed, aborted"
                cd $build_folder
                patch -p0 -R -i $rootme/make_check_adb_bridge_united_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
                patch -p0 -R -i $rootme/bridge_gcc_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
                patch -p0 -R -i $rootme/test_installed_adb_bridge_${test_arch}_${device_alias}.patch --forward $debug 1>/dev/null 2>/dev/null
                cd $rootme
                exit -1
            fi
        fi
        adb -s "$ADB_DEVICE" pull /system/lib/$stl_lib_name . $debug 1>/dev/null 2>/dev/null
        if [ $? != 0 ]; then
            echo " adb crashed, aborted"
            cd $build_folder
            patch -p0 -R -i $rootme/make_check_adb_bridge_united_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
            patch -p0 -R -i $rootme/bridge_gcc_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
            patch -p0 -R -i $rootme/test_installed_adb_bridge_${test_arch}_${device_alias}.patch --forward $debug 1>/dev/null 2>/dev/null
            cd $rootme
            exit -1
        fi
        rm ./$stl_lib_name $debug 1>/dev/null 2>/dev/null
        if [ $? != 0 ]; then
            echo " adb crashed, aborted"
            cd $build_folder
            patch -p0 -R -i $rootme/make_check_adb_bridge_united_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
            patch -p0 -R -i $rootme/bridge_gcc_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
            patch -p0 -R -i $rootme/test_installed_adb_bridge_${test_arch}_${device_alias}.patch --forward $debug 1>/dev/null 2>/dev/null
            cd $rootme
            exit -1
        fi
    fi
fi

#Building
check_error=0
./Android_MC_Bridge.sh $build_folder $rootme $ndk_dir $compiler $platform $ndk_arch $compiler_arch $binary $libs_alias $bits
if [ "$?" != "0" ]; then
    $ndebug echo " Android_MC_Bridge.sh returned NON-ZERO, therefore we talk that checking failed, abort after rollback"
    check_error=1
fi

#Clean up old results
$ndebug echo "Removing old results from destination folder $dest_folder/ANDROID_MAKE_CHECK"
rm -rf $dest_folder/ANDROID_MAKE_CHECK $debug 1>/dev/null 2>/dev/null
rmdir $dest_folder/ANDROID_MAKE_CHECK  $debug 1>/dev/null 2>/dev/null

#Copying
echo "Copying results to the destination folder"
mkdir $dest_folder/ANDROID_MAKE_CHECK $debug 1>/dev/null 2>/dev/null
chmod ug+rw $dest_folder/ANDROID_MAKE_CHECK $debug 1>/dev/null 2>/dev/null

cp -r $build_folder/ANDROID/* $dest_folder/ANDROID_MAKE_CHECK/ $debug 1>/dev/null 2>/dev/null
chmod -R ug+rw $dest_folder/ANDROID_MAKE_CHECK $debug 1>/dev/null 2>/dev/null

#Clean-up
$ndebug echo "Reverse patches"
#echo " patches..."
cd $build_folder
patch -p0 -R -i $rootme/make_check_adb_bridge_united_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
patch -p0 -R -i $rootme/bridge_gcc_$compiler_for_file.patch --forward $debug 1>/dev/null 2>/dev/null
patch -p0 -R -i $rootme/test_installed_adb_bridge_${test_arch}_${device_alias}.patch --forward  $debug 1>/dev/null 2>/dev/null
#revert temporary patches
#echo " hacks..."
rm -f $rootme/$build_folder/gcc/testsuite/g++.dg/pch/1_target.exp $debug 1>/dev/null 2>/dev/null
if [ $test_arch="x86" ]; then
    #revert old-fashioned patches
    cd $rootme/$ndk_dir/toolchains/x86-$compiler/prebuilt/linux-x86/lib/gcc/i686-linux-android/4.6.x-google/include-fixed/sys $debug 1>/dev/null 2>/dev/null
    patch -p0 -R -i $rootme/types.patch --forward $debug 1>/dev/null 2>/dev/null
fi
cd $rootme
#echo " temp files... "
#echo " temp directories... "
rm -rf $build_folder/ANDROID $debug 1>/dev/null 2>/dev/null
rmdir $build_folder/ANDROID $debug 1>/dev/null 2>/dev/null

echo "All done, you can find results in $dest_folder"

if [ "$check_error" = "0" ]; then
    $ndebug echo "$y is completed OK"
    exit 0
else
    $ndebug echo "$y returned NON-ZERO !"
    echo "Make Check failed, aborted"
    exit -1
fi
