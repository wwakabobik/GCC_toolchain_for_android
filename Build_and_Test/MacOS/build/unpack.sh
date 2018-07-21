#!/bin/bash

special=$1
source %path_file_path%
cd $androidExternal/ndk-release-$cur_date
mkdir  $localDirNDK/$cur_date-darwin$special
tar xjvf android-ndk-$cur_date-$cur_date-darwin-x86.tar.bz2  -C $localDirNDK/$cur_date-darwin$special
cp  android-ndk-$cur_date-$cur_date-darwin-x86.tar.bz2  $localDirNDK/$cur_date-darwin$special/

mkdir  $localDirNDK/$cur_date-darwin_64$special
tar xjvf android-ndk-$cur_date-$cur_date-darwin-x86_64.tar.bz2  -C $localDirNDK/$cur_date-darwin_64$special
cp  android-ndk-$cur_date-$cur_date-darwin-x86_64.tar.bz2  $localDirNDK/$cur_date-darwin_64$special/
