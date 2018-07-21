#!/bin/bash

special=$1

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi
source $baseDir/scripts/path.sh
cd $androidExternal/ndk-release-$cur_date
if [ -f android-ndk-$cur_date-[0-9]*-linux-x86.tar.bz2 ] ; then
	echo "Copying NDK (32 bit) for linux to $localDirNDK/$cur_date-linux$special"
	mkdir $localDirNDK/$cur_date-linux-32$special
	cp android-ndk-$cur_date-[0-9]*-linux-x86.tar.bz2 $localDirNDK/$cur_date-linux-32$special/
	cd $localDirNDK/$cur_date-linux-32$special/
	tar xjvf android-ndk-$cur_date-[0-9]*-linux-x86.tar.bz2 -C $localDirNDK/$cur_date-linux-32$special > /dev/null
	
fi
cd $androidExternal/ndk-release-$cur_date
if [ -f android-ndk-$cur_date-[0-9]*-linux-x86_64.tar.bz2 ] ; then
    echo "Copying NDK (64 bit) for linux to $localDirNDK/$cur_date-linux-64$special"

	mkdir $localDirNDK/$cur_date-linux-64$special
	cp android-ndk-$cur_date-[0-9]*-linux-x86_64.tar.bz2 $localDirNDK/$cur_date-linux-64$special/
	cd $localDirNDK/$cur_date-linux-64$special/
	tar xjvf android-ndk-$cur_date-[0-9]*-linux-x86_64.tar.bz2 -C $localDirNDK/$cur_date-linux-64$special > /dev/null
	

fi
cd $androidExternal/ndk-release-$cur_date
if [ -f android-ndk-$cur_date-[0-9]*-windows-x86.zip ]; then
	echo "Copying NDK (32 bit) for windows to $localDirNDK/$cur_date-win$special"
	mkdir $localDirNDK/$cur_date-win$special
	cp android-ndk-$cur_date-[0-9]*-windows-x86.zip $localDirNDK/$cur_date-win$special/
fi

cd $androidExternal/ndk-release-$cur_date
if [ -f android-ndk-$cur_date-[0-9]*-windows-x86_64.zip ] ; then
    echo "Copying NDK (64 bit) for windows to $localDirNDK/$cur_date-win-64$special"
	mkdir $localDirNDK/$cur_date-win-64$special
	cp android-ndk-$cur_date-[0-9]*-windows-x86_64.zip $localDirNDK/$cur_date-win-64$special/
fi

