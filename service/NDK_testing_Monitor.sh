#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    NDK_testing_Monitor.sh
# Purpose: Monitors status of NDK and Bionic testing
#
# Author:      Iliya Vereshchagin
#
# Created:     29.10.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

IndexOf()    {
    local i=1 S=$1; shift
    while [ $S != $1 ]
    do    ((i++)); shift
        [ -z "$1" ] && { i=0; break; }
    done
    echo $i
}

TestNeeded() {
    TNbshift=$1
    TNbcode=$2
    let 'TNbshift -= 1'
    let 'needed = TNbcode >> TNbshift'
    let 'needed &= 1'
    echo $needed
}

cur_date=`date +%Y`_`date +%m`_`date +%d`

share=/nfs/ims/proj/icl/gcc_cw/share
log_folder=$share/NDK_Testing
ndk_linux_test_user="gnucwtester"
ndk_macos_test_user="gnucwtester"
ndk_windows_test_user="gnucwtester"
path_to_results=/users/$ndk_linux_test_user/AndroidTesting/results

path_to_diff="/nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions"

bits_supported=(32 64)
compiler=(4.6 4.8 4.9)
#Medfield GalaxyNexus Nexus4 are not supported
#we can use arm devices too, there is no complexity here, actually
types_of_test=(NDK Bionic_static Bionic_dynamic)
#types_of_test=(Bionic_static Bionic_dynamic)
platforms=(Linux MacOS Windows)
devices=(Emulator CloverTrail Merrifield HarrisBeach)
declare -A test_to_run=([Linux]=7 [MacOS]=7 [Windows]=1)
declare -A test_needed=([NDK]=15 [Bionic_static]=1 [Bionic_dynamic]=1)
declare -A parse_command=([NDK]="/FAIL/{print x;next}{x=\$0;}" [Bionic_static]="/FAILED\\ TEST/{p=0};p;/below:/{p=1}" [Bionic_dynamic]="/FAILED\\ TEST/{p=0};p;/below:/{p=1}")
declare -A host_array=([Linux]='msticlxl102' [MacOS]='msticlem102' [Windows]='msticlxl102')
declare -A platform_path=([Linux]="/users/$ndk_linux_test_user/AndroidTesting/results" [MacOS]="/users/$ndk_macos_test_user/AndroidTesting/results" [Windows]="/users/$ndk_windows_test_user/AndroidTesting/results")
declare -A NDK_platform_pattern=([Linux]="*NDK_linux_tests.log" [MacOS]="*NDK_darwin_tests.log" [Windows]="*NDK_windows_tests.log" )
declare -A Bionic_static_platform_pattern=([Linux]="*_static.log" [MacOS]="*_static.log" [Windows]="*_static.log" )
declare -A Bionic_dynamic_platform_pattern=([Linux]="*_dynamic.log" [MacOS]="*_dynamic.log" [Windows]="*_dynamic.log" )

#Devices
#32
#declare -A Medfield_32_dev=([Linux]="MedfieldE906493B" [nc2]="MedfieldB12636D7")
declare -A CloverTrail_32_dev=([Linux]="RHBEC244100327" [nc1]="RHBEC244100327")
declare -A Merrifield_32_dev=([nc1]="INV131700234" [nc2]="INV131701015" [Linux]="INV133600823")
#declare -A GalaxyNexus_32_dev=([nc1]="0146AFFC18020012")
#declare -A Nexus4_32_dev=([nc1]="019270fc9908425c" [nc2]="00289867da111923")
declare -A HarrisBeach_32_dev=([Linux]="msticltz104.ims.intel.com:5555" [nc2]="msticltz103.ims.intel.com:5555")
declare -A Emulator_32_dev=([Linux]="emulator-*" [Windows]="emulator-*" [MacOS]="emulator-*")
#64
#declare -A Medfield_64_dev=([nc1]="MedfieldE906493B" [nc2]="MedfieldB12636D7")
declare -A CloverTrail_64_dev=([Linux]="RHBEC244100327")
declare -A Merrifield_64_dev=([nc1]="INV131700234" [nc2]="INV131701015" [Linux]="INV133600823")
#declare -A GalaxyNexus_64_dev=([nc1]="0146AFFC18020012")
#declare -A Nexus4_64_dev=([nc1]="019270fc9908425c" [nc2]="00289867da111923")
declare -A HarrisBeach_64_dev=([Linux]="msticltz104.ims.intel.com:5555" [nc2]="msticltz103.ims.intel.com:5555")
declare -A Emulator_64_dev=([Linux]="emulator-*" [Windows]="emulator-*" [MacOS]="emulator-*")


#Frequencies
#Linux
#declare -A Linux_Medfield_Freq_32=([4.6]=65535 [4.7]=65535 [4.8]=65535 [4.9]=65535)
#declare -A Linux_Medfield_Freq_64=([4.6]=65535 [4.7]=65535 [4.8]=65535 [4.9]=65535)
declare -A Linux_CloverTrail_Freq_32=([4.6]=7 [4.7]=1 [4.8]=1 [4.9]=1)
declare -A Linux_CloverTrail_Freq_64=([4.6]=7 [4.7]=7 [4.8]=7 [4.9]=7)
declare -A Linux_Merrifield_Freq_32=([4.6]=1 [4.7]=1 [4.8]=1 [4.9]=1)
declare -A Linux_Merrifield_Freq_64=([4.6]=7 [4.7]=7 [4.8]=7 [4.9]=7)
#declare -A Linux_GalaxyNexus_Freq_32=([4.6]=65535 [4.7]=65535 [4.8]=65535 [4.9]=65535)
#declare -A Linux_GalaxyNexus_Freq_64=([4.6]=65535 [4.7]=65535 [4.8]=65535 [4.9]=65535)
#declare -A Linux_Nexus4_Freq_32=([4.6]=65535 [4.7]=65535 [4.8]=65535 [4.9]=65535)
#declare -A Linux_Nexus4_Freq_64=([4.6]=65535 [4.7]=65535 [4.8]=65535 [4.9]=65535)
declare -A Linux_HarrisBeach_Freq_32=([4.6]=1 [4.7]=1 [4.8]=1 [4.9]=1)
declare -A Linux_HarrisBeach_Freq_64=([4.6]=7 [4.7]=7 [4.8]=7 [4.9]=7)
declare -A Linux_Emulator_Freq_32=([4.6]=1 [4.7]=1 [4.8]=1 [4.9]=1)
declare -A Linux_Emulator_Freq_64=([4.6]=1 [4.7]=1 [4.8]=1 [4.9]=1)
#MacOS
declare -A MacOS_Emulator_Freq_32=([4.6]=1 [4.7]=1 [4.8]=1 [4.9]=1)
declare -A MacOS_Emulator_Freq_64=([4.6]=1 [4.7]=1 [4.8]=1 [4.9]=1)
#Windows
declare -A Windows_Emulator_Freq_32=([4.6]=7 [4.7]=2 [4.8]=2 [4.9]=2)
declare -A Windows_Emulator_Freq_64=([4.6]=7 [4.7]=7 [4.8]=7 [4.9]=7)


echo "<HTML><HEAD><TITLE>NDK testing results</TITLE>"
echo "<style type=\"text/css\">"
echo "a {"
echo "   font-size: 60%;"
echo "   font-family: Verdana, Arial, Helvetica, sans-serif;"
echo "}"
echo "</style>"
echo "</HEAD><BODY>"

bit_length=${#bits_supported[@]}
compiler_length=${#compiler[@]}
let 'platform_length = compiler_length * bit_length'

#Print top table

for type_of_test in ${types_of_test[*]}
do
    sbitcode=${test_needed[$type_of_test]}
    pcom=${parse_command[$type_of_test]}
    echo "<H1>$type_of_test testing results</H1>"
    echo "<TABLE  border='1' cellpadding='3' cellspacing='0' width='360px'>"
    echo "<TR bgcolor=\"#C0C0C0\" align=\"center\"><TD><b>Platform</b></TD>"
    for platform in ${platforms[*]}
    do
        bitcode=${test_to_run[$platform]}
        bitshift=`IndexOf $type_of_test ${types_of_test[@]}`
        needed=`TestNeeded $bitshift $bitcode`
        if [ "$needed" == "0" ]; then
           continue
        fi
        echo "<TD colspan=$platform_length><b>$platform</b></TD>"
    done
    echo "</TR>"
    echo "<TR bgcolor=\"#C0C0C0\" align=\"center\">"
    echo "<TR bgcolor=\"#C0C0C0\" align=\"center\"><TD><b>Bits</b></TD>"

    for platform in ${platforms[*]}
    do
        bitcode=${test_to_run[$platform]}
        bitshift=`IndexOf $type_of_test ${types_of_test[@]}`
        needed=`TestNeeded $bitshift $bitcode`
        if [ "$needed" == "0" ]; then
           continue
        fi
        for bits in ${bits_supported[*]}
        do
            echo "<TD colspan=$compiler_length><b>$bits</b></TD>"
        done
    done
        echo "</TR>"
        echo "<TD bgcolor=\"#C0C0C0\" align=\"center\"><b>Compiler / Device</b></TD>"
    for platform in ${platforms[*]}
    do
        bitcode=${test_to_run[$platform]}
        bitshift=`IndexOf $type_of_test ${types_of_test[@]}`
        needed=`TestNeeded $bitshift $bitcode`
        if [ "$needed" == "0" ]; then
            continue
        fi
        for bits in ${bits_supported[*]}
        do
            for arg in ${compiler[*]}
            do
                echo "<TD bgcolor=\"#C0C0C0\" align=\"center\"><b>$arg</b></TD>"
            done
        done
    done
        echo "</TR>"
    #content
    for arg in ${devices[*]}
    do
        sbitcode=${test_needed[$type_of_test]}
        bshift=`IndexOf $arg ${devices[@]}`
        needed=`TestNeeded $bshift $sbitcode`
        if [ "$needed" == "1" ]; then
            echo "<TR><TD bgcolor=\"#C0C0C0\" align=\"center\"><b>$arg</b></TD>"
        else
             continue
        fi
        for platform in ${platforms[*]}
        do
            Frequencies="${platform}_${arg}_Freq_${bits}"
            bitcode=${test_to_run[$platform]}
            bitshift=`IndexOf $type_of_test ${types_of_test[@]}`
            needed=`TestNeeded $bitshift $bitcode`
            if [ "$needed" == "0" ]; then
               continue
            fi
            tot_dir=`echo $type_of_test | sed 's/_static//' | sed 's/_dynamic//'`
            ssh_comm="ssh ${host_array[$platform]}"
            pattern=${platform_pattern[$platform]}
            eval pattern=\${${type_of_test}_platform_pattern[$platform]}
            path_to_platform=${platform_path[$platform]}
            path_to_device_test="$path_to_platform/$tot_dir"
            for bits in ${bits_supported[*]}
            do
                true_device="${arg}_${bits}_dev"
                eval true_device_name=\${$true_device[$platform]}
                if [ -z $true_device_name ]; then
                    continue #debug
                elif [ "$true_device_name" == "na" ]; then
                    true_device_name=""
                fi
                for arg2 in ${compiler[*]}
                do
                    reg=""
                    prog=""
                    color="White"
                    fail_log=""
                    command=${arg2}/${bits}/${true_device_name}/${pattern}
                    logfile=${path_to_device_test}/`ssh ${host_array[$platform]} "cd ${path_to_device_test} 2>/dev/null && ls */$command 2>/dev/null | tail -1"`
                    oldfile=`ls $log_folder/Devices/${arg}_${platform}_${bits}_${arg2}_*.regression.log 2>/dev/null | tail -2 | head -1 `
                    x=`ssh ${host_array[$platform]} "cd ${path_to_device_test} 2>/dev/null && ls */$command 2>/dev/null | tail -1 | cut -d/ -f 1 | sed 's/^\(......\)/\1_/' | sed 's/^\(....\)/\1_/'"`
                    outfile="$log_folder/$type_of_test/${arg}_${platform}_${bits}_${arg2}_${x}"
                    if [ ! -z $x ]; then
                        ssh ${host_array[$platform]} "cp $logfile $outfile.log"
                        awk "$pcom" ${outfile}.log >${outfile}.regression.log
                        if [ -s ${outfile}.regression.log ]; then
                            color="Yellow"
                            fail_log="<a href='${outfile}.regression.log'>*</a>"
                        else
                            color="LawnGreen"
                        fi
                        if [ ! -z $oldfile ] && [ "$oldfile" != "${outfile}.regression.log" ]; then
                            sort -o ${outfile}.regression.log.comp ${outfile}.regression.log
                            sort -o $oldfile.comp $oldfile
                            comm -23 $oldfile.comp ${outfile}.regression.log.comp >$log_folder/comm_prog.log
                            comm -23 ${outfile}.regression.log.comp $oldfile.comp >$log_folder/comm_reg.log
                        fi
                    fi
                    if [ ! -z $x ]; then
                        days=`$path_to_diff/date_diff.sh $cur_date $x`
                    else
                        days=""
                    fi
                    eval Frequency=\${$Frequencies[$arg2]}
                    if [ ! -z $days ]; then
                        if [ "$days" -ge "$Frequency" ]; then
                            color="LightCoral"
                        else
                            if [ -s $log_folder/comm_reg.log ]; then
                                mv $log_folder/comm_reg.log ${outfile}.new_regression.log
                                reg="<a href='${outfile}.new_regression.log'>-</a>"
                                color="LightCoral"
                            fi
                            if [ -s $log_folder/comm_prog.log ]; then
                                mv $log_folder/comm_prog.log ${outfile}.new_progression.log
                                prog="<a href='${outfile}.new_progression.log'>+</a>"
                            fi
                        fi
                    fi
                    echo "<TD bgcolor='${color}'><NOBR><a href='${outfile}.log'>$x</a> ${fail_log} $reg $prog</NOBR></TD>"
                done
                echo "</TD>"
            done
        done
        echo "</TD>"
    done
    echo "</TR>"
    echo "</TR></TABLE>"
    echo "<BR><HR><BR>"
done

echo "<BR><HR><BR>"

echo "<div id=\"footer\" style=\"clear:both;\">"
#echo "<meta http-equiv=\"refresh\" content=\"15\">"
echo "$(date)"
echo "</div>"

echo "</BODY></HTML>"
