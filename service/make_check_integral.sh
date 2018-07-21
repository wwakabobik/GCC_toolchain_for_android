#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    make_check_integral.sh
# Purpose: integral script to automate daily testing of MC
#
# Author:      Iliya Vereshchagin
#
# Created:     09.07.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------


if [ -z $1 ]; then
    device="Medfield"
else
    device=$1
fi

if [ -z $2 ]; then
    bits="32"
else
    bits=$2
fi

if [ -z $3 ]; then
    cur_date_image=`date +%Y``date +%m``date +%d`
else
    cur_date_image=$3
fi

cur_date=`date +%Y`_`date +%m`_`date +%d`

db_engine="sqlite3"
path_to_db="/nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions"
db_prefix="ndk_regressions_"
db_ext=".db"

hostname=`hostname`
compiler=(4.4.3 4.6.2 4.7.2 4.8.1 trunk)
hosts=(msticlxl100 msticlxl101 msticlxl102)
devices=(Medfield CloverTrail Merrifield GalaxyNexus Nexus4 HarrisBeach Merrifield_pr2)
declare -A Medfield_dev=([msticlxl101]="MedfieldE906493B" [msticlxl100]="MedfieldB12636D7")
declare -A CloverTrail_dev=([msticlxl102]="RHBEC245500390")
declare -A Merrifield_dev=([nc]="INV131700234" [msticlxl102]="INV131701015")
declare -A Merrifield_pr2_dev=([msticlxl101]="INV133601000" [msticlxl102]="INV131701015")
declare -A GalaxyNexus_dev=([msticlxl101]="0146AFFC18020012")
declare -A Nexus4_dev=([msticlxl100]="019270fc9908425c" [nc]="00289867da111923")
declare -A HarrisBeach_dev=([msticlxl102]="msticltz104.ims.intel.com:5555" [msticlxl100]="msticltz103.ims.intel.com:5555")
declare -A Image_Type=([Medfield]="MCG_eng" [CloverTrail]="MCG_eng" [Merrifield]="MCG_eng" [GalaxyNexus]="Vanilla" [Nexus4]="AOSP" [HarrisBeach]="MCG_eng" [Merrifield_pr2]="MCG_eng")
declare -A Test_Type=([Medfield]="NDK" [CloverTrail]="Image" [Merrifield]="Image" [GalaxyNexus]="NDK" [Nexus4]="Image" [HarrisBeach]="Image" [Merrifield_pr2]="Image")
declare -A Test_Type_db=([Medfield]=0 [CloverTrail]=1 [Merrifield]=1 [GalaxyNexus]=0 [Nexus4]=1 [HarrisBeach]=1)
declare -A Medfield_Freq_32=([4.4.3]=65535 [4.6.2]=6 [4.7.2]=65535 [4.8.1]=0 [trunk]=0)
declare -A Medfield_Freq_64=([4.4.3]=65535 [4.6.2]=6 [4.7.2]=65535 [4.8.1]=6 [trunk]=6)
declare -A CloverTrail_Freq_32=([4.4.3]=65535 [4.6.2]=6 [4.7.2]=65535 [4.8.1]=6 [trunk]=6)
declare -A CloverTrail_Freq_64=([4.4.3]=65535 [4.6.2]=13 [4.7.2]=65535 [4.8.1]=13 [trunk]=13)
declare -A Merrifield_Freq_32=([4.4.3]=65535 [4.6.2]=6 [4.7.2]=65535 [4.8.1]=6 [trunk]=6)
declare -A Merrifield_Freq_64=([4.4.3]=65535 [4.6.2]=13 [4.7.2]=65535 [4.8.1]=13 [trunk]=13)
declare -A GalaxyNexus_Freq_32=([4.4.3]=65535 [4.6.2]=6 [4.7.2]=65535 [4.8.1]=6 [trunk]=6)
declare -A GalaxyNexus_Freq_64=([4.4.3]=65535 [4.6.2]=13 [4.7.2]=65535 [4.8.1]=13 [trunk]=13)
declare -A Nexus4_Freq_32=([4.4.3]=65535 [4.6.2]=6 [4.7.2]=65535 [4.8.1]=6 [trunk]=6)
declare -A Nexus4_Freq_64=([4.4.3]=65535 [4.6.2]=13 [4.7.2]=65535 [4.8.1]=13 [trunk]=13)
declare -A HarrisBeach_Freq_32=([4.4.3]=65535 [4.6.2]=6 [4.7.2]=65535 [4.8.1]=6 [trunk]=6)
declare -A HarrisBeach_Freq_64=([4.4.3]=65535 [4.6.2]=13 [4.7.2]=65535 [4.8.1]=13 [trunk]=13)
declare -A flash_needed=([Medfield]=0 [CloverTrail]=1 [Merrifield]=1 [GalaxyNexus]=0 [Nexus4]=0 [HarrisBeach]=1)
declare -A flash_script=([Medfield]="" [CloverTrail]="/users/abantonx/AndroidTesting/scripts/build/flash_image_CTP.sh" [Merrifield]="/gnucwmnt/msticlxl102_users/abantonx/AndroidTesting/scripts/build/flash_image_merrifield.sh" [Merrifield_pr2]="/users/abantonx/AndroidTesting/scripts/build/flash_image_merrifield.sh" [GalaxyNexus]="" [Nexus4]="" [HarrisBeach]="/users/abantonx/AndroidTesting/scripts/build/flash_image_HarrisBeach.sh")
declare -A gcov_workaround=([Medfield]=0 [CloverTrail]=0 [Merrifield]=0 [GalaxyNexus]=1 [Nexus4]=1 [HarrisBeach]=0 [Merrifield_pr2]=0)
#ADDED
declare -A Merrifield_pr2_Freq_32=([4.4.3]=0 [4.6.2]=0 [4.7.2]=0 [4.8.1]=0 [trunk]=0)
declare -A Merrifield_pr2_Freq_64=([4.4.3]=0 [4.6.2]=0 [4.7.2]=0 [4.8.1]=0 [trunk]=0)

#host check
rc=0
for arg in ${hosts[*]}
do
    if [ "$hostname" == $arg ]; then
        rc=1
        break
    fi
done
if [ "$rc" != "1" ]; then
    echo "your host $hostname is not listed in supportable list"
    exit -1
fi

#device check
rc=0
for arg in ${devices[*]}
do
    if [ "$device" == $arg ]; then
        rc=1
        break
    fi
done
if [ "$rc" != "1" ]; then
    echo "your device $device is not listed in supportable list"
    exit -1
fi

#check againt connection to current host
device_sn="${device}_dev"
eval serial=\${$device_sn[$hostname]}
if [ -z $serial ]; then
    echo "no device $device connected to $hostname"
    exit -1
fi

export ANDROID_SERIAL=$serial

MONITOR="/nfs/ims/proj/icl/gcc_cw/share/monitor/monitor.sh -s $ANDROID_SERIAL -t 0 -m -j"
export PATH=/nfs/ims/proj/icl/gcc_cw/share/ADB:$PATH

adb -s shell "su -c 'chmod -R 777 /data/local'"

#if no user is specified, try to run under current
if [ -z $MC_USER ]; then
    export MC_User=$USER
fi

Frequencies="${device}_Freq_${bits}"

for arg in ${compiler[*]}
    do
    test_needed=0
    if [ "$arg" == "trunk" ]; then
        compiler_db="4.9.0"
    else
        compiler_db=$arg
    fi
    x=`$db_engine $path_to_db/$db_prefix$device$db_ext "select test_date from Summaries where ndk_version='$compiler_db' AND image_type='${Image_Type[$device]}' AND tested_object=${Test_Type_db[$device]} AND bits=$bits ORDER by test_date DESC LIMIT 1"`
    days=`$path_to_db/date_diff.sh $cur_date $x`
    rc=$?
    eval Frequency=\${$Frequencies[$arg]}
    if [ "$days" -ge $Frequency ]; then
        test_needed=1
    fi
    if [ "$rc" != "0" ] || [ "$test_needed" -eq "1" ]; then
        #make sure, that you have valid rsa-ssh.pub key and it's used for key auth
        for arg2 in ${hosts[*]}
        do
            if [ "$arg2" != "$hostname" ]; then
                ssh $arg2 ps aux | grep $MC_User | grep run_daily.sh | grep $arg | grep $device | grep ${Image_Type[$device]} | grep $bits | grep ${Test_Type[$device]} 1>/dev/null 2>/dev/null
                rc=$?
                if  [ "$rc" == "0" ]; then
                   break
                fi
            fi
        done
        if [ "$rc" != "0" ]; then
            rc=0
            if [ ${flash_needed[$device]} == 1 ]; then
                compiler_for_flash=`echo $compiler_db | sed 's/\..//2'`
                if [ "$compiler_for_flash" == "4.6" ] || [ "$compiler_for_flash" == "4.4" ] || [ "$compiler_for_flash" == "4.7" ]; then
                    compiler_for_flash="4.8"
                fi
                $MONITOR "${flash_script[$device]} $compiler_for_flash $cur_date_image $bits $serial"
                rc=$?
            fi
            if [ "$rc" != "0" ]; then
                echo "Image not found, MC aborted!"
            else
                #gcov workaround
                if [ ${gcov_workaround[$device]} == 1 ]; then
                    export GCOV_WORKAROUND=1
                fi
                $MONITOR "/users/$MC_User/MC_Daily/run_daily.sh $arg $device ${Test_Type[$device]} $bits ${Image_Type[$device]}" >>/users/$MC_User/MC_Daily/logs/$device/MC_${device}_${bits}_${arg}
                chmod ug+rw /users/$MC_User/MC_Daily/logs/$device/MC_${device}_${bits}_${arg}
            fi
        fi
    fi
done

pid=$$
rc=0

for arg2 in ${hosts[*]}
do
    #if [ "$arg2" != "$hostname" ]; then
        ssh $arg2 ps aux | grep -v "grep" | grep -v $pid | grep make_check_integral.sh 1>/dev/null 2>/dev/null
        rc=$?
        if  [ "$rc" == "0" ]; then
           exit 0
        fi
    #fi
done

$path_to_db/update_svn.sh
exit 0
