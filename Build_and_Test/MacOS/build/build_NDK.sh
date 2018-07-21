#####################################################################
# Script is designed to automate process of building Android - NDK  #
#                                                                   #
# Usage:                                                            #   
# build_NDK.yes [approve]                                           #
# approve - only for avoiding accidential star-up, which clean all  #
#####################################################################

#!/bin/bash

source  %path_file_path%
ulimit -s 64000
buildAOSP=$1
bit=$2
if [ "yes" == "$buildAOSP" ]; then 
   if [ "32" == "$bit" ]; then
     cd $androidExternal
     make clean
     echo "Delete and make new out directory"
     rm -rf out
     mkdir -p out/target/product/generic
     mkdir -p out/target/product/generic_x86
     mkdir -p out/target/product/generic_mips
     echo "Run building"
     ./ndk/build/tools/dev-rebuild-ndk.sh 
    fi
    if [ "64" == "$bit" ]; then
     cd $androidExternal
     make clean
     echo "Delete and make new out directory"
     rm -rf out
     mkdir -p out/target/product/generic
     mkdir -p out/target/product/generic_x86
     mkdir -p out/target/product/generic_mips
     echo "Run building"
     ./ndk/build/tools/dev-rebuild-ndk.sh --try-64
    fi
fi


