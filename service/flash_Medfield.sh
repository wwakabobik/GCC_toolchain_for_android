#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    flash_Medfield.sh
# Purpose: script to flash Medfiled with default last stable image
#
# Author:      Iliya Vereshchagin
#
# Created:     09.07.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

path_to_image="/nfs/ims/proj/icl/gcc_cw/share/MFLD_current"
image_name="blackbay-ota-eng.abantonx.zip"

adb -s $1 reboot bootloader
sleep 60
fastboot -s $1 erase cache
sleep 3
fastboot -s $1 erase boot
sleep 10
fastboot -s $1 erase system
sleep 3
fastboot -s $1 flash update $path_to_image/$image_name
sleep 3
sleep 200
adb -s $1 wait-for-device
sleep 100