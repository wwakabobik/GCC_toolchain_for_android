#!/bin/bash

rootme=$PWD
hosts_array=(msticlxl100 msticlxl101 msticlxl102)
device_array=(x86/Medfield x86/CloverTrail x86/Merrifield arm/GalaxyNexus arm/Nexus4 x86/HarrisBeach)

for host_name in ${hosts_array[*]}
do
    cd /gnucwmnt/${host_name}_users/$USER/MC_Daily/Make_Check_Adb_Results && svn cleanup && svn up
    for device in ${device_array[*]}
    do
        cp /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/cleanup.sh /gnucwmnt/${host_name}_users/$USER/MC_Daily/MC/$device/cleanup.sh
        cd /gnucwmnt/${host_name}_users/$USER/MC_Daily/MC/$device && nohup ./cleanup.sh &
    done
done

cd $PWD