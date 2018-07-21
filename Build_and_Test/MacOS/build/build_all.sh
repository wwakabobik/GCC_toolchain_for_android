############################################################################################
# Script is designed to automate process of building Android:                              #
# 1) automate the build of Android-NDK (32 and 64 bit)                                     #
# 2) automate the build of AOSP (32 and 64 bit)                                            #
# 3) automate the build of MCG(blackbay and redhookbay) images (32 and 64 bit)             #
#                                                                                          #
# Usage:                                                                                   #   
# build_all.sh [special]                                                                   #
# special - optional, uses for creating special folders with images (date_version_special) #
#                                                                                          #
# Building doesn't concatinated in one function just for # usefult using.                  #
# Can build everything separately and comment out thing that doesn't work.                 #
############################################################################################

#!/bin/bash

source  %path_file_path%

#Useful functions

clean_AOSP () {
rm -rf $androidExternal/out/	
cd $androidExternal
#Creatin necessary folders for building Emulator image.
mkdir -p $deeper/generic
mkdir -p $deeper/generic_x86
mkdir -p $deeper/generic_mips
}

special=$1


###############
# NDK section #
###############

### NDK build Section ###
clean_AOSP
$rootDir/scripts/build/build_NDK.sh yes # using "yes" just for saves you from deleting folders
$rootDir/scripts/build/unpack.sh $special


###############
# 4.6 section #
###############

### 4.6 AOSP build section ###
$rootDir/scripts/build/build_targets.sh aosp 4.6 $special 
$rootDir/scripts/build/make_copy.sh aosp 4.6 $special



###############
# 4.7 section #
###############

### Preparing 4.7 soruces for building ###
#$rootDir/scripts/build/patch_for_4.7.sh

### 4.7 AOSP build section ###
clean_AOSP
$rootDir/scripts/build/build_targets.sh aosp 4.7 $special 
$rootDir/scripts/build/make_copy.sh aosp 4.7 $special


###############
# 4.8 section #
###############

### Preparing 4.8 soruces for building ###
#$rootDir/scripts/build/patch_for_4.8.sh

### 4.8 AOSP build section ###
clean_AOSP
$rootDir/scripts/build/build_targets.sh aosp 4.8 $special 
$rootDir/scripts/build/make_copy.sh aosp 4.8 $special


#########################################
# 4.9 for now it's trunk                #
# can be changed when 4.9 became stable #
#########################################

### Preparing trunk soruces for building ###
#$rootDir/scripts/build/patch_for_trunk.sh

### trunk AOSP build section ###
clean_AOSP
$rootDir/scripts/build/build_targets.sh aosp 4.9 $special 
$rootDir/scripts/build/make_copy.sh aosp 4.9 $special

