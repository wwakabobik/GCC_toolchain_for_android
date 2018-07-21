#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    info.sh
# Purpose: integral adb devices status monitor informer, shows status of devices
#          and provides link for additional info. Monitors now Medfield
#          and GalaxyNexus devices. Default machine is msticlxl101.
#
# Author:      Iliya Vereshchagin
#
# Created:     31.01.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

device_pattern=(MedfieldB12636D7 0146A0CD1601301E MedfieldE906493B 0146AFFC18020012 INV133601000)
declare -A device_aliases=([MedfieldB12636D7]='Medfield' [MedfieldE906493B]='Medfield' [0146A0CD1601301E]='GalaxyNexus' [0146AFFC18020012]='GalaxyNexus' [INV133601000]='Merrifield_pr2' [INV133600823]='Merrifield_pr2')
declare -A device_found=([Medfield]='0' [GalaxyNexus]='0' [Merrifield_pr2]='0')

share="/nfs/ims/proj/icl/gcc_cw/share"
adb="$share/ADB/adb"
monitor_root="$share/monitor"
info_script="info_current.sh"
output_temp="info_adb_101.html"
output_page="info.html"
build_info="build_info.html"
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

#rm $monitor_root/*.html
#<link href="data:image/x-icon;base64,AAABAAEAEBAAAAAAAABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAABIXFxc0rKyshqenp6Wnp6eenp6eeAAAACoAAAANAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAADAAAAEQAAACi+vrz/vr68/76+vP++vrz/vr68/76+vP++vrz/vr68/wAAACMAAAAPAAAABAAAAAAAAAAAAAAAAQAAAAwAAAAgr6+vmr6+vP++vrz/vr68/76+vP++vrz/vr68/1NTU1EAAAAcAAAACQAAAAEAAAAAAAAAAFlZWAGoqKYYrKyqGJ+fnRyDg4Ekvr68/76+vP++vrz/hYWEO4uLiSOqqqcbsbGuGKampBgAAAAAAAAAAAAAAAC+vrz/vr68/76+vP++vrz/vr68/76+vP++vrz/vr68/76+vP++vrz/vr68/76+vP++vrz/r6+sWwAAAAAAAAAAvr68/wEBAf8BAQH/AQEB/wEBAf8BAQH/AQEB/wEBAf8BAQH/AQEB/wEBAf8BAQH/vr68/6+vrFwAAAAAAAAAAL6+vP8BAQH/AQEB/wEBAf8BAQH/AQEB/wEBAf8BAQH/AQEB/wEBAf8BAQH/AQEB/76+vP+vr6xcAAAAAAAAAAC+vrz/AQEB/wEBAf8BAQH/AQEB/wEBAf8BAQH/AQEB/wEBAf8BAQH/AQEB/wEBAf++vrz/r6+sXAAAAAAAAAAAvr68/wEBAf8BAQH/AAAA/wEBAf8BAQH///////////8BAQH/AQEB/xAQEP8BAQH/vr68/6+vrFwAAAAAAAAAAL6+vP8BAQH/AQEB//////8AAAD/AAAA/wEBAf8BAQH/AAAA/wAAAP8AAAD/AQEB/76+vP+vr6xcAAAAAAAAAAC+vrz/AQEB/wEBAf8BAQH//////wEBAf8BAQH/AQEB/wAAAP8AAAD/AAAA/wEBAf++vrz/r6+sXAAAAAAAAAAAvr68/wEBAf8BAQH//////wEBAf8BAQH/AQEB/wEBAf8BAQH/AQEB/wEBAf8BAQH/vr68/6+vrFwAAAAAAAAAAL6+vP8BAQH/AQEB/wEBAf8BAQH/AQEB/wEBAf8BAQH/AQEB/wEBAf8BAQH/AQEB/76+vP+vr6xcAAAAAAAAAAC+vrz/vr68/76+vP++vrz/vr68/76+vP++vrz/vr68/76+vP++vrz/vr68/76+vP++vrz/tra0PgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//8AAPx/AADwDwAA8B8AAPx/AACAAwAAgAMAAIADAACAAwAAgAMAAIADAACAAwAAgAMAAIADAACAAwAA//8AAA==" rel="icon" type="image/x-icon" />
cat >$monitor_root/$output_temp <<EOF
<HTML>
<HEAD>

<link rel="shortcut icon" href="favicon.ico" />
<TITLE>Adb device status monitor on msticlxl101</TITLE>
<STYLE type="text/css">
body {
    background: white url("android-background.jpg") no-repeat center fixed;
}
</STYLE>
</HEAD>
<BODY>
<IMG src="Intel_logo.jpg" style="border=0; position: absolute; right: 5px; top -5px; width: 15%" />
<H3>Status of connected to <i>msticlxl101</i> adb devices is:</H3>
EOF

while [ $go_out != 1 ];
do
    let "counter = $counter + 1"
    device_connected=`$adb devices | head -n $counter | tail -n 1`
    if [[ -z $device_connected ]]; then
	break
    fi
    echo $device_connected | grep "?????" 1>/dev/null 2>/dev/null
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
    $monitor_root/$info_script "$device_connected" >"$monitor_root/info_$device_page.html" 2>/dev/null
    status=`echo $?`
    #rm -f $monitor_root/info_$device_page.html 2>/dev/null
    #cp /tmp/info_$device_page.html $monitor_root/info_$device_page.html
    #rm -f /tmp/info_$device_page.html 2>/dev/null
    #chown $USER $monitor_root/info_$device_page.html
    #chmod 664 $monitor_root/info_$device_page.html
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
    cat >>$monitor_root/$output_temp <<EOF
    <H2>$device_occupancy_img <a href="info_$device_page.html">$device_alias</a> is $device_occupancy</H2>
EOF
    if [[ $status != "3" ]] && ! [[ $device_alias =~ ^emulator ]] ; then
        cat >>$monitor_root/$output_temp <<EOF
        <H4>build.prop info: $device_connected `$adb -s $device_connected shell grep ro.build.description= /system/build.prop | cut -d= -f2`</H4>
EOF
    fi
done

#if devices are disconnected, generate info anyway
for arg in ${device_aliases[*]}
do
if [ ${device_found[$arg]} == "0" ]; then
    $monitor_root/$info_script "$arg" >$monitor_root/info_$arg.html
    #chown $USER $monitor_root/info_$arg.html
    #chmod 664 $monitor_root/info_$arg.html
cat >>$monitor_root/$output_temp <<EOF
<H2>$disconnected_img <a href="info_$arg.html">$arg</a> is $disconnected</H2>
EOF
fi
device_found[$arg]=1
done

#	get devices' status on xl100 and 102
for i in 100 102 ; do
ssh ${USER}@msticlxl$i exit >/dev/null 2>/dev/null &
pid=$!
sleep 3
res_status=`ps aux | grep " $pid " | grep -v grep  >/dev/null 2>/dev/null && echo $?`
if [[ $res_status == "0" ]] ; then
    kill -15 $pid >/dev/null 2>/dev/null
    cat >>$monitor_root/$output_temp <<EOF
<HR>
<H2>xl$i isn't responding!</H2>
EOF
else
	if ssh ${USER}@msticlxl$i exit >/dev/null 2>/dev/null ; then
		cat >>$monitor_root/$output_temp <<EOF
<HR>
<H3>Status of connected to <i>msticlxl$i</i> adb devices is:</H3>
EOF
		ssh ${USER}@msticlxl$i 'bash -s' < $monitor_root/info_$i.sh >>$monitor_root/$output_temp 2>/dev/null
	else
		cat >>$monitor_root/$output_temp <<EOF
<HR>
<H2>xl$i: Connection closed by remote host</H2>
EOF
	fi
fi 2>/dev/null
done

# Build and test info
cat >>$monitor_root/$output_temp <<EOF
<div style="clear:both; height:50px;">
	<ul style="list-style:none; margin:0; padding:0; text-align:center; width:100%;"><li style="display:inline; padding:7px; width:100px;">
	<li style="display:inline; padding:7px; width:100px;">
    	<font size="4"><b><a style="background-color:#EBF5DB; color:black; padding:7px; border-radius:5px; text-decoration:none;" href="file://///samba.ims.intel.com/nfs/ims/proj/icl/gcc_cw/share/monitor/MC_Monitor.html"> Make Check Results </a></b></font>
	</li><li style="display:inline; padding:7px; width:100px;">
    	<font size="4"><b><a style="background-color:#EBF5DB; color:black; padding:7px; border-radius:5px; text-decoration:none;" href="http://///traqs.intel.com/ViewPlainReport.aspx?EnforceTeam=GCC&QueryID=192"> Traq results </a></b></font>
	</li><li style="display:inline; width:100px; padding:7px;">
    	<font size="4"><b><a style="background-color:#EBF5DB; color:black; padding:7px; border-radius:5px; text-decoration:none;" href="file://///samba.ims.intel.com/nfs/ims/proj/icl/gcc_cw/share/monitor/report_today.html"> Today's build report </a></b></font>
	</li><li style="display:inline; padding:7px; width:100px;">
    	<font size="4"><b><a style="background-color:#EBF5DB; color:black; padding:7px; border-radius:5px; text-decoration:none;" href="file://///samba.ims.intel.com/nfs/ims/proj/icl/gcc_cw/share/monitor/report.html"> Yesterday's build report </a></b></font>
	</li><li style="display:inline; padding:7px; width:100px;">
    	<font size="4"><b><a style="background-color:#EBF5DB; color:black; padding:7px; border-radius:5px; text-decoration:none;" href="file://///samba.ims.intel.com/nfs/ims/proj/icl/gcc_cw/share/monitor/NDK_testing_report.html"> NDK/Bionic testing report </a></b></font>
	</li></ul>
</div>
<div id="footer" style="clear:both;">
	<meta http-equiv="refresh" content="15">
	$(date)
</div>
</BODY>
</HTML>
EOF

cp $monitor_root/$output_temp $monitor_root/$output_page
rm $monitor_root/$output_temp
#chmod 664 $monitor_root/$output_page
#chmod 664 $monitor_root/*.html

#Build info
bash $monitor_root/build_info.sh 1>$monitor_root/$build_info.tmp 2>/users/gnucwtester/build_info.errors.log
cp $monitor_root/$build_info.tmp $monitor_root/$build_info 2>/users/gnucwtester/build_info.errors.log
rm $monitor_root/$build_info.tmp 2>/users/gnucwtester/build_info.errors.log

exit 0
