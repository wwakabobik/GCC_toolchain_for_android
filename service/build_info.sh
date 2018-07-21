#!/bin/sh

#-------------------------------------------------------------------------------
# Name:    build_info.sh
# Purpose: This script monitors build status of ndk and images. Script scans files
#          within out dirs on related hosts and related devices/NDKs and then compare
#          with demanded frequency of rebuild for this type of build (bits, type).
#          This script called from monitor.sh script and it's output should be redirected
#          to html file. If you wanna add image or change scan folders/hosts, please
#          do it via related arrays.
#
# Author:      Alina Govorova, Ilya Vereschagin
#
# Created:     31.01.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

cur_date=`date +%Y``date +%m``date +%d`

linux_builder="gnucwtester"
macos_builder="gnucwtester"
shareDir=/nfs/ims/proj/icl/gcc_cw/share
log_dir=$shareDir/NDK_Testing
if [ -z $1 ]; then
    out_file=build.info.tmp
else
    out_file=$1
fi
log_suffix="log"
image_suffix="builds/images"
ndk_suffix="builds/ndk"

bits_host=(32 64)
bits_target=(32)
ndk_array=(ndk_Linux ndk_Windows ndk_Mac)
platforms=(Linux MacOS)
device_array=(CloverTrail Merrifield HarrisBeach Nexus4 AOSP_Linux AOSP_MacOS)
compilers_array=(4_8 4_9)
declare -A device_build=([CloverTrail]="Linux" [Merrifield]="Linux" [HarrisBeach]="Linux" [Nexus4]="Linux" [AOSP_Linux]="Linux" [AOSP_MacOS]="MacOS")
declare -A images_folder=([CloverTrail]="redhookbay" [Merrifield]="merrifield" [HarrisBeach]="OTC" [AOSP_Linux]="AOSP" [AOSP_MacOS]="AOSP" [Nexus4]="AOSP_mako")
declare -A alias_array=([CloverTrail]="redhookbay-ota" [Merrifield]="saltbay-ota" [HarrisBeach]="core_ufo" [AOSP_Linux]="system.img"  [AOSP_MacOS]="system.img" [Nexus4]="full_mako-img-eng" [ndk_Linux]="linux-x86.tar.bz2" [ndk_Mac]="darwin-x86.tar.bz2" [ndk_Windows]="windows-x86.zip")
declare -A host_array=([CloverTrail]="msticlxl102" [Merrifield]="msticlxl102" [HarrisBeach]="msticlxl102" [AOSP_Linux]="msticlxl101" [AOSP_MacOS]="msticlem102" [Nexus4]="msticlxl101" [ndk_Mac]="msticlem102" [ndk_Linux]="msticlxl102" [ndk_Windows]="msticlxl102")
declare -A folder_array=([CloverTrail]="/users/$linux_builder/AndroidTesting/$image_suffix" [Merrifield]="/users/$linux_builder/AndroidTesting/$image_suffix" [HarrisBeach]="/users/$linux_builder/AndroidTesting/$image_suffix" [AOSP_Linux]="/users/$linux_builder/AndroidTesting/$image_suffix" [Nexus4]="/users/$linux_builder/AndroidTesting/$image_suffix" [AOSP_MacOS]="/users/$macos_builder/AndroidTesting/$image_suffix" [ndk_Linux]="/users/$linux_builder/AndroidTesting/$ndk_suffix" [ndk_Windows]="/users/$linux_builder/AndroidTesting/$ndk_suffix" [ndk_Mac]="/users/$macos_builder/AndroidTesting/$ndk_suffix")
declare -A log_array=([CloverTrail]="/users/$linux_builder/AndroidTesting/$log_suffix" [Merrifield]="/users/$linux_builder/AndroidTesting/$log_suffix" [HarrisBeach]="/users/$linux_builder/AndroidTesting/$log_suffix" [AOSP_Linux]="/users/$linux_builder/AndroidTesting/$log_suffix" [Nexus4]="/users/$linux_builder/AndroidTesting/$log_suffix" [AOSP_MacOS]="/users/$macos_builder/AndroidTesting/$log_suffix" [ndk_Linux]="/users/$linux_builder/AndroidTesting/$log_suffix" [ndk_Windows]="/users/$linux_builder/AndroidTesting/$log_suffix" [ndk_Mac]="/users/$macos_builder/AndroidTesting/$log_suffix")

#32
declare -A ndk_freq_array_32=([ndk_Linux]="1" [ndk_Windows]="1" [ndk_Mac]="1")
declare -A CloverTrail_freq_array_32=([4_6]="65535" [4_7]="1" [4_8]="1" [4_9]="1")
declare -A Merrifield_freq_array_32=([4_6]="65535" [4_7]="1" [4_8]="1" [4_9]="1")
declare -A HarrisBeach_freq_array_32=([4_6]="65535" [4_7]="1" [4_8]="1" [4_9]="1")
declare -A AOSP_Linux_freq_array_32=([4_6]="65535" [4_7]="1" [4_8]="1" [4_9]="1")
declare -A AOSP_MacOS_freq_array_32=([4_6]="65535" [4_7]="1" [4_8]="1" [4_9]="1")
declare -A Nexus4_freq_array_32=([4_6]="65535" [4_7]="7" [4_8]="7" [4_9]="7")
#64
declare -A ndk_freq_array_64=([ndk_Linux]="7" [ndk_Windows]="7" [ndk_Mac]="7")
declare -A CloverTrail_freq_array_64=([4_6]="65535" [4_7]="7" [4_8]="7" [4_9]="7")
declare -A Merrifield_freq_array_64=([4_6]="65535" [4_7]="7" [4_8]="7" [4_9]="7")
declare -A HarrisBeach_freq_array_64=([4_6]="65535" [4_7]="7" [4_8]="7" [4_9]="7")
declare -A AOSP_Linux_freq_array_64=([4_6]="65535" [4_7]="7" [4_8]="7" [4_9]="7")
declare -A AOSP_MacOS_freq_array_64=([4_6]="65535" [4_7]="7" [4_8]="7" [4_9]="7")
declare -A Nexus4_freq_array_64=([4_6]="65535" [4_7]="7" [4_8]="7" [4_9]="7")

echo "<HTML><HEAD><TITLE>Build Info</TITLE></HEAD><BODY>" >${shareDir}/${out_file}

#NDK Current data

echo "<div id=\"content\" style=\"height:350px;width:280px;float:left;word-wrap:break-word;\"><HR>" >>${shareDir}/${out_file}
echo "<font size=\"3\"><b>NDK current info:</b></font>" >>${shareDir}/${out_file}
echo "<br>" >>${shareDir}/${out_file}
echo "<font size=\"2\">$shareDir/NDK_current*</font>" >>${shareDir}/${out_file}
echo "<br>" >>${shareDir}/${out_file}
echo "<table border=\"1\" cellpadding=\"3\" cellspacing=\"0\" width=\"260px\" bgcolor=\"#fff\">" >>${shareDir}/${out_file}
echo "<tr align=\"center\" bgcolor=\"#C0C0C0\">" >>${shareDir}/${out_file}
echo "<th>Date</th><th>Versions</th><th>Bits</th>" >>${shareDir}/${out_file}
echo "</tr>" >>${shareDir}/${out_file}

for bits in ${bits_host[*]}
do
    if [ "$bits" != "32" ]; then
        bits_add="_${bits}"
    fi
    ndk_cur_date=$(cd $shareDir && ls NDK_current${bits_add} | cut -d- -f 3)
    if [ ! -z $ndk_cur_date ]; then
        days=`$shareDir/monitor/date_diff.sh $ndk_cur_date $cur_date`
    else
        days="65535"
        color="LightCoral"
    fi
    if [ ! -z $days ]; then
        if [ "$days" -ge "1" ]; then
            color="LightCoral"
        else
            color="LawnGreen"
        fi
    fi
    echo "<tr>" >>${shareDir}/${out_file}
    echo "<td bgcolor="$color">$ndk_cur_date</td>" >>${shareDir}/${out_file}
    echo "<td bgcolor="$color">4.6 - 4.9</td>" >>${shareDir}/${out_file}
    echo "<td bgcolor="$color">$bits</td>" >>${shareDir}/${out_file}
    echo "</tr>" >>${shareDir}/${out_file}
done

echo "</table>" >>${shareDir}/${out_file}
echo "</div>" >>${shareDir}/${out_file}

#NDK data

echo "<div id=\"content\" style=\"height:350px;width:300px;float:left;word-wrap:break-word;\"><HR>" >>${shareDir}/${out_file}
echo "<font size=\"3\"><b>NDK info:</b></font>" >>${shareDir}/${out_file}
echo "<br>" >>${shareDir}/${out_file}
echo "<font size=\"2\">Linux: ${host_array[ndk_Linux]} : ${folder_array[ndk_Linux]}</font>" >>${shareDir}/${out_file}
echo "<br>" >>${shareDir}/${out_file}
echo "<font size=\"2\">Windows: ${host_array[ndk_Windows]} : ${folder_array[ndk_Windows]}</font>" >>${shareDir}/${out_file}
echo "<br>" >>${shareDir}/${out_file}
echo "<font size=\"2\">Mac: ${host_array[ndk_Mac]} : ${folder_array[ndk_Mac]}</font>" >>${shareDir}/${out_file}
echo "<br>" >>${shareDir}/${out_file}
echo "<table border=\"1\" cellpadding=\"3\" cellspacing=\"0\" width=\"275px\" bgcolor=\"#fff\">" >>${shareDir}/${out_file}
echo "<tr align=\"center\" bgcolor=\"#C0C0C0\">" >>${shareDir}/${out_file}
echo "<th>Date</th><th>Versions</th><th>Platform</th><th>Bits</th>" >>${shareDir}/${out_file}
echo "</tr>" >>${shareDir}/${out_file}

for bits in ${bits_host[*]}
do
    for ndk in ${ndk_array[*]}
    do
        addition=""
        Frequencies="ndk_freq_array_${bits}"
        if [ "$bits" == "64" ]; then
            pattern=`echo ${alias_array[$ndk]} | sed -r 's/86/86_64/g'`
        else
            pattern=${alias_array[$ndk]}
        fi
        command="cd ${folder_array[$ndk]} && ls * | grep ${pattern} | tail -1 | cut -d- -f 3"
        ndk_date=$( ssh ${host_array[$ndk]} "$command" )
        if [ ! -z $ndk_date ]; then
            days=`$shareDir/monitor/date_diff.sh $ndk_date $cur_date`
            if [ ! -z $days ]; then
                eval Frequency=\${$Frequencies[$ndk]}
                if [ "$days" -ge "$Frequency" ]; then
                    color="LightCoral"
                    pattern="*_build_ndk_${bits}.log"
                    command="cd ${log_array[$ndk]} && ls $pattern 2>/dev/null | tail -1"
                    recent_log=`ssh ${host_array[$ndk]} $command`
                    if [ ! -z $recent_log ]; then
                        command="cd ${log_array[$ndk]} && grep \"ERROR:\" ${recent_log} 1>/dev/null"
                        ssh ${host_array[$ndk]} $command
                        if [ $? == 0 ]; then
                            if [ ! -f $log_dir/Build/NDK/$recent_log ]; then
                                command="cd ${log_array[$ndk]} && cp $recent_log $log_dir/Build/Image"
                                ssh ${host_array[$ndk]} $command
                                if [ $? == 0 ]; then
                                    addition="<a href='$log_dir/Build/NDK/$recent_log'>*</a>"
                                fi
                            else
                                addition="<a href='$log_dir/Build/NDK/$recent_log'>*</a>"
                            fi
                        fi
                    fi
                else
                    color="LawnGreen"
                fi
            fi
        else
            days="65535"
            color="LightCoral"
        fi
            platform=`echo $ndk | sed -r 's/ndk_//g'`
            echo "<tr>" >>${shareDir}/${out_file}
            echo "<td bgcolor="$color">$ndk_date $addition</td>" >>${shareDir}/${out_file}
            echo "<td bgcolor="$color">4.6 - 4.9</td>" >>${shareDir}/${out_file}
            echo "<td bgcolor="$color">$platform</td>" >>${shareDir}/${out_file}
            echo "<td bgcolor="$color">$bits</td>" >>${shareDir}/${out_file}
            echo "</tr>" >>${shareDir}/${out_file}
    done
done

echo "</table>" >>${shareDir}/${out_file}
echo "</div>" >>${shareDir}/${out_file}

bit_length_host=${#bits_host[@]}
bit_length_target=${#bits_target[@]}
compiler_length=${#compilers_array[@]}
let 'bits_top_length = compiler_length * bit_length_target'

#Generate Header
echo "<div id=\"content\" style=\"height:350px;width:300px;float:left;word-wrap:break-word;\"><HR>" >>${shareDir}/${out_file}
echo "<font size=\"3\"><b>Images info:</b></font>" >>${shareDir}/${out_file}
echo "<table border=\"1\" cellpadding=\"3\" cellspacing=\"0\" width=\"200px\" bgcolor=\"#fff\">" >>${shareDir}/${out_file}
#echo "<tr align=\"center\" bgcolor=\"#C0C0C0\">" >>${shareDir}/${out_file}
#echo "</tr><tr bgcolor=\"#C0C0C0\" align=\"center\">" >>${shareDir}/${out_file}
echo "<tr bgcolor=\"#C0C0C0\" align=\"center\">" >>${shareDir}/${out_file}
echo "<td rowspan=\"1\" colspan=\"2\"><b>Host</b></td>" >>${shareDir}/${out_file}
for bits_h in ${bits_host[*]}
do
    echo "<td colspan=\"${bits_top_length}\"><b>$bits_h</b></td>" >>${shareDir}/${out_file}
done
echo "</tr><tr bgcolor=\"#C0C0C0\" align=\"center\">" >>${shareDir}/${out_file}
echo "<td colspan=\"2\"><b>Target</b></td>" >>${shareDir}/${out_file}
for bits_h in ${bits_host[*]}
do
    for bits_t in ${bits_target[*]}
    do
        echo "<td colspan=\"${compiler_length}\"><b>$bits_t</b></td>" >>${shareDir}/${out_file}
    done
done
echo "</tr><tr bgcolor=\"#C0C0C0\" align=\"center\">" >>${shareDir}/${out_file}
echo "<td><b>Build Host</b></td>" >>${shareDir}/${out_file}
echo "<td><b>Compiler / Device</b></td>" >>${shareDir}/${out_file}
for bits_h in ${bits_host[*]}
do
    for bits_t in ${bits_target[*]}
    do
        for compiler in ${compilers_array[*]}
        do
            cc=`echo $compiler | sed -r 's/_/\./g'`
            echo "<td colspan=1><b>$cc</b></td>" >>${shareDir}/${out_file}
        done
    done
done
echo "</tr>" >>${shareDir}/${out_file}

#generate data
for device in ${device_array[*]}
do
    for platform in ${platforms[*]}
    do
        if [ "${device_build[$device]}" == "$platform" ]; then
            devn=`echo $device | sed -r 's/_Linux//g' | sed -r 's/_MacOS//g'` #delete OS suffix
            echo "<tr><td bgcolor=\"#C0C0C0\" align=\"center\"><b>$platform</b></td><td bgcolor=\"#C0C0C0\" align=\"center\"><b>$devn</b></td>" >>${shareDir}/${out_file}
            for bits_h in ${bits_host[*]}
            do
                for bits_t in ${bits_target[*]}
                do
                    for compiler in ${compilers_array[*]}
                    do
                        addition=""
                        #LastImage="${host_array[$device]}/${folder_array[$device]}"
                        Frequencies="${device}_freq_array_${bits_h}"
                        cc=`echo $compiler | sed -r 's/_/\./g'`
                        command="cd ${folder_array[$device]} && ls -d *_${cc}/${images_folder[$device]}_${bits_h} 2>/dev/null | tail -1 | cut -d_ -f 1"
                        image_date=$( ssh ${host_array[$device]} $command )
                        if [ ! -z $image_date ]; then
                            command="cd ${folder_array[$device]} && ls ${image_date}_${cc}/${images_folder[$device]}_${bits_h}/* 2>/dev/null | grep ${alias_array[$device]} 1>/dev/null 2>/dev/null"
                            ssh ${host_array[$device]} $command
                            if [ $? == 0 ]; then
                                days=`$shareDir/monitor/date_diff.sh $image_date $cur_date`
                            else
                                days="65535"
                                color="LightCoral"
                            fi
                        else
                            days="65535"
                            color="LightCoral"
                        fi
                        if [ ! -z $days ]; then
                            eval Frequency=\${$Frequencies[$compiler]}
                            if [ "$days" -ge "$Frequency" ]; then
                                color="LightCoral"
                                pattern="*-${cc}-${images_folder[$device]}_${bits_h}.log"
                                pattern="*-${cc}-${images_folder[$device]}.log"
                                command="cd ${log_array[$device]} && ls $pattern 2>/dev/null | tail -1"
                                recent_log=`ssh ${host_array[$device]} $command`
                                if [ ! -z $recent_log ]; then
                                    command="cd ${log_array[$device]} && grep \" Error \" ${recent_log} 1>/dev/null"
                                    ssh ${host_array[$device]} $command
                                    if [ $? == 0 ]; then
                                        if [ ! -f $log_dir/Build/Image/$recent_log ]; then
                                            command="cd ${log_array[$device]} && cp $recent_log $log_dir/Build/Image"
                                            ssh ${host_array[$device]} $command
                                            if [ $? == 0 ]; then
                                                addition="<a href='$log_dir/Build/Image/$recent_log'>*</a>"
                                            fi
                                        else
                                            addition="<a href='$log_dir/Build/Image/$recent_log'>*</a>"
                                        fi
                                    fi
                                fi
                            else
                                color="LawnGreen"
                            fi
                            LastImage="${host_array[$device]}/${folder_array[$device]}/${image_date}_${cc}/${images_folder[$device]}_${bits_h}/"
                            image_date="<a href='$LastImage'>$image_date</a>"
                        fi
                        echo "<td bgcolor=\"$color\"><NOBR>$image_date $addition</NOBR></td>" >>${shareDir}/${out_file}
                    done
                done
            done
            echo "</tr>" >>${shareDir}/${out_file}
        fi
    done
done
echo "</table>" >>${shareDir}/${out_file}

echo "<BR><BR><HR><div id=\"footer\" style=\"clear:both;\">" >>${shareDir}/${out_file}
echo "<meta http-equiv=\"refresh\" content=\"60\">" >>${shareDir}/${out_file}
echo "$(date)" >>${shareDir}/${out_file}
echo "</div>" >>${shareDir}/${out_file}
echo "</BODY></HTML>" >>${shareDir}/${out_file}

cat ${shareDir}/${out_file}
rm  ${shareDir}/${out_file}

exit 0
