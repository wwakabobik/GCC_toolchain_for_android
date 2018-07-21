#####################################################################
# Script is designed to automate process of building Android - NDK  #
#                                                                   #
# Usage:                                                            #   
# build_NDK.yes [approve]                                           #
# approve - only for avoiding accidential star-up, which clean all  #
#####################################################################

#!/bin/bash

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi

source $baseDir/scripts/path.sh
ulimit -s 64000
buildAOSP=$1
bit=$2
if ! [ -z "$3" ] ; then
	# setup gcc version list
	ver=$3
	sed -e "s/^DEFAULT_GCC_VERSION_LIST=.*/DEFAULT_GCC_VERSION_LIST=\"$ver\"/" -i $androidExternal/ndk/build/tools/dev-defaults.sh
	grep "DEFAULT_GCC_VERSION_LIST=" $androidExternal/ndk/build/tools/dev-defaults.sh
fi

if [ "yes" == "$buildAOSP" ]; then 
	if [ "32" == "$bit" ]; then
		cd $androidExternal
    	make clean
    	mkdir -p out/target/product/generic
    	mkdir -p out/target/product/generic_x86
    	mkdir -p out/target/product/generic_mips
    	echo "Build NDK (32 bit)..."
		echo "see log ${androidExternal}/rebuild-all.log"
    	./ndk/build/tools/dev-rebuild-ndk.sh 
	 	echo "Log is copied in ${rootDir}/log/${cur_date}_build_ndk_32.log"
	 	cp ${androidExternal}/rebuild-all.log ${rootDir}/log/${cur_date}_build_ndk_32.log
	elif [ "64" == "$bit" ]; then
     	cd $androidExternal
    	make clean
     	mkdir -p out/target/product/generic
     	mkdir -p out/target/product/generic_x86
     	mkdir -p out/target/product/generic_mips
     	echo "Build NDK (64 bit)..."
	 	echo "see log ${androidExternal}/rebuild-all.log"
     	./ndk/build/tools/dev-rebuild-ndk.sh --try-64
     	echo "Log is copied in ${rootDir}/log/${cur_date}_build_ndk_64.log"
	 	cp ${androidExternal}/rebuild-all.log ${rootDir}/log/${cur_date}_build_ndk_64.log
    else 
		echo "Second argument must be 32 or 64 only!"
		exit 1
	fi
fi

exit 0

