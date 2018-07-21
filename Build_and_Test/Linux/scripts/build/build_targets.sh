############################################################################################
# Building Android images for devices and emulator                                         #
#                                                                                          #
# Usage:                                                                                   #   
# build_targets.sh [image_name][gcc_version][special]                                      #
# image_name - name of image (aosp, blackbay, redhookbay)                                  #
# gcc_version - version of gcc, which must be in NDK folder                                #
# special - optional, uses for using special NDK which was built with special option       #
############################################################################################

#!/bin/bash

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi

source $baseDir/scripts/path.sh

image_name=$1
gcc_version=$2
bit=$3
special=$4
if [ "$bit" = "32" ] || [ -z $bit ] ; then
    bitcp="-32"
    bit=""
else
    bitcp="-"$bit
    bit=_$bit
fi
    
copy_and_setenv () {
    cp -rp $localDirNDK/$cur_date-linux$bitcp$special/android-ndk-$cur_date-[0-9]*/toolchains/* $1/ndk/toolchains/
    echo "$localDirNDK/$cur_date-linux$bitcp$special/android-ndk-$cur_date-[0-9]*/toolchains/* $1/ndk/toolchains/"
    cd $1
    source build/envsetup.sh
    make clean
    ls -l ndk/toolchains/x86-$gcc_version/prebuilt/linux-x86$bit/bin/i686-linux-android-gcc
}

if [ "aosp_emulator" == "$image_name" ]; then
    copy_and_setenv $androidExternal
    # Creating necessary folders for building Emulator image.
    mkdir -p $deeper/generic
    mkdir -p $deeper/generic_x86
    mkdir -p $deeper/generic_mips
    lunch full_x86-eng
    echo "see log in $baseDir/log/$cur_date-$gcc_version-full_x86$bit.log"
    make -j8 showcommands TARGET_TOOLS_PREFIX=ndk/toolchains/x86-$gcc_version/prebuilt/linux-x86$bit/bin/i686-linux-android- 1>$baseDir/log/$cur_date-$gcc_version-full_x86$bit.log 2>&1

elif [ "aosp_mako" == "$image_name" ]; then
    copy_and_setenv $androidExternal
    lunch full_mako-userdebug
    echo "see log in $baseDir/log/$cur_date-$gcc_version-full_mako-userdebug$bit.log"
    make -j8 TARGET_BUILD_VARIANT=eng updatepackage showcommands TARGET_TOOLS_PREFIX=ndk/toolchains/arm-linux-androideabi-$gcc_version/prebuilt/linux-x86$bit/bin/arm-linux-androideabi- 1>$baseDir/log/$cur_date-$gcc_version-full_mako-userdebug$bit.log 2>&1

elif [ "blackbay" == "$image_name" ]; then
    copy_and_setenv $androidInternal
    lunch blackbay-eng
    echo "see log in $baseDir/log/$cur_date-$gcc_version-blackbay$bit.log"
    make -j8 flashfiles showcommands TARGET_TOOLS_PREFIX=ndk/toolchains/x86-$gcc_version/prebuilt/linux-x86$bit/bin/i686-linux-android- 1>$baseDir/log/$cur_date-$gcc_version-blackbay$bit.log 2>&1

elif [ "redhookbay" == "$image_name" ]; then
    copy_and_setenv $androidInternal
    lunch redhookbay-eng
    echo "see log in $baseDir/log/$cur_date-$gcc_version-redhookbay$bit.log"
    make -j8 flashfiles showcommands TARGET_TOOLS_PREFIX=ndk/toolchains/x86-$gcc_version/prebuilt/linux-x86$bit/bin/i686-linux-android- 1>$baseDir/log/$cur_date-$gcc_version-redhookbay$bit.log 2>&1

elif [ "merrifield" == "$image_name" ]; then
    copy_and_setenv $androidInternal
    lunch saltbay-eng
    echo "see log in $baseDir/log/$cur_date-$gcc_version-merrifield$bit.log"
    make -j8 flashfiles showcommands TARGET_TOOLS_PREFIX=ndk/toolchains/x86-$gcc_version/prebuilt/linux-x86$bit/bin/i686-linux-android- 1>$baseDir/log/$cur_date-$gcc_version-merrifield$bit.log 2>&1

elif [ "OTC" == "$image_name" ]; then
    copy_and_setenv $androidInternal_OTC
    lunch core_ufo-eng
    echo "see log in $baseDir/log/$cur_date-$gcc_version-OTC$bit.log"
    make -j8 allimages showcommands TARGET_TOOLS_PREFIX=ndk/toolchains/x86-$gcc_version/prebuilt/linux-x86$bit/bin/i686-linux-android- 1>$baseDir/log/$cur_date-$gcc_version-OTC$bit.log 2>&1
fi

exit 0

