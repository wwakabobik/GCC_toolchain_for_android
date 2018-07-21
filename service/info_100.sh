#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    info.sh
# Purpose: part of integral adb devices status monitor informer, shows status of devices
#          and provides link for additional info. Monitors now Medfield
#          and Nexus4 devices. Default machine is msticlxl100.
#
# Author:      Ilya Vereshchagin
#
# Created:     01.03.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

device_pattern=(019270fc9908425c 00289867da111923 MedfieldB12636D7 MedfieldE906493B msticltz103.ims.intel.com:5555 msticltz104.ims.intel.com:5555)
declare -A device_aliases=([MedfieldB12636D7]='Medfield' [MedfieldE906493B]='Medfield' [019270fc9908425c]='Nexus4' [00289867da111923]='Nexus4' [msticltz103.ims.intel.com:5555]='HarrisBeach' [msticltz104.ims.intel.com:5555]='HarrisBeach')
declare -A device_found=([Nexus4]='0' [Medfield]='0' [HarrisBeach]='0')

share="/nfs/ims/proj/icl/gcc_cw/share"
adb="$share/ADB/adb"
monitor_root="$share/monitor"
info_script="info_current.sh"
#output_temp="info_adb_100.html"
#output_page="info_100.html"
counter=1
go_out=0
device_connected=""
#statuses
disconnected="disconnected"
freedev="free"
occupied="occupied"
monopoly="occupied in monopoly mode"
corrupted="corrupted"
recovery="in recovery mode"
device_occupancy=$disconnected
disconnected_img="<IMG src='disconnected.png'>"
freedev_img="<IMG src='free.png'>"
occupied_img="<IMG src='occupied.png'>"
monopoly_img="<IMG src='monopoly.png'>"
corrupted_img="<IMG src='corrupted.png'>"
recovery_img="<IMG src='recovery.png'>"
device_occupancy_img=$disconnected_img

while [ $go_out != 1 ];
do
    let "counter = $counter + 1"
    device_connected=`$adb devices | head -n $counter | tail -n 1`
    if [[ -z $device_connected ]]; then
	break
    fi
    echo $device_connected | grep "????????????" 1>/dev/null 2>/dev/null
    if [ $? == 0 ]; then
        device_connected="FaultyDevice"
        device_alias=$device_connected
    fi
    device_connected=`echo "$device_connected" | awk '{print $1}'`
    #generate monitor files
    found=0
    for arg in ${device_pattern[*]}
    do
	echo $device_connected | grep "$arg" 1>/dev/null 2>/dev/null
	if [ $? == 0 ]; then
	    device_alias=${device_aliases[$arg]}
	    device_found[$device_alias]=1
	    found=1
	    break
	fi
    done
    if [ $found == 0 ]; then
        device_alias=$device_connected
    fi
    device_page=`echo $device_connected | sed 's/\.//g' | sed 's/\://g'`
    $monitor_root/$info_script "$device_connected" > "/tmp/info_$device_page.100.html" 2> /dev/null
    status=`echo $?`
    #rm -f $monitor_root/info_$device_page.100.html 2>/dev/null
    mv /tmp/info_$device_page.100.html $monitor_root/info_$device_page.100.html
    #rm -f /tmp/info_$device_page.100.html 2>/dev/null
    echo $device_connected | grep "recovery" 1>/dev/null 2>/dev/null
    if [[ $? == 0 ]]; then
	device_occupancy=$recovery
        device_occupancy_img=$recovery_img
    else
	if [[ $status == "0" ]]; then
	    device_occupancy=$freedev
            device_occupancy_img=$freedev_img
	elif [[ $status == "1" ]]; then
	    device_occupancy=$occupied
            device_occupancy_img=$occupied_img
	elif [[ $status == "2" ]]; then
	    device_occupancy=$monopoly
            device_occupancy_img=$monopoly_img
	elif [[ $status == "3" ]]; then
	    device_occupancy=$disconnected
            device_occupancy_img=$disconnected_img
	else
	    device_occupancy=$corrupted
            device_occupancy_img=$corrupted_img
	fi
    fi
    echo "   <H2>$device_occupancy_img <a href="info_$device_page.100.html">$device_alias</a> is $device_occupancy</H2>"
    if [[ $status != "3" ]] && ! [[ $device_alias =~ ^emulator ]] ; then
        echo "<H4>build.prop info: $device_connected `$adb -s $device_connected shell grep ro.build.description= /system/build.prop | cut -d= -f2`</H4>"
    fi
done

#if devices are disconnected, generate info anyway
for arg in ${device_aliases[*]}
do
if [ ${device_found[$arg]} == "0" ]; then
    $monitor_root/$info_script "$arg" > "/tmp/info_$arg.100.html"
    mv /tmp/info_$arg.100.html $monitor_root/info_$arg.100.html
    echo "<H2>$disconnected_img <a href=\"info_$arg.100.html\">$arg</a> is $disconnected</H2>"
fi
device_found[$arg]=1
done

exit 0
