#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    info_current.sh
# Purpose: adb device status monitor informer, shows status of devicem
#          provides info from adb status monitor.
#
# Author:      Ilya Vereshchagin
#
# Created:     31.01.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

share="/nfs/ims/proj/icl/gcc_cw/share"
adb="$share/ADB/adb"
monitor_root="$share/monitor"
job_dir="$monitor_root/job"

ADB_DEVICE=$1
#ADB_DEVICE=`echo $ADB_DEVICE | sed "s/\:/\./g"`

JOB_ROOT="$job_dir/$ADB_DEVICE"
ls $JOB_ROOT/* >/dev/null 2>/dev/null
res=`echo $?`
check_mono=`grep Monopoly $JOB_ROOT/* >/dev/null 2>/dev/null && echo $?`;
$adb -s $ADB_DEVICE shell "exit" >/dev/null 2>/dev/null &
pid=$!
sleep 1
res_status=`ps aux | grep " $pid " | grep -v grep  >/dev/null 2>/dev/null && echo $?`
if [[ $res_status == "0" ]] ; then
	kill -15 $pid >/dev/null 2>/dev/null
	status=
else
	status=`$adb -s $ADB_DEVICE shell "exit" >/dev/null 2>/dev/null && echo $?`
fi

rc=-1

echo '<HTML><HEAD>'
if [[ $res -ne 0 ]] && [[ $status == "0" ]] ; then
# free
	rc=0
	echo '<link href="data:image/x-icon;base64,AAABAAEAEBAQAAAAAAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAgAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAH5kjABieHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAREREREQAAAREREREREAARERERERERABERERIREREAERISIiEREQARERERERERABEhEiIiEREAESIREREREQARERERERERABEREREREREAERIRIREREQAiIhIiERIiAAIiERERIiAAACIiIiIiAAAAAAAAAAAAD//wAA4AcAAMADAACAAQAAgAEAAIABAACAAQAAgAEAAIABAACAAQAAgAEAAIABAACAAQAAwAMAAOAHAAD//wAA" rel="icon" type="image/x-icon" />'
	echo "<H1>It is $ADB_DEVICE</H1>"
	echo '</HEAD><BODY bgcolor="#A3F29D">'
	echo '<H2>Device is free</H2>'
elif [[ $res == "0" ]] && ! [[ $check_mono == "0" ]] && [[ $status == "0" ]] ; then
# busy
	rc=1
	echo '<link href="data:image/x-icon;base64,AAABAAEAEBAQAAAAAAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAgAAAAAAAAAAAAAAAEAAAAAAAAAAA4f8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEREREREREREREAAAAAABEREAAAAAAAAREAAAAAAAAAEQAAAAAAAAARAAAAAAAAABEAAAAAAAAAEQAAAAAAAAARAAAAAAAAABEAAAAAAAAAEQAAAAAAAAARAAAAAAAAABEAAAAAAAAAERAAAAAAAAEREQAAAAAAERERERERERERH//wAA4AcAAMADAACAAQAAgAEAAIABAACAAQAAgAEAAIABAACAAQAAgAEAAIABAACAAQAAwAMAAOAHAAD//wAA" rel="icon" type="image/x-icon" />'
	echo "<H1>It is $ADB_DEVICE</H1>"
	echo '</HEAD><BODY bgcolor="#D4F79C">'
	echo '<H2>There is no single mode, you can also run your job. Now are running:</H2>'
elif [[ $check_mono == "0" ]] && [[ $status == "0" ]] ; then
	rc=2
	echo '<link href="data:image/x-icon;base64,AAABAAEAEBAQAAAAAAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAgAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAFX/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAREREREQAAAREREREREAARERERERERABEREREREREAEREREREREQARERERERERABEREREREREAEREREREREQARERERERERABEREREREREAEREREREREQARERERERERAAERERERERAAABERERERAAAAAAAAAAAAD//wAA4AcAAMADAACAAQAAgAEAAIABAACAAQAAgAEAAIABAACAAQAAgAEAAIABAACAAQAAwAMAAOAHAAD//wAA" rel="icon" type="image/x-icon" />'
	echo "<H1>It is $ADB_DEVICE</H1>"
	echo '</HEAD><BODY bgcolor="#FFC89C">'
	echo '<H2>Single mode. Now are running:</H2>'
elif [[ $status != "0" ]] ; then
	rc=3
	echo '<link href="data:image/x-icon;base64,AAABAAEAEBAAAAEAGABoAwAAFgAAACgAAAAQAAAAIAAAAAEAGAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAD///////////////////////////////////////////////////////////////////////////////8KCqv///////////////////////8KCqv///////////////////////////8KCqsKCqsKCqv///////////////8KCqsKCqsKCqv///////////////////8KCqsKCqsKCqsKCqsKCqv///////8KCqsKCqsKCqsKCqsKCqv///////////8KCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqv///////////8KCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqv///////////////////8KCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqv///////////////////////////8KCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqv///////////////////////////////8KCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqv///////////////////////////8KCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqv///////////////////8KCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqv///////////8KCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqsKCqv///////////8KCqsKCqsKCqsKCqsKCqv///////8KCqsKCqsKCqsKCqsKCqv///////////////////8KCqsKCqsKCqv///////////////8KCqsKCqsKCqv///////////////////////////8KCqv///////////////////////8KCqv//////////////////////////////////////////////////////////////////////////////////wAA9+8AAOPHAADBgwAAgAEAAMADAADgBwAA8A8AAPAPAADgBwAAwAMAAIABAADBgwAA48cAAPfvAAD//wAAPCEtLQokKCdib2R5JykuZXEoMCkuY3NzKCd3aWR0aCcpCi0tPgo=" rel="icon" type="image/x-icon" />'
	echo "<H1>It is $ADB_DEVICE</H1>"
	echo '</HEAD><BODY bgcolor="#FFC89C">'
	echo '<H2>Device not available</H2>'
fi
echo '<meta http-equiv="refresh" content="15">'
echo '<TABLE BORDER=0>'
if [[ -d "$JOB_ROOT" ]]; then
    ls $JOB_ROOT | while read x
    do
	echo '<TR><TD>&#9658;&nbsp;'$x'</TD></TR>'
	echo '<TR><TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp'`head -1 $JOB_ROOT/$x`'</TD></TR>'
    done
fi
echo '</TABLE>'
echo '<HR>'
echo '<script type="text/javascript">'
echo '  <!--'
echo '  lastmod = document.lastModified     // get string of last modified date'
echo '  lastmoddate = Date.parse(lastmod)   // convert modified string to date'
echo '  if(lastmoddate == 0){               // unknown date (or January 1, 1970 GMT)'
echo '     document.writeln("Last Modified: Unknown")'
echo '     } else {'
echo '     document.writeln("Last Modified: " + lastmod)'
echo '  }// -->'
echo '</script>'
echo '</BODY></HTML>'
exit $rc
