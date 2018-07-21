#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    check_stable_regression.sh
# Purpose: script checks and adds new failure into database. If test becomes
#          passed, then this test marked as non-regression and logged. If
#          regression detected during one day, then stored into file.
#          Database powered by SQLite engine
#
# Author:      Iliya Vereshchagin
#
# Created:     22.10.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------
y=`basename $0`
$ndebug echo "$y started with parameters:"
$ndebug echo "   $1"
$ndebug echo "   $2"
$ndebug echo "   $3"
$ndebug echo "   $4  $5  ${6}  ${7}"

if [ -z $1 ]; then
    cur_date=`date +%Y`_`date +%m`_`date +%d`
else
    cur_date=$1
fi

if [ -z $2 ]; then
    tablename="ndk462"
else
    tablename="$2"
fi

if [ -z $device_target_bits ]; then
    device_target_bits=32
fi

table_name="BadTests"

database=$3
compiler=$4
bits=$5
tested_object=${6}
image_type=${7}

path_to_ndk_regressions="/nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions"
filename_prefix="progressions_and_regressions_${tested_object}_${bits}_${image_type}_"
extension=".log"
new_columns="ndk_version,bits,tested_object,image_type"
temp_file="$path_to_ndk_regressions/$tablename/db_$bits.tmp"

#Check XFAILs
grep "XFAIL: " $path_to_ndk_regressions/$tablename/$filename_prefix$cur_date$extension | sed -e 's/.*XFAIL:\s//g' $temp_file >$temp_file $debug 2>/dev/null

while read line
do
    tmp=`echo ${line} | sed -e 's/\"/\ù/g'`
    line=`echo ${tmp} | sed -e 's/[ gcov]*$//' | sed -e 's/ gcov://'`
    status=`sqlite3 $path_to_ndk_regressions/$database "select * from $table_name where testname='$line' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
    echo $status | grep "/" $debug >/dev/null
    rc=`echo $?`
    #Test now XFAILs, inactivate regression
    if [ $rc = 0 ]; then
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set laststatuschanged=datetime('now') where testname='$line' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type' "`
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set activefail=0 where testname='$line' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
    fi
done < $temp_file

#Check FAILs
grep -v "XFAIL: " $path_to_ndk_regressions/$tablename/$filename_prefix$cur_date$extension | grep "FAIL: " | sed -e 's/.*FAIL:\s//g' >$temp_file $debug 2>/dev/null

while read line
do
    tmp=`echo ${line} | sed -e 's/\"/\ù/g'`
    echo ${tmp} | grep " gcov " $debug 1>/dev/null 2>/dev/null
    if [ "$?" -eq 0 ]; then
        tst_name=`expr "$line" : '^\(\S*\)'`
        line=$tst_name
    else
        line=$tmp
    fi
    status=`sqlite3 $path_to_ndk_regressions/$database "select * from $table_name where testname=\"${line}\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
    echo $status | grep "/" $debug >/dev/null
    rc=`echo $?`

    #Test now FAILs, confirm regression
    if [ $rc = 0 ]; then
        #test already exist
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set laststatuschanged=datetime('now') where testname=\"${line}\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set activefail=1 where testname=\"${line}\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set timesoccured=timesoccured+1 where testname=\"${line}\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
    else
        #new test
        status=`sqlite3 $path_to_ndk_regressions/$database "insert into $table_name (testname, $new_columns, status,activefail,timesoccured,laststatuschanged) values ('${line}', '$compiler',   $bits, $tested_object, '$image_type',  'FAIL',1,1,datetime('now'))"`
    fi
done < $temp_file

#Check UNRESOLVEDs
grep "UNRESOLVED: " $path_to_ndk_regressions/$tablename/$filename_prefix$cur_date$extension | sed -e 's/.*UNRESOLVED:\s//g' >$temp_file $debug 2>/dev/null

while read line
do
    tmp=`echo ${line} | sed -e 's/\"/\ù/g'`
    echo ${tmp} | grep " gcov " $debug 1>/dev/null 2>/dev/null
    if [ "$?" -eq 0 ]; then
        tst_name=`expr "$line" : '^\(\S*\)'`
        line=$tst_name
    else
        line=$tmp
    fi
    status=`sqlite3 $path_to_ndk_regressions/$database "select * from $table_name where testname=\"$line\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
    echo $status | grep "/" $debug >/dev/null
    rc=`echo $?`
    #Test now UNRESOLVED, confirm regression
    if [ $rc = 0 ]; then
        #test already exist
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set laststatuschanged=datetime('now') where testname=\"${line}\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set activefail=1 where testname=\"${line}\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set timesoccured=timesoccured+1 where testname=\"${line}\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
    else
        #new test
        status=`sqlite3 $path_to_ndk_regressions/$database "insert into $table_name (testname, $new_columns,  status,activefail,timesoccured,laststatuschanged) values ('$line', '$compiler',   $bits, $tested_object, '$image_type',  'UNRESOLVED',1,1,datetime('now'))"`
    fi
done < $temp_file

#Check XPASSes
grep "XPASS: " $path_to_ndk_regressions/$tablename/$filename_prefix$cur_date$extension | sed -e 's/.*XPASS:\s//g' >$temp_file $debug 2>/dev/null

while read line
do
    tmp=`echo ${line} | sed -e 's/\"/\ù/g'`
    echo ${tmp} | grep " gcov " $debug 1>/dev/null 2>/dev/null
    if [ "$?" -eq 0 ]; then
        tst_name=`expr "$line" : '^\(\S*\)'`
        line=$tst_name
    else
        line=$tmp
    fi
    status=`sqlite3 $path_to_ndk_regressions/$database "select * from $table_name where testname='$line'"`
    echo $status | grep "/" $debug >/dev/null
    rc=`echo $?`
    #Test now XPASSes, confirm regression
    if [ $rc = 0 ]; then
        #test already exist
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set laststatuschanged=datetime('now') where testname=\"${line}\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set activefail=1 where testname=\"${line}\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set timesoccured=timesoccured+1 where testname=\"${line}\" AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
    else
        #new test
        status=`sqlite3 $path_to_ndk_regressions/$database "insert into $table_name (testname,  $new_columns,  status,activefail,timesoccured,laststatuschanged) values ('$line', '$compiler',   $bits, $tested_object, '$image_type',   'XPASS',1,1,datetime('now'))"`
    fi
done < $temp_file

#Check PASSes
grep -v "XPASS: " $path_to_ndk_regressions/$tablename/$filename_prefix$cur_date$extension | grep "PASS: " | sed -e 's/.*PASS:\s//g' >$temp_file $debug 2>/dev/null

while read line
do
    tmp=`echo ${line} | sed -e 's/\"/\ù/g'`
    echo ${tmp} | grep " gcov " $debug 1>/dev/null 2>/dev/null
    if [ "$?" -eq 0 ]; then
        tst_name=`expr "$line" : '^\(\S*\)'`
        line=$tst_name
    else
        line=$tmp
    fi
    status=`sqlite3 $path_to_ndk_regressions/$database "select * from $table_name where testname='${line}' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
    echo $status | grep "/" $debug >/dev/null
    rc=`echo $?`

    #Test now PASSes, inactivate regression
    if [ $rc = 0 ]; then
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set laststatuschanged=datetime('now') where testname='${line}' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set activefail=0 where testname='${line}' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
    fi
done < $temp_file

#Check UNSUPPORTED
grep  "UNSUPPORTED: " $path_to_ndk_regressions/$tablename/$filename_prefix$cur_date$extension | sed -e 's/.*UNSUPPORTED:\s//g' >$temp_file $debug 2>/dev/null

while read line
do
    tmp=`echo ${line} | sed -e 's/\"/\ù/g'`
    line=`echo ${tmp} | sed -e 's/\([^ gcov]\) .*/\1/' | sed -e 's/ gcov://'`
    rc=0
    rc=`echo $?`

    #Test now UNSUPPORTED, inactivate regression
    if [ $rc = 0 ]; then
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set laststatuschanged=datetime('now') where testname LIKE '${line}%' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
        status=`sqlite3 $path_to_ndk_regressions/$database "update $table_name set activefail=0 where testname LIKE '${line}%' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type'  "`
    fi
done < $temp_file

status=`sqlite3 $path_to_ndk_regressions/$database "select status,timesoccured,testname,laststatuschanged from $table_name where laststatuschanged<datetime('now','-1 day') AND activefail=1 AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type' " >$path_to_ndk_regressions/$tablename/stable_regression_${tested_object}_${bits}_$image_type.log`

status=`sqlite3 $path_to_ndk_regressions/$database "select status,testname from $table_name where laststatuschanged<datetime('now','-2 day') AND activefail=1 AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type' " >$path_to_ndk_regressions/$tablename/stable_bugs_${tested_object}_${bits}_$image_type.log`

sort -o $path_to_ndk_regressions/$tablename/stable_bugs_${tested_object}_${bits}_$image_type.log  $path_to_ndk_regressions/$tablename/stable_bugs_${tested_object}_${bits}_$image_type.log

rm $temp_file $debug 1>/dev/null 2>/dev/null

exit 0