#!/bin/bash

data=$1
version=$2
bit=$3
special=$4

if [ "$bit" == "" ]; then
   bit="32"
fi
   

source path.sh
cur_date_version=$cur_date"_"$version$special

deeper=out/target/product #Path in sources where images placed
if [ "$data" == "aosp" ]; then
    
    targetDirLocal=$localDir/$cur_date_version/AOSP_$bit
    targetDirShared=$shareDir/$cur_date_version/AOSP_$bit

    mkdir -p $targetDirLocal
    mkdir -p $targetDirShared
    echo  "Copying full_x86  build.prop to local storage"
    cp $androidExternal/$deeper/generic_x86/system/build.prop $targetDirLocal
    
    echo  "Copying full_x86  ramdisk.img to local storage"
    cp $androidExternal/$deeper/generic_x86/ramdisk.img $targetDirLocal
    
    echo  "Copying full_x86  system.img to local storage"
    cp $androidExternal/$deeper/generic_x86/system.img  $targetDirLocal
    
    echo  "Copying full_x86  userdata.img to local storage"
    cp $androidExternal/$deeper/generic_x86/userdata.img $targetDirLocal
    
fi




