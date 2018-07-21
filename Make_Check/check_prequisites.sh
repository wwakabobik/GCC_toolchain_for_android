#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    check_prequisites.sh
# Purpose: check required files, tools and directories for daily NDK compiler
#          make check testing using adb bridge method
#
# Author:      Iliya Vereshchagin
#
# Created:     31.10.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------

y=`basename $0`
$ndebug echo "$y started with parameters:"
$ndebug echo "   $1"
$ndebug echo "   $2"
$ndebug echo "   $3"

if [ -z $1 ]; then
    rootme=$PWD
else
    rootme=$1
fi

if [ -z $2 ]; then
    device_alias="Medfield"
else
    device_alias=$2
fi

if [ -z $3 ]; then
    NDK_subf="NDK"
else
    NDK_subf=$3
fi

list_of_files_to_check=($rootme/Make_Check_Android.sh $rootme/check_stable_regression.sh $rootme/get_excel_summary.sh $rootme/make_check_adb_bridge_united_443.patch $rootme/make_check_adb_bridge_united_46.patch $rootme/make_check_adb_bridge_united_47.patch $rootme/make_check_adb_bridge_united_48.patch $rootme/make_check_adb_bridge_united_49.patch $rootme/types.patch $rootme/check_dejagnu.sh /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk_regressions\_$device_alias.db $rootme/generate_ti_patch.sh $rootme/test_installed_adb_bridge_patch_x86.template $rootme/test_installed_adb_bridge_patch_arm.template /nfs/ims/proj/icl/gcc_cw/share/ADB/adb $rootme/make_check_linux.sh)
list_of_dirs_to_check=(/nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk443_HarrisBeach /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk462_HarrisBeach /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk472_HarrisBeach /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk480_HarrisBeach /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk490_HarrisBeach /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk443_Merrifield /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk462_Merrifield /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk472_Merrifield /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk480_Merrifield /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk490_Merrifield /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk443_GalaxyNexus /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk462_GalaxyNexus /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk472_GalaxyNexus /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk480_GalaxyNexus /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk490_GalaxyNexus /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk443_Medfield /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk462_Medfield /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk472_Medfield /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk480_Medfield /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk490_Medfield /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk443_CloverTrail /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk462_CloverTrail /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk472_CloverTrail /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk480_CloverTrail /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk490_CloverTrail /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk443_Nexus4 /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk462_Nexus4 /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk472_Nexus4 /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk480_Nexus4 /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk490_Nexus4 /nfs/ims/proj/icl/gcc_cw/share/Make_Check_Adb_Results $NDK_subf /gnumnt/msticlel02_gnu_server/svn/replica/gcc)
list_of_needed_tools_to_check=(sqlite3 rm cat patch svn git cp mv comm touch adb fastboot tclsh)
list_of_non_empty_dirs_to_check=(/nfs/ims/proj/icl/gcc_cw/share/$NDK_subf /nfs/ims/proj/icl/gcc_cw/share/ADB)

for arg in ${list_of_files_to_check[*]}
do
    if [ ! -f $arg ]; then
    echo " critical file $arg missed, aborted"
    exit -1
    fi
done

for arg in ${list_of_dirs_to_check[*]}
do
    if [ ! -d $arg ]; then
    echo " critical directory $arg missed, aborted"
    exit -1
    fi
done

for arg in ${list_of_tools_to_check[*]}
do
    which $arg
    if [ $? != 0 ]; then
    echo " critical tool $arg missed, aborted"
    exit -1
    fi
done

for arg in ${list_of_tools_to_check[*]}
do
    if [[ ($(ls -A $arg)) ]]; then
    echo " required directory $arg is empty, aborted"
    exit -1
    fi
done

touch $rootme/test_file.daily_check_ndk
if [ $? != 0 ]; then
    echo " no write access to needed folder $rootme, aborted"
    exit -1
else
    rm $rootme/test_file.daily_check_ndk
fi

exit 0
