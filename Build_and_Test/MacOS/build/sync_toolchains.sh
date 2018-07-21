#!/bin/bash

source %path_file_path%
androidToolchain_synced=$rootDir"/repositories/toolchain_synced" #Path to toolchain sources
androidToolchain_synced_tmp=$rootDir"/repositories/toolchain_synced_tmp" #Path to toolchain sources

### Prepare toolchains
rm -rf  $androidToolchain_synced_tmp
rm -rf  $androidToolchain_synced
mkdir  $androidToolchain_synced
mkdir  $androidToolchain_synced_tmp
cd   $androidToolchain_synced_tmp
repo_ext init -u https://android.googlesource.com/toolchain/manifest
repo_ext sync


### LLVM version may change in future
llvm_prepare () {
  llvmRelease=${1//[.]/} 
  rm -rf $androidToolchain_synced_tmp/llvm-$1/llvm
  rm -rf $androidToolchain_synced_tmp/llvm-$1/clang

  mkdir -p $androidToolchain_synced_tmp/llvm-$1/llvm
  mkdir -p $androidToolchain_synced_tmp/llvm-$1/clang

  cd $androidToolchain_synced_tmp/llvm-$1/clang
  git --git-dir=../../clang/.git/ checkout aosp/release_$llvmRelease #At first run must bew  git --git-dir=../../clang/.git/ checkout  release_32/31
  git --git-dir=../../clang/.git/ checkout aosp/release_$llvmRelease .  #At first run must bew  git --git-dir=../../clang/.git/ checkout  release_32/31
  cd $androidToolchain_synced_tmp/llvm-$1/llvm
  git --git-dir=../../llvm/.git/ checkout aosp/release_$llvmRelease #At first run must be  --git-dir=../../llvm/.git/ checkout  release_32/31
  git --git-dir=../../llvm/.git/ checkout aosp/release_$llvmRelease .  #At first run must bew  git --git-dir=../../clang/.git/ checkout  release_32/31

  (cd $androidToolchain_synced_tmp/llvm-$1/llvm/ && \
	ln -s ../../clang tools && \
	 test -d tools/polly && mv tools/polly ..)
	
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

cd $androidToolchain_synced_tmp
for D in *; do
   if [ -d "${D}" ]; then
       echo "${D}"   # your processing here
     mkdir $androidToolchain_synced/${D}
     mv ${D}/* $androidToolchain_synced/${D} 
#      copy_directory ${D} $androidToolchain_synced/${D}
    fi
done

$androidExternal/ndk/build/tools/patch-sources.sh  $androidToolchain_synced $androidExternal/ndk/build/tools/toolchain-patches
    
