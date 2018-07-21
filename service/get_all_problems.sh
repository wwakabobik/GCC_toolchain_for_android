#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    get_all_problems.sh
# Purpose: gets a problems of last recent versions of MC results
#
# Author:      Iliya Vereshchagin
#
# Created:     09.07.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

device_arch=x86
#device_arch=arm
#device=CloverTrail
device=Medfield

./get_problems.sh gcc.log 462 $device_arch/$device/Android_4.6.2_Patched
./get_problems.sh g++.log 462 $device_arch/$device/Android_4.6.2_Patched
./get_problems.sh gcc.log 472 $device_arch/$device/Android_4.7.2_Patched
./get_problems.sh g++.log 472 $device_arch/$device/Android_4.7.2_Patched
#./get_problems.sh gcc.log 480 $device_arch/$device/Android_4.8.0_Patched
#./get_problems.sh g++.log 480 $device_arch/$device/Android_4.8.0_Patched
./get_problems.sh gcc.log 481 $device_arch/$device/Android_4.8.1_Patched
./get_problems.sh g++.log 481 $device_arch/$device/Android_4.8.1_Patched
./get_problems.sh gcc.log trunk $device_arch/$device/Android_4.9.0_Patched
./get_problems.sh g++.log trunk $device_arch/$device/Android_4.9.0_Patched
