#!/bin/bash

ulimit -s 64000
unset LANG
export EDITOR=/usr/bin/mcedit
export PATH=/usr/bin:$PATH
export PATH=/nfs/ims/proj/icl/gcc_cw/changeset_analysis/scripts:$PATH
export http_proxy=http://proxy.ims.intel.com:911
export https_proxy=https://proxy.ims.intel.com:911
export no_proxy="localhost,.intel.com,127.0.0.0/8,172.16.0.0/20,192.168.0.0/16,10.0.0.0/8"
export PATH="/nfs/ims/proj/icl/gcc_cw/scripts:$PATH"
export PYTHONPATH=~/
export ANT_HOME=/usr/share/ant
export CLASSPATH=.
export PATH=~/bin:$PATH.
export PATH=/usr/java/default/bin/:$PATH.
ulimit -s 64000
source %path_file_path%

echo "### START Preparing repos ###" 
$rootDir/scripts/build/sync_repos.sh
echo "### END Preparing repos ###" 


echo "### START Preparing toolchains ###" 
$rootDir/scripts/build/sync_toolchains.sh
echo "### END Preparing toolchains ###" 

echo "### START Preparing trunk ###" 
cd $rootDir/repositories/gcc_trunk
svn update
mkdir -p $androidToolchain_synced/gcc/gcc-4.9/
cp -r $rootDir/repositories/gcc_trunk/* $androidToolchain_synced/gcc/gcc-4.9/
echo "### END Preparing trunk ###" 

echo "### START Patching repos ###"
$rootDir/scripts/build/patch_repos.sh
$rootDir/scripts/build/patch_trunk.sh
echo "### END Patching repos ###"  



echo "### START building repos ###" 
$rootDir/scripts/build/build_all.sh
echo "### END building repos ###" 
