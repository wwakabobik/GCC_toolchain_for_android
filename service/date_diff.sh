#!/bin/bash

#-------------------------------------------------------------------------------
# Name:   date_diff.sh
# Purpose: prints difference between two dates
#
# Author:      Iliya Vereshchagin
#
# Created:     09.07.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

a=`echo $1 | sed 's/_//g'`
b=`echo $2 | sed 's/_//g'`

x=$(date +%j --date $a);\
y=$(date +%j --date $b);\
echo $(($y-$x))
#echo "$y - $x = $(($y-$x))" >>/users/igveresx/date_diff.log