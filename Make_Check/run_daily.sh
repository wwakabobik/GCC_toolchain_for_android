#!/bin/bash

export http_proxy=http://proxy.ims.intel.com:911
export https_proxy=https://proxy.ims.intel.com:911
export no_proxy=localhost,.intel.com,127.0.0.0/8,172.16.0.0/20,192.168.0.0/16,10.0.0.0/8

trunk_version="4.9.0"  #  It's a global parameter
y=`basename $0`
st_dt=`date +%Y%m%d_%H%M%S`
$ndebug echo "$y started on $st_dt with parameters:"
$ndebug echo "   $1"
$ndebug echo "   $2"
$ndebug echo "   $3  $4  $5"
$ndebug echo "android_stl_type=$android_stl_type"

if [ -z $1 ]; then
    compiler="4.7.2"
    echo "Compiler isn't specified, trying to use $compiler compiler defaults"
else
    compiler=$1
fi

if [ -z $2 ]; then
    test_arch="x86"
    echo "Testing device/arch isn't specified, trying to use $test_arch arch defaults"
else
    test_arch=$2
fi

tested_object=0
if [ -z $3 ]; then
    $ndebug echo "Tested object is taken as NDK (on Default): it corresponds to value 0 of tested_object (variable in scripts and column in tables of sqlite3)"
    tested_object=0
else
    if [ "$3" == "NDK" ]; then
      $ndebug echo "Tested object is defined as NDK"
      tested_object=0
    else
        if [ "$3" == "Image" ]; then
            $ndebug echo "Tested object is defined as Android's Image"
            tested_object=1
        else
            echo "3rd parameter is not belong to taken range of values, execution is aborted"
            exit -1
      fi
   fi
fi

#  bits: 32 or 64
bits=0
if [ -z $4 ]; then
    bits=32
    $ndebug echo "NDK compiler is taken as $bits bits"
else
    bits=$4
    if [ "$bits" != "32" ] && [ "$bits" != "64" ]; then
        "4th parameter (if specified) must be equal to 32 or 64, aborted"
        exit -1
    fi
fi

image_type=""
if [ -z $5 ]; then
     if [ "$test_arch" == "x86" ]; then
        image_type="MCG_eng"
     fi
     if [ "$test_arch" == "Medfield" ]; then
        image_type="MCG_eng"
     fi
     if [ "$test_arch" == "CloverTrail" ]; then
        image_type="MCG_eng"
     fi
     if [ "$test_arch" == "Merrifield" ]; then
        image_type="MCG_eng"
     fi
     if [ "$test_arch" == "HarrisBeach" ]; then
        image_type="MCG_eng"
     fi
     if [ "$test_arch" == "arm" ]; then
        image_type="Vanilla"
     fi
     if [ "$test_arch" == "GalaxyNexus" ];then
        image_type="Vanilla"
     fi
     if [ "$test_arch" == "Nexus4" ]; then
        image_type="AOSP"
     fi
     if [ "$image_type" != "" ]; then
        echo "Android's Image type is taken as $image_type"
     else
        echo "Android's Image type was not specified and we were not able guess about acceptable default value, aborted."
        exit -1
     fi
else
    image_type=$5
fi

if [ -z $MC_User ]; then
    MC_User=$USER
fi

#defaults
adb_folder="/nfs/ims/proj/icl/gcc_cw/share/ADB"
daily_folder="/users/$MC_User/MC_Daily"
log_folder="$daily_folder/logs"
daily_script="./daily_mc_ndk.sh"
update_dejagnu=0
post_results=1

cd $daily_folder
rootme=$PWD
OLD_PATH=$PATH
export PATH=$adb_folder:$PATH:$daily_folder

if [ ! -d $daily_folder ]; then
    echo "no $daily_folder exists, aborted"
    export PATH=$OLD_PATH
    exit -1
else
    cd $daily_folder
    if [ ! -f $daily_script ]; then
        echo "$daily_script not found, aborted"
        cd $rootme
        export PATH=$OLD_PATH
        exit -1
    fi
fi

if [ -f ./Devices/$test_arch.cfg ]; then
    if [ -z $device_serial ]; then
        device_serial=`grep "device_serial" ./Devices/$test_arch.cfg | sed 's/device_serial=//'`
    fi
    if [ -z $device_arch ]; then
        device_arch=`grep "device_arch" ./Devices/$test_arch.cfg | sed 's/device_arch=//'`
    fi
    if [ -z $device_temp ]; then
        device_temp=`grep "device_temp" ./Devices/$test_arch.cfg | sed 's/device_temp=//'`
    fi
    if [ -z $device_rooted ]; then
        device_rooted=`grep "device_rooted" ./Devices/$test_arch.cfg | sed 's/device_rooted=//'`
    fi
    if [ -z $device_fs ]; then
        device_fs=`grep "device_fs" ./Devices/$test_arch.cfg | sed 's/device_fs=//'`
    fi
    if [ -z $device_disk ]; then
        device_disk=`grep "device_disk" ./Devices/$test_arch.cfg | sed 's/device_disk=//'`
    fi
    if [ -z $device_platform ]; then
        device_android_platform=`grep "device_android_platform" ./Devices/$test_arch.cfg | sed 's/device_android_platform=//'`
    fi
    if [ -z $device_alias ]; then
        device_alias=`grep "device_alias" ./Devices/$test_arch.cfg | sed 's/device_alias=//'`
    fi
    if [ -z $device_tune ]; then
        device_tune=`grep "device_tune" ./Devices/$test_arch.cfg | sed 's/device_tune=//'`
    fi
    if [ -z $device_target_bits ]; then
        device_target_bits=`grep "device_target_bits" ./Devices/$test_arch.cfg | sed 's/device_target_bits=//'`
    fi

    if [ -z $device_serial ] || [ -z $device_arch ]; then
        echo "Critical, no device\platform specified"
        export PATH=$OLD_PATH
        cd $rootme
        exit -1
    fi

    ./Phone_reboot_common.sh $device_serial

    if [ -z $device_temp ]; then
        device_temp="/data/local/MC_Temp"
    fi

    if [ -z $device_rooted ] || [ -z $device_disk ]; then
        device_rooted=0
    fi

    if [ -z $device_fs ]; then
        device_fs="ext4"
    fi

    if [ -z $device_android_platform ]; then
        device_rooted=0
        device_android_platform=9
    fi

    if [ -z $device_alias ]; then
        device_alias=$test_arch
    fi

    if [ -z $device_target_bits ]; then
        device_target_bits=32
    fi

    export ADB_SERIAL=$device_serial
    export device_temp
    export device_fs
    export device_disk
    export device_target_bits
#else #do not use stright check, probably it will be specified within env
    #echo "device configuration is unknown, aborted"
    #cd $rootme
    #export PATH=$OLD_PATH
    #exit -1
fi

if [ ! -d $log_folder ]; then
    echo " no $log_folder exists, create new one"
    mkdir -p $log_folder
fi

#update repo
#svn up $debug 1>/dev/null 2>/dev/null

mkdir -p $log_folder/$test_arch $debug 1>/dev/null 2>/dev/null
file_log=$log_folder/$test_arch/MC_${bits}_${device_target_bits}_${compiler}_${device_alias}_`date +%Y%m%d`.log
$ndebug echo "$daily_script was launched: see $file_log in order to"
$ndebug echo "      have seen parameters, messages, subscripts of the above bash  script"

$daily_script $daily_folder $device_serial $compiler $update_dejagnu $post_results $device_arch $device_rooted $device_alias $device_android_platform  $bits  $tested_object $image_type $trunk_version  1>"${file_log}"  2>&1

x=$?
if [ $x -ne 0 ]; then
    $ndebug echo "$daily_script returned $x,"
    $ndebug echo "     for details, see the above .log file"
    export PATH=$OLD_PATH
    cd $rootme
    exit -1
fi

export PATH=$OLD_PATH

if [ $MC_User != $USER ];then
    chmod -R ug+w * $debug 1>/dev/null 2>/dev/null
    chmod -R ug+w .* $debug 1>/dev/null 2>/dev/null
fi

cd $rootme

exit 0
