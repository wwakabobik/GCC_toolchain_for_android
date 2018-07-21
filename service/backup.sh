#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    backup.sh
# Purpose: makes backup from specified folder to specified folder for files
#          conforms to specified pattern if they are older than specified amount
#          of days
#
# Author:      Iliya Vereshchagin
#
# Created:     06.11.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

if [ -z $1 ]; then
    path=.
else
    path=$1
fi

if [ -z $2 ]; then
    out_dir=backup
else
    out_dir=$2
fi

if [ -z $3 ]; then
    days=30
else
    days=$3
fi

if [ ! -z $4 ]; then
    pattern=$4
fi

cd $path

for a in `find . -mtime +$days`
do
    [ -d $a ] && mkdir -p $out_dir/$a
    if [[ "$a" == *"$pattern"* ]] || [ -z $pattern ]; then
        [ -f $a ] && cp $a $out_dir/$a
        [ -f $a ] && rm $a
    fi
done