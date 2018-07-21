#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    Phone_reboot_common.sh
# Purpose: script reboots the phone and set frequencies, makes device anonymous
#
# Author:      Arseniy Antonov
#
# Created:     20.03.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

yy=`basename $0`
$ndebug echo "$yy started with parameters:"
$ndebug echo "   $1"

connectedDevice=$1
hostname=`hostname`

declare -A phones
export ANDROID_SERIAL="$connectedDevice"

phones[019270fc9908425c]='Nexus4'
phones[00289867da111923]='Nexus4'
phones[0146AFFC18020012]='GalaxyNexus'
phones[0146A0CD1601301E]='GalaxyNexus'
phones[MedfieldB12636D7]='medfield'
phones[MedfieldE906493B]='medfield'
phones[Medfield2D7DC688]='clovertrail'
phones[Medfield5344EBC9]='clovertrail'
phones[RHBEC245500319]='clovertrail'
phones[RHBEC245500390]='clovertrail'
phones[INV131701015]='merrifield'
phones[INV131700234]='merrifield'
phones[msticltz104.ims.intel.com:5555]='harrisbeach'
phones[msticltz103.ims.intel.com:5555]='harrisbeach'
phones[INV133601000]='merrifield'
phones[INV133600823]='merrifield'

for i in "${!phones[@]}"
do
    if [ "$i" == "$connectedDevice" ]; then
        deviceModel=${phones[$i]}
    fi
done
if [ "$deviceModel" == "" ]; then
    echo "No such device, please check your serial number which you sent as parameter) "
fi

if [ "$deviceModel" = "harrisbeach" ]; then
    adb -s "$connectedDevice" reboot
    sleep 60
    adb connect $connectedDevice
    adb -s   "$connectedDevice"   wait-for-device
    adb -s "$connectedDevice" root
    sleep 10
    adb connect $connectedDevice
    adb shell "echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
    adb shell "echo 1400000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
    adb shell "echo 1400000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor"
    adb shell "echo 1400000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq"
    adb shell "echo 1400000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor"
    adb shell "echo 1400000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq"
    adb shell "echo 1400000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor"
    adb shell "echo 1400000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq"
    adb shell "echo 1400000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq"
    sleep 150
    adb shell 'sed -e "s/core_ufo/deviceHB10400102/g" -i /system/build.prop'
    sleep 1
    adb shell 'sed -e "s/harrisbeach/deviceHB10400102/g" -i /system/build.prop'
    sleep 1
    adb shell 'sed -e "s/ro.kernel.android.checkjni=/#ro.kernel.android.checkjni=/g" -i /system/build.prop'
    sleep 10
    adb -s   "$connectedDevice" root
    sleep 10
    adb connect $connectedDevice
    adb -s   "$connectedDevice" remount
    sleep 10
    adb connect $connectedDevice
    exit 0
fi

if [ "$deviceModel" = "merrifield" ]; then
    adb -s   "$connectedDevice"   reboot
    adb -s   "$connectedDevice"   wait-for-device
    adb shell "echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
    adb shell "echo 2133000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
    adb shell "echo 2133000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor"
    adb shell "echo 2133000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq"
    adb shell "echo 2133000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor"
    adb shell "echo 2133000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq"
    adb shell "echo 2133000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor"
    adb shell "echo 2133000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq"
    adb shell "echo 2133000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq"
    sleep 150
    adb -s   "$connectedDevice"  shell 'sed -e "s/saltbay/deviceINV131701015/g" -i /system/build.prop'
    sleep 1
    adb -s   "$connectedDevice"  shell 'sed -e "s/merrifield/deviceINV131701015/g" -i /system/build.prop'
    sleep 1
    adb -s   "$connectedDevice"  shell 'sed -e "s/ro.kernel.android.checkjni=/#ro.kernel.android.checkjni=/g" -i /system/build.prop'
    adb -s   "$connectedDevice" root
    sleep 10
    adb -s   "$connectedDevice" remount
    sleep 10
    exit 0
fi

if [ "$deviceModel" = "medfield" ]; then
    adb -s   "$connectedDevice"   reboot
    adb -s   "$connectedDevice"   wait-for-device
    adb -s   "$connectedDevice" root
    sleep 10
    adb -s   "$connectedDevice" remount
    sleep 10
    adb shell "echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
    adb shell "echo 1600000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
    adb shell "echo 1600000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor"
    adb shell "echo 1600000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq"
    adb shell "echo 1600000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq"
    sleep 150
    adb -s   "$connectedDevice"  shell 'sed -e "s/blackbay/deviceB12636D7/g" -i /system/build.prop'
    sleep 1
    adb -s   "$connectedDevice"  shell 'sed -e "s/medfield/deviceB12636D7/g" -i /system/build.prop'
    sleep 1
    adb -s   "$connectedDevice"  shell 'sed -e "s/ro.kernel.android.checkjni=/#ro.kernel.android.checkjni=/g" -i /system/build.prop'
    adb -s   "$connectedDevice" root
    sleep 10
    adb -s   "$connectedDevice" remount
    sleep 10
    exit 0
fi

if [ "$deviceModel" = "clovertrail" ]; then

    adb -s   "$connectedDevice"   reboot
    adb -s   "$connectedDevice"   wait-for-device
    adb -s   "$connectedDevice" root
    sleep 10
    adb -s   "$connectedDevice" remount
    sleep 10
    adb shell "echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq"
    sleep 150
    if [ "$hostname" = "msticlxl101" ]; then
        sleep 1
        adb -s   "$connectedDevice"  shell 'sed -e "s/redhookbay/device2D7DC688/g" -i /system/build.prop'
        sleep 1
        adb -s   "$connectedDevice"  shell 'sed -e "s/clovertrail/device2D7DC688/g" -i /system/build.prop'
        sleep 1
        adb -s   "$connectedDevice"  shell 'sed -e "s/ro.kernel.android.checkjni=/#ro.kernel.android.checkjni=/g" -i /system/build.prop'
    else
        sleep 1
        adb -s   "$connectedDevice"  shell 'sed -e "s/redhookbay/device2D7DC688_100/g" -i /system/build.prop'
        sleep 1
        adb -s   "$connectedDevice"  shell 'sed -e "s/clovertrail/device2D7DC688_100/g" -i /system/build.prop'
        sleep 1
        adb -s   "$connectedDevice"  shell 'sed -e "s/ro.kernel.android.checkjni=/#ro.kernel.android.checkjni=/g" -i /system/build.prop'
    fi
    adb -s   "$connectedDevice" root
    sleep 10
    adb -s   "$connectedDevice" remount
    sleep 10
    exit 0
fi

if [ "$deviceModel" = "GalaxyNexus" ]; then
    adb -s   "$connectedDevice"   reboot
    adb -s   "$connectedDevice"   wait-for-device
    adb -s   "$connectedDevice" root
    sleep 10
    adb -s   "$connectedDevice" remount
    sleep 10
    adb shell "su -c 'echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor'"
    adb shell "su -c 'echo 1200000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq'"
    adb shell "su -c 'echo 1200000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq'"
    sleep 150
    adb shell "su -c 'echo userspace > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor'"
    adb shell "su -c 'echo 1200000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq'"
    adb shell "su -c 'echo 1200000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq'"
    sleep 150
    adb -s   "$connectedDevice" root
    sleep 10
    adb -s   "$connectedDevice" remount
    sleep 10
    exit 0
fi

if [ "$deviceModel" = "Nexus4" ]; then
    adb -s   "$connectedDevice"   reboot
    adb -s   "$connectedDevice"   wait-for-device
    adb -s   "$connectedDevice" root
    sleep 10
    adb -s   "$connectedDevice" remount
    sleep 10
    adb shell "echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq"
    sleep 150
    adb shell "echo userspace > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq"
    sleep 150
    adb -s   "$connectedDevice" root
    sleep 10
    adb -s   "$connectedDevice" remount
    sleep 10
    exit 0
fi
