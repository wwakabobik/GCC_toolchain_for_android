############################################################################################
# Script is designed to automate process of building Android - images                      #
#                                                                                          #
# Usage:                                                                                   #   
# build_targets.sh [image_name][gcc_version][special]                                      #
# image_name - name of image (aosp, blackbay, redhookbay)                                  #
# gcc_version - version of gcc, which must be in NDK folder                                #
# special - optional, uses for using special NDK which was built with special option       #
############################################################################################

#!/bin/bash

source %path_file_path%

image_name=$1
gcc_version=$2
bit=$3
special=$4
bit=_$bit
if [ "$bit" = "32" ]; then
  bit=
fi
    
copy_and_setenv () {
    cp -rp  $localDirNDK/$cur_date-$special/android-ndk-$cur_date-$cur_date$bit/toolchains/*  $1/ndk/toolchains
    cd $1
    . ./build/envsetup.sh
    source build/envsetup.sh
    make clean
    rm -rf out
    ls -l ndk/toolchains/x86-$gcc_version/prebuilt/darwin-x86$bit/bin/i686-linux-android-gcc
}

if [ "aosp" == "$image_name" ]; then
    copy_and_setenv $androidExternal
    lunch full_x86-eng
    make -j8 showcommands  TARGET_TOOLS_PREFIX=ndk/toolchains/x86-$gcc_version/prebuilt/darwin-x86$bit/bin/i686-linux-android- 1>$cur_date-$gcc_version-full_x86.log 2>&1
fi







