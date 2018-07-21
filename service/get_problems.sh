#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    get_problems.sh
# Purpose: get problems from needed dir
#
# Author:      Iliya Vereshchagin
#
# Created:     09.07.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

#$1 is log name
#$2 is version
#$3 is path

if [ -z $3 ]; then
    log_dir=.
else
    log_dir=$3
fi

grep FAIL: $log_dir/$1 | grep -v XFAIL >$1.$2.problems.log
grep UNRESOLVED: $log_dir/$1 >>$1.$2.problems.log
grep XPASS: $log_dir/$1 >>$1.$2.problems.log
