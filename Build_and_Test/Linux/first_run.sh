#!/bin/sh

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi

source $baseDir/scripts/path.sh

cd $androidExternal
cleanup_repo_ext
echo "repo_ext sync"
echo "First AOSP repo sync... It takes about 3 hours"
repo_ext sync > $rootDir/log/first_sync_AOSP_repos.log 2>&1
prebuilts/misc/linux-x86/ccache/ccache -M 50G

cd $androidInternal
cleanup_repo_int
echo "repo_int sync"
echo "First MCG repo sync... It takes about 3 hours"
repo_int sync > $rootDir/log/first_sync_MCG_repos.log 2>&1
prebuilts/misc/linux-x86/ccache/ccache -M 50G


cd $androidInternal_OTC
cleanup_repo_int_otc
echo "repo_int sync"
echo "First MCG repo sync... It takes about 3 hours"
repo_otc sync > $rootDir/log/first_sync_OTC_repos.log 2>&1
prebuilts/misc/linux-x86/ccache/ccache -M 50G

echo "Start sync toolchains... See log in $rootDir/log/first_sync_toolchains.log"
$rootDir/scripts/build/first_sync_toolchains.sh > $rootDir/log/first_sync_toolchains.log 2>&1

echo "Start preparing trunk... See log in $rootDir/log/first_sync_trunk.log"
cd $rootDir/repositories/gcc_trunk
svn update > $rootDir/log/first_sync_trunk.log 2>&1
mkdir -p $androidToolchain_synced/gcc/gcc-4.9/
cp -R $rootDir/repositories/gcc_trunk/* $androidToolchain_synced/gcc/gcc-4.9/

echo "Start patching repos... see log in $rootDir/log/first_patch.log"
$rootDir/scripts/build/patch_repos.sh > $rootDir/log/first_patch.log 2>&1
$rootDir/scripts/build/patch_trunk.sh >> $rootDir/log/first_patch.log 2>&1
$rootDir/scripts/build/patch_werror_workaround.sh >> $rootDir/log/first_patch.log 2>&1

# mingw build
export PATH=${androidExternal}/prebuilts/gcc/linux-x86/host/i686-linux-glibc2.7-4.4.3/bin:$PATH
rm -rf /tmp/build-mingw64-toolchain-$USER/
mkdir -p ${mingw32_dir}
echo "Building mingw_32..."
${androidExternal}/ndk/build/tools/build-mingw64-toolchain.sh --package-dir=${mingw32_dir} --binprefix=i686-linux --target-arch=i686 > $rootDir/log/first_build_mingw_32.log 2>&1
tar xjf ${mingw32_dir}/i686-w64-mingw32-linux-i686.tar.bz2 -C ${mingw32_dir}

export PATH=${androidExternal}/prebuilts/gcc/linux-x86/host/i686-linux-glibc2.7-4.4.3/bin:$PATH
rm -rf /tmp/build-mingw64-toolchain-$USER/
mkdir -p ${mingw64_dir}
echo "Building mingw_64..."
${androidExternal}/ndk/build/tools/build-mingw64-toolchain.sh --package-dir=${mingw64_dir} --binprefix=i686-linux > $rootDir/log/first_build_mingw_64.log 2>&1
tar xjf ${mingw64_dir}/x86_64-w64-mingw32-linux-i686.tar.bz2 -C ${mingw64_dir}

export cur_date=`date +%Y%m%d`
sed -e "s/^       BUILD_TARGET_PLATFORMS=.*/       BUILD_TARGET_PLATFORMS=\"linux-x86 windows\"/" -i $androidExternal/ndk/build/tools/dev-rebuild-ndk.sh

echo "Start building 32-bit version of NDK... see log in $rootDir/log/first_build_NDK_32.log"
$rootDir/scripts/build/build_NDK.sh yes 32 "4.6 4.7 4.8 4.9" > $rootDir/log/first_build_NDK_32.log 2>&1
$rootDir/scripts/build/unpack.sh >> $rootDir/log/first_build_NDK_32.log 2>&1

echo "Start building 64-bit version of NDK... see log in $rootDir/log/first_build_NDK_64.log"
$rootDir/scripts/build/build_NDK.sh yes 64 "4.6 4.7 4.8 4.9" > $rootDir/log/first_build_NDK_64.log 2>&1
$rootDir/scripts/build/unpack.sh >> $rootDir/log/first_build_NDK_64.log 2>&1

exit 0

