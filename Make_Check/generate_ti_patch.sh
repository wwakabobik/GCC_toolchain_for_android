#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    generate_ti_patch.sh
# Purpose: this script parses template and generate the patch for
#          test_installed script, used by make check bridge method
#
# Author:      Iliya Vereshchagin
#
# Created:     31.10.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------


if [ -z $1 ]; then
    dejagnu_dir=""
else
    dejagnu_bin_dir=`echo "$1/bin/" | sed -e 's/\\//\\\\\\//g'`
    boards_dir=`echo "$1/share/dejagnu/baseboards" | sed -e 's/\\//\\\\\\//g'`
    dejagnu_dir=`echo $1 | sed -e 's/\\//\\\\\\//g'`
fi

if [ -z $2 ]; then
    device="MedfieldE906493B"
else
    device=$2
fi

if [ -z $3 ]; then
    test_arch="x86"
else
    test_arch=$3
fi

if [ -z $4 ]; then
    device_alias=""
else
    device_alias="_$4"
fi

if [ -z $5 ]; then
    exec_folder="\/data\/local\/$USER\/MC"
else
    exec_folder=`echo $5 | sed -e 's/\\//\\\\\\//g'`
fi

if [ -z $6 ]; then
    output_patch="test_installed_adb_bridge_$test_arch$device_alias.patch"
else
    output_patch=`echo $6 | sed -e 's/\\//\\\\\\//g'`
fi

if [ "$test_arch" == "arm" ] || [ "$test_arch" == "x86" ] ||  [ "$test_arch" == "arm7" ] || [ "$test_arch" == "mips" ]; then
    cat test_installed_adb_bridge_patch_$test_arch.template | sed -e 's/@BOARDS_DIR@/'$boards_dir'/g' | sed -e 's/@DEJAGNU_DIR@/'$dejagnu_bin_dir'/g' | sed -e 's/@DEVICE@/'$device'/g' | sed -e 's/@EXEC_FOLDER@/'$exec_folder'/g' > $output_patch
else
    echo "Wrong architecture specified for test patch, aborted..."
    exit -1
fi

exit 0