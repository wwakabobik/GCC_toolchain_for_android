#!/bin/bash 

export PATH=/nfs/ims/proj/icl/gcc_cw/share/ADB:/users/${USER}/AndroidBuild/repos/android-sdk-linux/platform-tools:/users/${USER}/AndroidBuild/repos/android-sdk-linux/tools:/usr/sbin:$PATH
export PATH=/nfs/ims/proj/icl/gcc_cw/share/ADB:/users/${USER}/android-SDK/adt-bundle-linux-x86_64/sdk/tools:/users/${USER}/AndroidBuild/repos/android-sdk-linux/platform-tools:/users/${USER}/AndroidBuild/repos/android-sdk-linux/tools:/usr/sbin:$PATH
#export ANDROID_SERIAL=Medfield5344EBC9
#export ANDROID_SERIAL="msticltz104.ims.intel.com:5555"
#export DISPLAY=$(ps x | grep `whoami` | grep 'Xvnc' | grep `hostname` | sed -e 's/\(.*\)\(['`hostname`':].*\)\((.*\)/\2/')
#export DISPLAY=:98
version=$1  # Version of image 4.6 or 4.7
cur_date=$2
bit=$3
serial=$4
#special=$5


if [ "$bit" == "" ]; then
    bit="32"
fi
    

check_serial(){
    if  [ "$1" == "msticltz104.ims.intel.com:5555" ] || [ "$1" == "msticltz103.ims.intel.com:5555" ]; then 
	echo "Your ANDROID_SERIAL is $1"
	export ANDROID_SERIAL=$1
    else
	echo "You are using not HarrisBeach serial (check your env), will be used msticltz104.ims.intel.com:5555"
	export ANDROID_SERIAL="msticltz104.ims.intel.com:5555"
    fi
}

if [ "$serial" != "" ]; then
    check_serial $serial
else
    check_serial $ANDROID_SERIAL
fi



#exit 0;	
tools="/users/aagovorx/AndroidBuild/repos/bin" #Path for tools:  fastboot_ctp and etc.
name="${USER}" #Username of image builder
hour=`date +%_H`
# Check for daily using, because first image flashes at same date as it was built, and the next one (4.7) flashes only at the next day, at morning.
# for avoiding addition manual manipulations this check were added.
# 16 - it's 16 hours, we asssume that images already built until 17.00, at least image for 4.6( this image flashes first).
if [ "$cur_date" == ""  ]; then
if  [[ "$hour" -le 16 ]]; then 
    cur_date=`date +%Y%m%d -d "yesterday"` 
    else
    cur_date=`date +%Y%m%d`
fi
fi

#cur_date="20130128" # set special date for special image.

if [ "$version" = "" ]; then
     echo "Version not set! Will be used 4.6 by default"
     version="4.6"
fi

image=${cur_date}"_"${version}${special}
baseDir=/gnu_cw_hosts/msticlxl102_users/${USER}/AndroidTesting

if [ ! -f ${baseDir}/builds/images/${image}/OTC_$bit/ota-dev.zip ]; then
 echo "Image ${version}${special} of ${cur_date} not found!"
 echo "Flashing image and AWR test cancelled"
 exit 1;
fi

function flashimage {
    if [ ! -e $1 ]; then
        echo "$1 file missing"
        return 1
    fi
    adb push $1 /data
    BN=`basename $1`
    adb shell "cat /data/$BN > $2"
    adb shell "rm /data/$BN"
    return 0
}



flash_on_phone () {
adb connect ${ANDROID_SERIAL}
echo "Copying OTA image  to device..."
adb push ${baseDir}/builds/images/${image}/OTC_$bit/ota-dev.zip /cache/update.zip
echo "Setting parameters and rebooting into recovery console..."
adb shell "mkdir -p /cache/recovery"
adb shell "echo \"--update_package=/cache/update.zip\" > /cache/recovery/command"
timeout 4 adb reboot recovery || true
sleep 300
adb connect ${ANDROID_SERIAL}
}

# prepating phone:
# !!! MUST BE DONE BEFORE RUNNING ANY TESTS !!!
# 1. depersonalization phone (removing redhookbay and clovertrail from build.prop) 
# 2. setting frequency happens in after-reboot-required.py !Don't reboot phone after setting frequency!
prepare_phone () {
    adb root
    sleep 1
    adb remount
    sleep 1
#    adb shell 'mount -o remount,rw -t rootfs rootfs /system'
    sleep 7
#    adb push /nfs/ims/proj/icl/gcc_cw/share/daily_testing/bin/sed /system/xbin/
    sleep 1
    adb shell 'chmod 777 /system/xbin/sed'
    sleep 1
    adb shell 'sed -e "s/core_ufo/device103/g" -i /system/build.prop'
    sleep 1
    adb shell 'sed -e "s/harrisbeach/device103/g" -i /system/build.prop'
    
    sleep 1
#    adb shell 'sed -e "s/bigcore/device103/g" -i /system/build.prop'
        sleep 1
    adb shell 'sed -e "s/ro.kernel.android.checkjni=/#ro.kernel.android.checkjni=/g" -i /system/build.prop'
#    adb shell 'sed -e "s/test-keys/dev-keys/g" -i /system/build.prop'
    sleep 1
    adb shell "sed -e \"s/\ test-keys/\ ${version}\ test-keys/g\" -i /system/build.prop"
    sleep 1
	adb shell "su -c mkdir /data/local"
	adb shell "su -c chmod -R 777 /data"
	adb shell "ls -la /data/local"
	adb root
    sleep 3
}
echo "Flashing Android kernel image..."
    flashimage ${baseDir}/builds/images/${image}/OTC_$bit/boot.img /dev/block/by-name/boot

echo "Flashing recovery kernel image..."
    flashimage ${baseDir}/builds/images/${image}/OTC_$bit/recovery.img /dev/block/by-name/recovery

echo "Flashing Droidboot kernel image..."
    flashimage ${baseDir}/builds/images/${image}/OTC_$bit/droidboot.img /dev/block/by-name/fastboot

flash_on_phone $image
prepare_phone

