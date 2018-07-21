#!/bin/bash

data=$1
version=$2
bit=$3
special=$4
if [ "$bit" == "" ]; then
	bit="32"
fi

if [ -z $baseDir ] ; then
	echo "Please setup work directory as baseDir variable"
    exit 1
fi

source $baseDir/scripts/path.sh

cur_date_version=$cur_date"_"$version$special

deeper=out/target/product #Path in sources where images placed
if [ "$data" == "aosp_emulator" ]; then
    targetDirLocal=$localDir/$cur_date_version/AOSP_$bit
    targetDirShared=$shareDir/$cur_date_version/AOSP_$bit
	if [ -f $androidExternal/$deeper/generic_x86/system/build.prop ] && [ -f $androidExternal/$deeper/generic_x86/ramdisk.img ] && [ -f $androidExternal/$deeper/generic_x86/system.img ] && [ -f $androidExternal/$deeper/generic_x86/userdata.img ] ; then
	    mkdir -p $targetDirLocal

		echo "Copying full_x86 emulator to local storage ($targetDirLocal)"
	    cp $androidExternal/$deeper/generic_x86/system/build.prop $targetDirLocal
	    cp $androidExternal/$deeper/generic_x86/ramdisk.img $targetDirLocal
	    cp $androidExternal/$deeper/generic_x86/system.img  $targetDirLocal
	    cp $androidExternal/$deeper/generic_x86/userdata.img $targetDirLocal

	else 
		echo "Error: Emulator image not found in $androidExternal/$deeper/generic_x86/system"
	fi

elif [ "$data" == "aosp_mako" ]; then
    targetDirLocal=$localDir/$cur_date_version/AOSP_mako_$bit
    targetDirShared=$shareDir/$cur_date_version/AOSP_mako_$bit

    if [ -f $androidExternal/$deeper/mako/full_mako-img-eng.${USER}.zip ] ; then
        mkdir -p $targetDirLocal
        echo "Copying mako image to $targetDirLocal"
        cp $androidExternal/$deeper/mako/full_mako-img-eng.${USER}.zip $targetDirLocal
    else
        echo "Error: full_mako-img-eng.$name.zip not found in $androidExternal/$deeper/mako/"
    fi

# TODO:change it as redhookbay
elif [ "$data" == "blackbay" ]; then 
    targetDirLocal=$localDir/$cur_date_version/blackbay_$bit
    targetDirShared=$shareDir/$cur_date_version/blackbay_$bit

    mkdir -p $targetDirLocal
#    mkdir -p $targetDirShared
    echo  "Copying blackbay to local storage"
	echo "ls -la $androidInternal/pub/BLACKBAY/fastboot-images/eng"
	ls -la $androidInternal/pub/BLACKBAY/fastboot-images/eng
	echo "ls -la $androidInternal/pub/BLACKBAY/flash_files/build-eng"
	ls -la $androidInternal/pub/BLACKBAY/flash_files/build-eng	

    cp $androidInternal/pub/BLACKBAY/fastboot-images/eng/blackbay-ota-eng.$name.zip $targetDirLocal
    cp $androidInternal/pub/BLACKBAY/fastboot-images/eng/system.img.gz $targetDirLocal


#    echo  "Copying blackbay to nfs"
#    cp $androidInternal/$deeper/blackbay/blackbay-ota-eng.$name.zip $targetDirShared
#    cp $androidInternal/$deeper/blackbay/boot.bin $targetDirShared
#    cp $androidInternal/$deeper/blackbay/system.img.gz $targetDirShared


elif [ "$data" == "redhookbay" ]; then 
    targetDirLocal=$localDir/$cur_date_version/redhookbay_$bit
    targetDirShared=$shareDir/$cur_date_version/redhookbay_$bit

#	if [ -f $androidInternal/$deeper/redhookbay/redhookbay-ota-eng.${USER}.zip ] && [ -f $androidInternal/$deeper/redhookbay/system.img.gz ] ; then
	    mkdir -p $targetDirLocal
#	    mkdir -p $targetDirShared
	    echo "Copying redhookbay image to $targetDirLocal"
	    
	    cp $androidInternal/$deeper/redhookbay/*.zip $targetDirLocal
            cp $androidInternal/$deeper/redhookbay/*.img $targetDirLocal
	    cp $androidInternal/$deeper/redhookbay/system/etc/firmware/modem/* $targetDirLocal
    	    cp $androidInternal/$deeper/redhookbay/system.img.gz $targetDirLocal
	#	cp $androidInternal/$deeper/redhookbay/redhookbay-ota-eng.${USER}.zip $targetDirLocal
	#	cp $androidInternal/$deeper/redhookbay/system.img.gz $targetDirLocal
#	else
#		echo "Error: redhookbay-ota-eng.$name.zip and/or system.img.gz not found in $androidInternal/$deeper/redhookbay/"
#	fi

elif [ "$data" == "merrifield" ]; then
    targetDirLocal=$localDir/$cur_date_version/merrifield_$bit
    targetDirShared=$shareDir/$cur_date_version/merrifield_$bit

        mkdir -p $targetDirLocal
        mkdir -p $targetDirShared
        echo "Copying redhookbay image to $targetDirLocal"
        cp $androidInternal/$deeper/saltbay/*.zip $targetDirLocal
        cp $androidInternal/$deeper/saltbay/*.img $targetDirLocal
        cp $androidInternal/$deeper/saltbay/system/etc/firmware/modem/* $targetDirLocal
        cp $androidInternal/$deeper/saltbay/system.img.gz $targetDirLocal
    
elif [ "$data" == "OTC" ]; then
    targetDirLocal=$localDir/$cur_date_version/OTC_$bit
    targetDirShared=$shareDir/$cur_date_version/OTC_$bit

        mkdir -p $targetDirLocal
        mkdir -p $targetDirShared
        echo "Copying redhookbay image to $targetDirLocal"
        cp $androidInternal_OTC/$deeper/core_ufo/*.img  $targetDirLocal
        cp $androidInternal_OTC/$deeper/core_ufo/core_ufo-target_files-eng.${USER}.zip  $targetDirLocal
        cp $androidInternal_OTC/$deeper/core_ufo/ota-dev.zip  $targetDirLocal
        cp $androidInternal_OTC/$deeper/core_ufo/*.gz  $targetDirLocal
        cp $androidInternal_OTC/$deeper/core_ufo/system/etc/firmware/modem/* $targetDirLocal
        cp $androidInternal_OTC/$deeper/core_ufo/system.img.gz $targetDirLocal

elif [ "$data" == "ndk" ]; then
	targetDirShared=$shareDir/$cur_date_version/ndk
	if [ -f $androidExternal/ndk-release-$cur_date/android-ndk-$cur_date-[0-9]*-linux-x86.tar.bz2 ] && ! [ -f $ndkCurrentDir/android-ndk-$cur_date-[0-9]*-linux-x86.tar.bz2 ] ; then
        mkdir -p ${ndkCurrentDir}_temp
		echo "Copying NDK (32 bit) for linux to $ndkCurrentDir"
		cp $androidExternal/ndk-release-$cur_date/android-ndk-$cur_date-[0-9]*-linux-x86.tar.bz2 ${ndkCurrentDir}_temp
		rm -rf $ndkCurrentDir
        mv ${ndkCurrentDir}_temp ${ndkCurrentDir}
    fi
	if [ -f $androidExternal/ndk-release-$cur_date/android-ndk-$cur_date-[0-9]*-windows-x86.zip ] && ! [ -f $targetDirShared/android-ndk-$cur_date-[0-9]*-windows-x86.zip ] ; then
	    echo "Copying NDK (32 bit) for windows to $targetDirShared"
		mkdir -p $targetDirShared
    	cp $androidExternal/ndk-release-$cur_date/android-ndk-$cur_date-[0-9]*-windows-x86.zip $targetDirShared
	fi

	if [ -f $androidExternal/ndk-release-$cur_date/android-ndk-$cur_date-[0-9]*-linux-x86_64.tar.bz2 ]  && ! [ -f $ndkCurrentDir/android-ndk-$cur_date-[0-9]*-linux-x86_64.tar.bz2 ] ; then
        mkdir -p ${ndkCurrentDir64}_temp
		echo "Copying NDK (64 bit) for linux to $ndkCurrentDir"
		cp $androidExternal/ndk-release-$cur_date/android-ndk-$cur_date-[0-9]*-linux-x86_64.tar.bz2 ${ndkCurrentDir64}_temp
		rm -rf $ndkCurrentDir64
        mv ${ndkCurrentDir64}_temp ${ndkCurrentDir64}
    fi
	if [ -f $androidExternal/ndk-release-$cur_date/android-ndk-$cur_date-[0-9]*-windows-x86_64.zip ] && ! [ -f $targetDirShared/android-ndk-$cur_date-[0-9]*-windows-x86_64.zip ] ; then
	    echo "Copying NDK (64 bit) for windows to $targetDirShared"
		mkdir -p $targetDirShared
	    cp $androidExternal/ndk-release-$cur_date/android-ndk-$cur_date-[0-9]*-windows-x86_64.zip $targetDirShared
	fi
fi

exit 0

