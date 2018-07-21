#!/bin/sh

if [ -z $baseDir ] ; then
	echo "Please setup work directory as baseDir variable"
	exit 1
fi

ulimit -s 64000
unset LANG
export EDITOR=/usr/bin/vim
export PATH=/usr/bin:$PATH
export PATH=/nfs/ims/proj/icl/gcc_cw/changeset_analysis/scripts:$PATH
export http_proxy=http://proxy.ims.intel.com:911
export https_proxy=https://proxy.ims.intel.com:911
export no_proxy="localhost,.intel.com,127.0.0.0/8,172.16.0.0/20,192.168.0.0/16,10.0.0.0/8"
export PATH="/nfs/ims/proj/icl/gcc_cw/scripts:$baseDir/scripts/build:$baseDir/scripts/test:$PATH"
export GIT_PROXY_COMMAND=~/proxy-wrapper
export PYTHONPATH=~/
export ANT_HOME=/usr/share/ant
export CLASSPATH=.
export PATH=/nfs/ims/proj/icl/gcc_cw/share/ADB:$baseDir/bin:$PATH.
export CCACHE_DIR=/export/users/$USER/.ccache
export USE_CCACHE=1
export PATH=/usr/java/default/bin:$PATH.
ulimit -s 64000

###All necessary variables

export name="$USER" #This variable uses in copying/naming images

export rootDir="$baseDir" #root dir for bith of your folders instead of share
export shareDir="/nfs/ims/proj/icl/gcc_cw/users/$USER" # Share folder where images/ndk will be placed ( in folder with name currentDate_gccVersion )

export buildDir=$rootDir"/builds" #Path where results will be placed
export localDir=$buildDir"/images" #Local folder where images will be placed !not NDK
export localDirNDK=$buildDir"/ndk" #Local folder where NDK will be placed 
export ndkCurrentDir="/nfs/ims/proj/icl/gcc_cw/share/NDK_current" #Path where must be placed latest succesfull NDK build
export ndkCurrentDir64="/nfs/ims/proj/icl/gcc_cw/share/NDK_current_64"

export mingw32_dir=${baseDir}/repositories/mingw-w32
export mingw64_dir=${baseDir}/repositories/mingw-w64
export androidExternal=$rootDir"/repositories/AOSP" #Path to [AOSP] sources 
export androidInternal=$rootDir"/repositories/MCG" #Path to [MCG] soruces
export androidInternal_OTC=$rootDir"/repositories/MCG_OTC" #Path to [MCG] soruces
export deeper="out/target/product" #Path in sources where images placed NOTE: $rootDir doesn't needed here
export androidToolchain_synced=$rootDir"/repositories/toolchain_synced" #Path to toolchain sources
export androidToolchain_synced_tmp=$rootDir"/repositories/toolchain_synced_tmp" #Path to toolchain sources

export testResults=$rootDir"/results" #Path where NDK test results will be placed
export patchFolder=$rootDir"/patches" #Path to patches

export tools="$baseDir/bin" #Path for tools like adb fastboot and etc.
export sdkTools="${rootDir}/SDK/adt-bundle-linux-x86_64/sdk/platform-tools:${rootDir}/SDK/adt-bundle-linux-x86_64/sdk/tools" #Path to SDK tools

###Spectial function for cleanup all git repositories (checkout latest sources and remove all extra files)
cleanup_repo_ext () {
        repo_ext forall -c "git reset --hard"
        repo_ext forall -c "git clean -f -d"
        repo_ext forall -c "git checkout ."
}

cleanup_repo_int () {
        repo_int forall -c "git reset --hard"
        repo_int forall -c "git clean -f -d"
        repo_int forall -c "git checkout ."
}

cleanup_repo_int_otc () {
        repo_otc forall -c "git reset --hard"
        repo_otc forall -c "git clean -f -d"
        repo_otc forall -c "git checkout ."
}





