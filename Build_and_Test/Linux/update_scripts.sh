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
mkdir -p $baseDir/repositories/toolchain_synced
mkdir -p $baseDir/repositories/gcc_trunk
mkdir -p $baseDir/repositories/toolchain_synced_tmp
mkdir -p $baseDir/builds/images
mkdir -p $baseDir/builds/ndk
mkdir -p $baseDir/results/Bionic 
mkdir -p $baseDir/results/Devices
mkdir -p $baseDir/log
cp -rf $workDir/patches $baseDir/.
cp -rf $workDir/scripts $baseDir/.
cp -rf $workDir/bin $baseDir/.

mkdir -p /export/users/$USER/.ccache
mkdir -p $baseDir/repositories/gcc_trunk

