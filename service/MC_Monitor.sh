#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    MC_Monitor.sh
# Purpose: Monitors status of MC
#
# Author:      Iliya Vereshchagin
#
# Created:     09.07.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

cur_date=`date +%Y`_`date +%m`_`date +%d`

db_engine="sqlite3"
path_to_db="/nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions"
db_prefix="ndk_regressions_"
db_ext=".db"

bits_supported=(32 64)
#compiler 4.4.3, 4.7.2, 4.8.0, 4.8.1 are not supported anymore
compiler=(4.6.2 4.8.2 4.9.0)
devices=(Medfield CloverTrail Merrifield GalaxyNexus Nexus4 HarrisBeach)
declare -A Image_Type=([Medfield]="MCG_eng" [CloverTrail]="MCG_eng" [Merrifield]="MCG_eng" [GalaxyNexus]="Vanilla" [Nexus4]="AOSP" [HarrisBeach]="MCG_eng")
declare -A Test_Type_db=([Medfield]=0 [CloverTrail]=1 [Merrifield]=1 [GalaxyNexus]=0 [Nexus4]=1 [HarrisBeach]=1)
declare -A Medfield_Freq_32=([4.4.3]=65535 [4.6.2]=7 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=2 [4.9.0]=2)
declare -A Medfield_Freq_64=([4.4.3]=65535 [4.6.2]=7 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=7 [4.9.0]=7)
declare -A CloverTrail_Freq_32=([4.4.3]=65535 [4.6.2]=7 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=7 [4.9.0]=7)
declare -A CloverTrail_Freq_64=([4.4.3]=65535 [4.6.2]=14 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=14 [4.9.0]=14)
declare -A Merrifield_Freq_32=([4.4.3]=65535 [4.6.2]=7 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=2 [4.9.0]=2)
declare -A Merrifield_Freq_64=([4.4.3]=65535 [4.6.2]=14 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=7 [4.9.0]=7)
declare -A GalaxyNexus_Freq_32=([4.4.3]=65535 [4.6.2]=7 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=7 [4.9.0]=7)
declare -A GalaxyNexus_Freq_64=([4.4.3]=65535 [4.6.2]=14 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=14 [4.9.0]=14)
declare -A Nexus4_Freq_32=([4.4.3]=65535 [4.6.2]=7 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=7 [4.9.0]=7)
declare -A Nexus4_Freq_64=([4.4.3]=65535 [4.6.2]=14 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=14 [4.9.0]=14)
declare -A HarrisBeach_Freq_32=([4.4.3]=65535 [4.6.2]=7 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=7 [4.9.0]=7)
declare -A HarrisBeach_Freq_64=([4.4.3]=65535 [4.6.2]=14 [4.7.2]=65535 [4.8.0]=65535 [4.8.1]=65535 [4.8.2]=14 [4.9.0]=14)

echo "<HTML><HEAD><TITLE>MC results</TITLE></HEAD><BODY>"

#Print top table

for bits in ${bits_supported[*]}
do
    echo "<H3>$bits bit results</H3>"
    echo "<TABLE  border='1' cellpadding='3' cellspacing='0' width='360px'>"
    echo "<TR><TD><b>Device</b></TD>"
    for arg in ${compiler[*]}
    do
        echo "<TD><b>$arg</b></TD>"
    done
    echo "</TR>"

    for arg in ${devices[*]}
    do
        Frequencies="${arg}_Freq_${bits}"
        echo "<TR>"
        echo "<TD>$arg</TD>"
        for arg2 in ${compiler[*]}
        do
            compiler_for_db=`echo $arg2 | sed -r 's/[.]//g'`
            x=`$db_engine $path_to_db/$db_prefix$arg$db_ext "select test_date from Summaries where ndk_version='$arg2' AND image_type='${Image_Type[$arg]}' AND tested_object=${Test_Type_db[$arg]} AND bits=$bits ORDER by test_date DESC LIMIT 1"`
            if [ ! -z $x ]; then
                days=`$path_to_db/date_diff.sh $cur_date $x`
            else
                days=""
            fi
            eval Frequency=\${$Frequencies[$arg2]}
            if [ ! -z $days ]; then
                if [ "$days" -ge "$Frequency" ]; then
                    color="LightCoral"
                else
                    color="LawnGreen"
                fi
            fi
            hfile=`ls  $path_to_db/ndk${compiler_for_db}_${arg}/mc_summary_${Test_Type_db[$arg]}_${bits}_${Image_Type[$arg]}_$x.log 2>/dev/null`
            lfile=`ls  $path_to_db/ndk${compiler_for_db}_${arg}/progressions_and_regressions_${Test_Type_db[$arg]}_${bits}_${Image_Type[$arg]}_$x.log 2>/dev/null`
            echo "<TD bgcolor='${color}'><NOBR><a href='$hfile'>$x</a> <a href='$lfile'>[*]</a></NOBR></TD>"
        done
    done
    echo "</TABLE>"
done

echo "<BR><HR><BR>"

echo "<div id=\"footer\" style=\"clear:both;\">"
echo "<meta http-equiv=\"refresh\" content=\"15\">"
echo "$(date)"
echo "</div>"

echo "</BODY></HTML>"
