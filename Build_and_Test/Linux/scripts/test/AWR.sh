#!/bin/bash 

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi
source  $baseDir/scripts/path.sh

version=$1
awr_folder=$2
if [ -z $version ] ; then
    echo "Compiler version doesn't specified! Setup it as first argument"
    exit 1
fi
if [ -z $awr_folder ] ; then
	echo "AWR folder doesn't specified! Setup it as second argument"
	exit 1
fi

connectedDevice=$ANDROID_SERIAL
declare -A phones
phones[00289867da111923]='Nexus4' 
phones[0146AFFC18020012]='GalaxyNexus' 
phones[0146A0CD1601301E]='GalaxyNexus'
phones[MedfieldB12636D7]='medfield'
phones[MedfieldE906493B]='medfield' 
phones[Medfield2D7DC688]='clovertrail'
phones[Medfield5344EBC9]='clovertrail'
phones[RHBEC245500390]='clovertrail'

DISPLAY=$(ps x | grep $USER | grep 'Xvnc' | grep $HOSTNAME | awk '{print $8}' | cut -d: -f2)
if [ -z $DISPLAY ] ; then
    echo "VNC server isn't runned! Running..."
    ~/.vnc/startvnc
    DISPLAY=$(ps x | grep $USER | grep 'Xvnc' | grep $HOSTNAME | awk '{print $8}' | cut -d: -f2)
fi
export DISPLAY=":$DISPLAY"

for i in "${!phones[@]}" ; do
	if [ "$i" == "$connectedDevice" ]; then
		deviceModel=${phones[$i]}
	fi
done
if [ "$deviceModel" == "" ]; then
	echo "There is no tests for such device, please check your serial number (ANDROID_SERIAL) "
fi

cd /users/common/up-to-date/
python after-reboot-required.py -sudo-script ./sudo_run_internet.sh


if [ "$deviceModel" == "medfield"]; then
    adb shell "echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
    adb shell "echo 1600000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
    adb shell "echo 1600000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
    adb shell "echo 1600000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq"
    adb shell "echo 1600000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq"
    traq_file=$awr_folder/tools/traq-template_medfiled_$version.xml

elif [ "$deviceModel" == "clovertrail"]; then
    adb shell "echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
    sleep 100
    adb shell "echo userspace > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq"
    sleep 100
    adb shell "echo userspace > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq"
    sleep 100
    adb shell "echo userspace > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq"
    adb shell "echo 2000000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq"
    traq_file=$awr_folder/tools/traq-template_clovertrail_$version.xml

elif [ "$deviceModel" == "GalaxyNexus"]; then
    adb shell "su -c 'echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor'"
    adb shell "su -c 'echo 1200000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq'"
    adb shell "su -c 'echo 1200000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq'"
    sleep 100
    adb shell "su -c 'echo userspace > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor'"
    adb shell "su -c 'echo 1200000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq'"
    adb shell "su -c 'echo 1200000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq'"
    traq_file=$awr_folder/tools/traq-template_galaxyNexus.xml

elif [ "$deviceModel" == "Nexus4"]; then
    adb shell "echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
    sleep 100
    adb shell "echo userspace > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq"
    adb shell "echo 1512000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq"
    sleep 10
    adb shell "su -c 'echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor'"
    adb shell "su -c 'echo 1512000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq'"
    adb shell "su -c 'echo 1512000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq'"
    sleep 100
    adb shell "su -c 'echo userspace > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor'"
    adb shell "su -c 'echo 1512000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq'"
    adb shell "su -c 'echo 1512000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq'"
                                                            
    traq_file=$awr_folder/tools/traq-template_galaxyNexus.xml
fi

monkeyrunner $awr_folder/scripts/awr.py -awr-dir=$awr_folder/ -traq-template=$traq_file

exit 0
 
