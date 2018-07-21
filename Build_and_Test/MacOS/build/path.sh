#!/bin/sh

###All necessary variables

name="%name%" #This variable uses in copying/naming images
export cur_date=`date +%Y%m%d` #Current date (example: 20121109) 9 november 2012

rootDir="%rootDir%" #root dir for bith of your folders instead of share
shareDir="/nfs/ims/proj/icl/gcc_cw/users/%name%" # Share folder where images/ndk will be placed ( in folder with name currentDate_gccVersion )

buildDir="$rootDir/builds" #Path where results will be placed
localDir="$buildDir/images" #Local folder where images will be placed !not NDK
localDirNDK="$buildDir/ndk" #Local folder where NDK will be placed 
ndkCurrentDir="/nfs/ims/proj/icl/gcc_cw/share/NDK_current/" #Path where must be placed latest succesfull NDK build


androidExternal="$rootDir/repositories/AOSP" #Path to [AOSP] sources 
androidInternal="$rootDir/repositories/MCG" #Path to [MCG] soruces
deeper="out/target/product" #Path in sources where images placed NOTE: $rootDir doesn't needed here
androidToolchain_synced="$rootDir/repositories/toolchain_synced" #Path to toolchain sources
androidToolchain_synced_tmp="$rootDir/repositories/toolchain_synced_tmp" #Path to toolchain sources

testResults="$rootDir/results" #Path where NDK test results will be placed
patchFolder="$rootDir/patches" #Path to patches

tools="/nfs/ims/home/%name%/bin/" #Path for tools like adb fastboot and etc.
sdkTools=$rootDir"/adt-bundle-linux-x86_64/sdk/platform-tools/:"$rootDir"/adt-bundle-linux-x86_64/sdk/tools/:" #Path to SDK tools


###Spectial function for cleanup all git repositories (checkout latest sources and remove all extra files)
cleanup_repo_ext () { 
repo_ext forall -c "git checkout ."
repo_ext forall -c "git clean -f -d"
}

cleanup_repo_int () { 
repo_int forall -c "git checkout ."
repo_int forall -c "git clean -f -d"
}
