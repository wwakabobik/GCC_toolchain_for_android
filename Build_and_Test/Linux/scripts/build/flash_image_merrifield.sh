#!/bin/bash 

export PATH=/nfs/ims/proj/icl/gcc_cw/share/ADB:/users/${USER}/AndroidBuild/repos/android-sdk-linux/platform-tools:/users/${USER}/AndroidBuild/repos/android-sdk-linux/tools:/usr/sbin:$PATH
export PATH=/nfs/ims/proj/icl/gcc_cw/share/ADB:/users/${USER}/android-SDK/adt-bundle-linux-x86_64/sdk/tools:/users/${USER}/AndroidBuild/repos/android-sdk-linux/platform-tools:/users/${USER}/AndroidBuild/repos/android-sdk-linux/tools:/usr/sbin:$PATH
#export ANDROID_SERIAL=Medfield5344EBC9
export ANDROID_SERIAL=INV131701015
export DISPLAY=$(ps x | grep `whoami` | grep 'Xvnc' | grep `hostname` | sed -e 's/\(.*\)\(['`hostname`':].*\)\((.*\)/\2/')

export DISPLAY=:98
version=$1  # Version of image 4.6 or 4.7
cur_date=$2
bit=$3
#special=$4


if [ "$bit" == "" ]; then
    bit="32"
fi
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

if [ ! -f ${baseDir}/builds/images/${image}/merrifield_$bit/saltbay-ota-eng.${name}.zip ]; then
 echo "Image ${version}${special} of ${cur_date} not found!"
 echo "Flashing image and AWR test cancelled"
 exit 1;
fi


flash_on_phone () {
    adb reboot bootloader
    sleep 60
    fastboot_ctp devices
    sleep 1
#    fastboot_ctp erase boot
#    sleep 10
    fastboot_ctp erase system
    sleep 3
    fastboot_ctp erase cache
    sleep 3
    fastboot_ctp flash update  ${baseDir}/builds/images/${image}/merrifield_$bit/saltbay-ota-eng.${name}.zip
#    fastboot_ctp flash system  ${baseDir}/builds/images/$1/merrifield_32/system.img
    sleep 3
#    fastboot_ctp continue
    sleep 200
    adb wait-for-device
    sleep 100
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
    adb shell 'sed -e "s/saltbay/device131701015/g" -i /system/build.prop'
    sleep 1
    adb shell 'sed -e "s/merrifield/device131701015/g" -i /system/build.prop'
    sleep 1
    adb shell 'sed -e "s/ro.kernel.android.checkjni=/#ro.kernel.android.checkjni=/g" -i /system/build.prop'
    sleep 1
    adb shell "sed -e \"s/\ dev-keys/\ ${version}\ dev-keys/g\" -i /system/build.prop"
    sleep 1
	adb shell "su -c mkdir /data/local"
	adb shell "su -c chmod -R 777 /data"
	adb shell "ls -la /data/local"
    cd /users/common/up-to-date/
    python after-reboot-required.py -sudo-script ./sudo_run_internet.sh # turn on internet
	adb root
    sleep 3
}
flash_on_phone $image
prepare_phone

