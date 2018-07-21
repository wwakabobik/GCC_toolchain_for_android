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

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi

source $baseDir/scripts/path.sh
special=$1

FAILED=false
FAILED64=false

buildImage() {
    codeName=$1
    version=$2
    bit=$3
    special=$4
    
    $rootDir/scripts/build/build_targets.sh $codeName $version $bit $special 
    $rootDir/scripts/build/make_copy.sh $codeName $version $bit $special 
}

build_image_set() {
    bit=$1
    failed=$2
    special=$3

    buildImage merrifield 4.7 $bit  $special
    buildImage OTC 4.7 $bit $special
    buildImage merrifield 4.8 $bit $special
    buildImage OTC 4.8 $bit $special

#    if [ ! $failed ]; then
	buildImage merrifield 4.9 $bit $special
	buildImage OTC 4.9 $bit $special
#    fi
}

build_NDK() {
    bit=$1
    versions=$2
    $rootDir/scripts/build/build_NDK.sh yes $bit "$versions"  # using "yes" just for saves you from deleting folders
    $rootDir/scripts/build/unpack.sh $special
    $rootDir/scripts/build/make_copy.sh ndk 4.6 $special ### version doesn't matter

}

build_NDK 32 "4.6 4.7 4.8 4.9"
if [ ! -f ${baseDir}/builds/ndk/${cur_date}-linux-32/android-ndk-${cur_date}-${cur_date}-linux-x86.tar.bz2 ]; then
    FAILED=true
    build_NDK 32 "4.6 4.7 4.8"
fi

build_image_set 32 FAILED $special & ## parallel build images & NDK
pid32=$!
echo "Backgrounded build image process (pid=$pid32)"

build_NDK 64 "4.6 4.7 4.8 4.9" 
if [ ! -f ${baseDir}/builds/ndk/${cur_date}-linux-64/android-ndk-${cur_date}-${cur_date}-linux-x86_64.tar.bz2 ]; then
    FAILED64=true
    build_NDK 64 "4.6 4.7 4.8"
fi

wait $pid32
build_image_set 64 FAILED64 $special


export PATH=${mingw32_dir}/i686-w64-mingw32/bin:$PATH
sed -e "s/^       BUILD_TARGET_PLATFORMS=.*/       BUILD_TARGET_PLATFORMS=\"windows\"/" -i $androidExternal/ndk/build/tools/dev-rebuild-ndk.sh
$rootDir/scripts/build/build_NDK.sh yes 32 "4.6 4.7 4.8 4.9"
$rootDir/scripts/build/unpack.sh

if [ ! -f ${baseDir}/builds/ndk/${cur_date}-win/android-ndk-${cur_date}-${cur_date}-windows-x86.zip ]; then
#    FAILED=true
    sed -e "s/^       BUILD_TARGET_PLATFORMS=.*/       BUILD_TARGET_PLATFORMS=\"windows\"/" -i $androidExternal/ndk/build/tools/dev-rebuild-ndk.sh
    $rootDir/scripts/build/build_NDK.sh yes 32 "4.6 4.7 4.8"
    $rootDir/scripts/build/unpack.sh
fi



export PATH=${mingw32_dir}/x86_64-w64-mingw32/bin:$PATH
sed -e "s/^       BUILD_TARGET_PLATFORMS=.*/       BUILD_TARGET_PLATFORMS=\"windows\"/" -i $androidExternal/ndk/build/tools/dev-rebuild-ndk.sh
$rootDir/scripts/build/build_NDK.sh yes 64 "4.6 4.7 4.8 4.9"
$rootDir/scripts/build/unpack.sh

if [ ! -f ${baseDir}/builds/ndk/${cur_date}-win/android-ndk-${cur_date}-${cur_date}-windows-x86_64.zip ]; then
#    FAILED=true
    sed -e "s/^       BUILD_TARGET_PLATFORMS=.*/       BUILD_TARGET_PLATFORMS=\"windows\"/" -i $androidExternal/ndk/build/tools/dev-rebuild-ndk.sh
    $rootDir/scripts/build/build_NDK.sh yes 64 "4.6 4.7 4.8"
    $rootDir/scripts/build/unpack.sh
fi


exit 0

