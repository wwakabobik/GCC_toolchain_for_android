#!/bin/bash

baseDir=$1
if [ "$baseDir" == "" ]; then
  echo "Please select root folder for Android testing, as first parameter"
  exit 1
fi

name=`whoami`
mkdir -p $baseDir/bin
mkdir -p $baseDir/SDK
mkdir -p $baseDir/repositories/AOSP
mkdir -p $baseDir/repositories/MCG
mkdir -p $baseDir/repositories/toolchain_synced
mkdir -p $baseDir/repositories/gcc_trunk
mkdir -p $baseDir/repositories/toolchain_synced_tmp
mkdir -p $baseDir/builds/images
mkdir -p $baseDir/builds/ndk
mkdir -p $baseDir/patches/
mkdir -p $baseDir/results/Bionic 
mkdir -p $baseDir/results/Devices
mkdir -p $baseDir/scripts/build
mkdir -p $baseDir/scripts/test
mkdir -p $baseDir/log
cp -rf ../patches/* $baseDir/patches/
cp -rf ../build/* $baseDir/scripts/build/
cp -rf ../test/* $baseDir/scripts/test/

sed "s/%name%/$name/" $baseDir/scripts/build/path.sh  > $baseDir/1.tmp
mv $baseDir/1.tmp  $baseDir/scripts/build/path.sh 
sed "s|%rootDir%|$baseDir|g" $baseDir/scripts/build/path.sh > $baseDir/2.tmp
mv $baseDir/2.tmp $baseDir/scripts/build/path.sh
mv $baseDir/scripts/build/path.sh $baseDir/scripts/path.sh

sed "s|%rootDir%|$baseDir|g" $baseDir/scripts/path.sh > $baseDir/2.tmp
mv $baseDir/2.tmp $baseDir/scripts/path.sh
#mv $baseDir/scripts/build/path.sh $baseDir/scripts/path.sh

FILES=$baseDir/scripts/build/*
for f in $FILES
do
  sed -i "s|%path_file_path%|$baseDir\/scripts\/path.sh|g" $f 
done


FILES=$baseDir/scripts/test/*
for f in $FILES
do
  sed -i "s|%path_file_path%|$baseDir\/scripts\/path.sh|g" $f 
done


FILES=$baseDir/patches/*.patch
for f in $FILES
do
  sed -i "s|%rootDir%|$baseDir|g" $f 
done

cp -rf /nfs/ims/proj/icl/gcc_cw/share/SDK/* $baseDir/SDK/
cd $baseDir/SDK/
unzip adt-bundle-darwin-x86_64.zip

##Sync AOSP
#curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > $baseDir/bin/repo_ext
#chmod a+x $baseDir/bin/repo_ext
#export PATH=$baseDir/bin/:$PATH
#cd $baseDir/repositories/AOSP
#repo_ext init -u https://android.googlesource.com/platform/manifest
#repo_ext sync
# Your ~/.ssh/config file should looks like this:
#######################
#host umg-repo1.intel.com
#    port 29418
#    user username
#
#host jfumgrepo1.jf.intel.com
#    port 29418
#    user username
#
#host android.intel.com
#    port 29418
#    user username
#
#host android.jf.intel.com
#    port 29418
#    user username
#gerrit mirror setup
#host umgsw-gcrmirror5.jf.intel.com
#     user username
#     port 29418
########################
#

###SYNC  gcc-trunk
#
# mkdir $baseDir/repositories/gcc_trunk
# svn co file:///gnumnt/msticlel02_gnu_server/svn/replica/gcc/trunk $baseDir/repositories/gcc_trunk/
#
#
#


