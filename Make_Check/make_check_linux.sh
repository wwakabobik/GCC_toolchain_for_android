#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    make_check_linux.sh
# Purpose: gcc for linux configure, building, checking script
#          adopted to be much more similar to NDK settings
#
# Author:      Iliya Vereshchagin
#
# Created:     20.05.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------

cur_date=`date +%Y%m%d`
cur_date_format=`date +%m/%d/%Y`
cur_pwd=`pwd`
branch=$1
p_length=$2
space=$3

if [ "$PARALLEL" != "" ] ; then
  parallel=$PARALLEL
else
  parallel="-j 8"
fi

export PATH=/usr/local32/bin:$PATH
export CC="gcc -m32"
export CXX="g++ -m32"
export LD_LIBRARY_PATH=/usr/lib/gcc/i686-redhat-linux/4.7.2:$LD_LIBRARY_PATH

export ROOT_DIR=$PWD

if [ -d $ROOT_DIR/$space/builds/$branch/$p_length/$cur_date ] ; then
  echo build $ROOT_DIR/$space/builds/$branch/$p_length/$cur_date already exist, remove before rebuild
  exit 1;
fi

mkdir -p $ROOT_DIR/$space/builds/$branch/$p_length/$cur_date
mkdir -p $ROOT_DIR/$space/work/$branch/$p_length/logs
mkdir -p $ROOT_DIR/$space/work/$branch/$p_length/install
mkdir -p $ROOT_DIR/$space/work/$branch/$p_length/build
mkdir -p $ROOT_DIR/$space/work/$branch/$p_length/check

rm -rf $ROOT_DIR/$space/work/$branch/$p_length/install/*
rm -rf $ROOT_DIR/$space/work/$branch/$p_length/build/*
cd $ROOT_DIR/$space/work/$branch/$p_length/build

#start workaround cycle

conf_array=(--disable-ppl-version-check --disable-cloog-version-check --enable-cloog-backend=isl --disable-libssp --enable-threads --disable-nls --disable-libmudflap --disable-libgomp --disable-sjlj-exceptions --disable-shared --disable-tls --disable-libitm --with-arch=i686 --with-tune=atom --with-fpmath=sse --enable-initfini-array --disable-nls --with-binutils-version=2.22 --with-mpfr-version=3.1.1 --with-mpc-version=1.0.1 --with-gmp-version=5.0.5 --with-gcc-version=4.7 --with-gdb-version=7.3.x --disable-bootstrap --disable-libquadmath --enable-plugins --enable-libgomp --enable-gold --enable-graphite=yes --with-cloog-version=0.17.0 --with-ppl-version=1.0)

#default flags
config_flags="--enable-languages=c,c++ --with-gnu-as --with-gnu-ld --target=i686-linux-gnu --host=i686-linux-gnu --build=i686-linux-gnu" #--with-host-libstdcxx='-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm'"

#check for supported flags
for arg in ${conf_array[*]}
do
config_flags=$config_flags" "$arg
done

echo Configuring gcc

echo "Using flags=$config_flags"

if [ "$p_length" == "32" ] ; then
$ROOT_DIR/$space/configure i686-linux CFLAGS="-m32 -Wa,--32 -Wl,-melf_i386" CXXFLAGS="-m32 -Wa,--32 -Wl,-melf_i386" $config_flags --prefix=$ROOT_DIR/$space/work/$branch/$p_length/install 1>$ROOT_DIR/$space/work/$branch/$p_length/logs/configure.${cur_date}.log 2>&1
else
  $ROOT_DIR/$space/configure $config_flags --prefix=$ROOT_DIR/$space/work/$branch/$p_length/install --enable-languages=c,c++,fortran 1>$ROOT_DIR/$space/work/$branch/$p_length/logs/configure.${cur_date}.log 2>&1
fi

if [ "$?" != "0" ] ; then
  echo some problems with gcc configure see $ROOT_DIR/$space/work/$branch/$p_length/logs/configure.${cur_date}.log
  exit 3;
fi

echo ok

make clean

echo Building gcc

if [ "$p_length" == "32" ] ; then
  make $parallel   1>$ROOT_DIR/$space/work/$branch/$p_length/logs/make.${cur_date}.log 2>&1
else
  make $parallel   1>$ROOT_DIR/$space/work/$branch/$p_length/logs/make.${cur_date}.log 2>&1
fi

if [ "$?" != "0" ] ; then
  echo some problems with gcc make see $ROOT_DIR/$space/work/$branch/$p_length/logs/make.${cur_date}.log
  exit 4;
fi
echo ok

echo Checking gcc
make check $parallel 1>$ROOT_DIR/$space/work/$branch/$p_length/logs/make_check.${cur_date}.log 2>&1
if [ "$?" != "0" ] ; then
  echo WARNING: some problems with gcc make check see $ROOT_DIR/$space/work/$branch/$p_length/logs/make_check.${cur_date}.log
fi
echo ok
 exit 0

