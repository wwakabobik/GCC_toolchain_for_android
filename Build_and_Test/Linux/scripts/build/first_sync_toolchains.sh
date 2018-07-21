#!/bin/bash

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi

source $baseDir/scripts/path.sh
androidToolchain_synced=$rootDir"/repositories/toolchain_synced" #Path to toolchain sources
androidToolchain_synced_tmp=$rootDir"/repositories/toolchain_synced_tmp" #Path to toolchain sources

### Prepare toolchains
rm -rf $androidToolchain_synced_tmp
rm -rf $androidToolchain_synced
mkdir $androidToolchain_synced
mkdir $androidToolchain_synced_tmp
cd $androidToolchain_synced_tmp
repo_ext init -u https://android.googlesource.com/toolchain/manifest
repo_ext sync


### LLVM version may change in future
llvm_prepare () {
    # Check-out and Adjust directory structure a bit
    # 1. Create symbolic link for clang which is always built
    # 2. Create symbolic link for compiler-rt too
    # 3. Move tools/polly up to be a sibling of llvm and clang.  Script build-llvm.sh
    #    will only create symbolic link when --with-polly is specified.
	# See ndk/build/tools/download-toolchain-sources.sh

	llvmRelease=${1//[.]/} 
	rm -rf $androidToolchain_synced_tmp/llvm-$1/llvm
	rm -rf $androidToolchain_synced_tmp/llvm-$1/clang

	mkdir -p $androidToolchain_synced_tmp/llvm-$1/llvm
	mkdir -p $androidToolchain_synced_tmp/llvm-$1/clang

	cd $androidToolchain_synced_tmp/llvm-$1/clang
	git --git-dir=../../clang/.git/ checkout release_$llvmRelease
	git --git-dir=../../clang/.git/ checkout release_$llvmRelease .
	cd $androidToolchain_synced_tmp/llvm-$1/llvm
	git --git-dir=../../llvm/.git/ checkout release_$llvmRelease
	git --git-dir=../../llvm/.git/ checkout release_$llvmRelease .

    (cd $androidToolchain_synced_tmp/llvm-$1/llvm/ && \
        ln -s ../../clang tools && \
        test -d tools/polly && mv tools/polly ..)

	if [ "$1" != "3.1" ]; then
    	# compiler-rt only exists on and after 3.2
    	rm -rf $androidToolchain_synced_tmp/llvm-$1/compiler-rt
    	mkdir -p $androidToolchain_synced_tmp/llvm-$1/compiler-rt
    	cd $androidToolchain_synced_tmp/llvm-$1/compiler-rt
    	git --git-dir=../../compiler-rt/.git/ checkout release_$llvmRelease
    	git --git-dir=../../compiler-rt/.git/ checkout release_$llvmRelease .
    	(cd "$androidToolchain_synced_tmp/llvm-$1/llvm" && \
      		test -d ../compiler-rt && ln -s ../../compiler-rt projects)
	fi
	
	# In polly/utils/cloog_src, touch Makefile.in, aclocal.m4, and configure to
	# make sure they are not regenerated.
	# Fore more information see here https://android-review.googlesource.com/#/c/49393/2

	(test -d "$androidToolchain_synced_tmp/llvm-$1/polly" && \
		cd "$androidToolchain_synced_tmp/llvm-$1/polly" && \
		find . -name "Makefile.in" -exec touch {} \; && \
		find . -name "aclocal.m4" -exec touch {} \; && \
		find . -name "configure" -exec touch {} \; )
}
llvm_prepare 3.1
llvm_prepare 3.2
llvm_prepare 3.3

cd $androidToolchain_synced_tmp
for D in *; do
	if [ -d "${D}" ]; then
		echo "${D}"   # your processing here
		mkdir $androidToolchain_synced/${D}
		mv ${D}/* $androidToolchain_synced/${D}
	fi
done

$androidExternal/ndk/build/tools/patch-sources.sh $androidToolchain_synced $androidExternal/ndk/build/tools/toolchain-patches

