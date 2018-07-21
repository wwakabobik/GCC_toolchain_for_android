#!/bin/bash

export baseDir=$1
workDir="$(dirname $0)"

if [ -z $baseDir ]; then
	echo "Please set full path to root directory for Android testing as first argument"
	exit 1
fi

name=$USER
mkdir -p $baseDir/SDK
mkdir -p $baseDir/repositories/AOSP
mkdir -p $baseDir/repositories/MCG
mkdir -p $baseDir/repositories/MCG_OTC
mkdir -p $baseDir/repositories/toolchain_synced
mkdir -p $baseDir/repositories/gcc_trunk
mkdir -p $baseDir/repositories/toolchain_synced_tmp
mkdir -p $baseDir/builds/images
mkdir -p $baseDir/builds/ndk
mkdir -p $baseDir/results/Bionic 
mkdir -p $baseDir/results/Devices
mkdir -p $baseDir/log
mkdir -p ${mingw32_dir}
mkdir -p ${mingw64_dir}
cp -rf $workDir/patches $baseDir/.
cp -rf $workDir/scripts $baseDir/.
cp -rf $workDir/bin $baseDir/.

mkdir -p /export/users/$USER/.ccache

unzip /nfs/ims/proj/icl/gcc_cw/share/SDK/adt-bundle-linux-x86_64.zip -d $baseDir/SDK/

###SYNC  gcc-trunk
mkdir -p $baseDir/repositories/gcc_trunk
svn co file:///gnumnt/msticlel02_gnu_server/svn/replica/gcc/trunk $baseDir/repositories/gcc_trunk/

##Sync AOSP
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $baseDir/bin/repo_ext
chmod a+x $baseDir/bin/repo_ext
export PATH=$baseDir/bin/:$PATH
export PATH=$baseDir/bin/connect:$PATH

cd $baseDir/repositories/AOSP
repo_ext init -u https://android.googlesource.com/platform/manifest

# mako only
#wget https://dl.google.com/dl/android/aosp/broadcom-mako-jwr66y-137ef66d.tgz
#wget https://dl.google.com/dl/android/aosp/lge-mako-jwr66y-a85ca75e.tgz
#wget https://dl.google.com/dl/android/aosp/qcom-mako-jwr66y-a5becaf1.tgz
#tar xzf broadcom-mako-jwr66y-137ef66d.tgz
#tar xzf lge-mako-jwr66y-a85ca75e.tgz
#tar xzf qcom-mako-jwr66y-a5becaf1.tgz
#
#echo "You should write I ACCEPT when run these extract files"
#./extract-broadcom-mako.sh
#./extract-lge-mako.sh
#./extract-qcom-mako.sh
#
repo_ext sync -j5
#echo "AOSP synced. Now you can setup access to android.intel.com and run commands below"

export GIT_PROXY_COMMAND=$baseDir/bin/socks-gw
##SYNC MCG
rm -rf ~/.repoconfig
curl http://android.intel.com/repo > $baseDir/bin/repo_int
chmod a+x $baseDir/bin/repo_int
cd $baseDir/repositories/MCG
repo_int init -u ssh://android.intel.com/manifest -b platform/android/main -m android-main
echo "First MCG repo sync... It takes about 3 hours"
repo_int sync -j5


##SYNC MCG_OTC
rm -rf ~/.repoconfig
curl http://otc-android.intel.com/repo > $baseDir/bin/repo_otc
chmod a+x $baseDir/bin/repo_otc
cd $baseDir/repositories/MCG_OTC
repo_otc init -u ssh://otc-android.intel.com/aosp/platform/manifest -b jb-ia -m pc_std_internal
echo "First MCG_OTC repo sync... It takes about 3 hours"
repo_otc sync -j5

#
# Setup access to android.intel.com:
#
#	1. Create public and private key:
#ssh-keygen -p -f ~/.ssh/id_rsa -N ''
#ssh-copy-id -i ~/.ssh/id_rsa.pub  $USER@msticltz00.ims.intel.com
#
#	2. Copy id_rsa.pub to android.intel.com (use browser)
#cat ~/.ssh/id_rsa.pub
#         2.1 Do the same for otc-android.intel.com 
#	3. setup git config (~/.gitconfig), something like:
#[user]
#    name = gnucwtester
#    email = gnucwtester@intel.com
#    [review "android.intel.com:8080"]
#    username = gnucwtester
#    logallrefupdates=true
#
#[url "ssh://gnucwtester@gerrit-glb.tl.intel.com:29418/"]
#    insteadOf=ssh://jfumg-gcrmirror.jf.intel.com/
#    insteadOf=git://jfumg-gcrmirror.jf.intel.com/
#    insteadOf=git://android.intel.com/
#    insteadOf=ssh://mcg-devgcr-sc1.jf.intel.com/
#    insteadOf=git://mcg-devgcr-sc1.jf.intel.com/
#    insteadOf=ssh://android.intel.com:29418/
#    insteadOf=ssh://android.intel.com/
#
#[color]
#    ui = auto
#[core]
#        gitproxy = /nfs/ims/home/gnucwtester/proxy-wrapper
#
#
#	4. Setup ssh config (~/.ssh/config), something like:
#host *.ims.intel.com
#        user gnucwtester
#        RSAAuthentication yes
#
#
#host 10.125.173.*
#        user gnucwtester
#        RSAAuthentication yes
#
#gerrit mirror setup
#          host android.intel.com
#          port 29418
#          user gnucwtester
#
#
#
#          host gerrit-glb.tl.intel.com
#          port 29418
#          user gnucwtester
#
#
#host review.otc-android.intel.com
#port 29418
#user gnucwtester
#
#host otc-android.intel.com
#port 29418
#user gnucwtester


