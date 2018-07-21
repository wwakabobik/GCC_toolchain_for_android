#!/system/bin/sh

#-------------------------------------------------------------------------------
# Name:    android_profile.sh
# Purpose: This script collects profile data on Android devices.
#
# Author:      Iliya Vereshchagin
#
# Created:     21.02.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

if [ -z $1 ]; then
    binary="coremark.exe"
else
    binary=$1
fi

if [ -z $2 ]; then
    params=""
else
    params="$2"
fi

if [ -z $3 ]; then
    rootme=$PWD
else
    rootme=$3
fi

if [ -z $4 ]; then
    perfroot=$rootme
else
    perfroot=$4
fi

if [ -z $5 ]; then
    outdir=$rootme
else
    outdir=$5
fi


cur_date=`date +%d`
cur_date=$cur_date/`date +%m`
cur_date=$cur_date/`date +%Y`

cur_date_for_write=`date +%Y`_`date +%m`_`date +%d`

$perfroot/perf record $rootme/$binary $params >$outdir/$binary\_$cur_date_for_write.log
export PAGER=cat  # otherwise it will look for "less"
$perfroot/perf report >$outdir/$binary\_$cur_date_for_write\_perf.log