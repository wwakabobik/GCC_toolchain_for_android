#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    Android_MC_Bridge_GPP.sh
# Purpose: configuration and test script for NDK compilers make check,
#          using gcc testsuite, for test_installed via adb method for g++
#
# Author:      Iliya Vereshchagin
#
# Created:     25.10.2012
# Copyright:   Conributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------


y=`basename $0`
$ndebug echo "$y started with parameters:"
$ndebug echo "   $1"
$ndebug echo "   $2"
$ndebug echo "   $3  $4  $5  $6  $7  $8  $9"

#Local environment
build=$1
ROOT_DIR=$2
NDK_DIR=$3

if [ -z $4 ]; then
    compiler=4.7
else
    compiler=$4
fi

if [ -z $5 ]; then
    platform=9
else
    platform=$5
fi

if [ -z $6 ]; then
    ndk_arch="x86"
else
    ndk_arch=$6
fi

if [ -z $7 ]; then
    compiler_arch="x86"
else
    compiler_arch=$7
fi

if [ -z $8 ]; then
    binary="i686-linux-android"
else
    binary=$8
fi

if [ -z $9 ]; then
    libs_alias="x86"
else
    libs_alias=$9
fi

if [ -z ${10} ]; then
    bits=32
else
    bits=${10}
fi

process_folder="$ROOT_DIR/$build/ANDROID"

NDK_include=""
stl_type=""
stl_lib_name=""
if [ -z $android_stl_type ] || [ $android_stl_type == "gnustl" ]; then
   stl_lib_name="lgnustl"
   stl_type="gnu-libstdc++/$compiler"
   NDK_include="include"
elif [ $android_stl_type == "stlport" ]; then
   stl_lib_name="lstlport"
   stl_type=$android_stl_type
   NDK_include="stlport"
elif [ $android_stl_type == "gabi++" ]; then
   stl_lib_name="lgabi++"
   stl_type=$android_stl_type
   NDK_include="include"
else
   echo "environment variable android_stl_type=\"$android_stl_type\" has wrong value, aborted"
   cd $rootme
   exit -1
fi

if [ $bits == 64 ]; then
    bits_for_compiler="_64"
fi

NDK_bin="toolchains/$compiler_arch-$compiler/prebuilt/linux-x86${bits_for_compiler}/bin"
NDK_root="platforms/android-$platform/arch-$ndk_arch"
NDK_prefix="toolchains/$compiler_arch-$compiler/prebuilt/linux-x86${bits_for_compiler}/$binary"

NDK_libstdc="sources/cxx-stl/$stl_type"
NDK_lib="libs/$libs_alias"

#Check for g++ compiler
#We should use g++ wrapper to pass parameters to linker in correct order, so be sure, that the g++ wrapper script exists and correctly configured!
if [ ! -f $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-gcc ] || [ ! -f $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-g++ ] || [ ! -f $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-gcov ] || [ ! -f $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-nm ] || [ ! -f $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-gdb ]; then
    $ndebug echo "$y: At least, one of the following NDK compiler binaries is absent:"
    $ndebug echo "   $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-gcc"
    $ndebug echo "   $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-g++"
    $ndebug echo "   $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-gcov"
    $ndebug echo "   $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-nm"
    $ndebug echo "   $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-gdb"
    $ndebug echo "$y FAILed!"
    $debug echo "Compiler binaries missed, therefore aborted!"
    exit -1
fi

#Prepare environment
rm -rf $process_folder $debug 1>/dev/null 2>/dev/null
rmdir $process_folder $debug 1>/dev/null 2>/dev/null
mkdir $process_folder $debug 1>/dev/null 2>/dev/null
cp $ROOT_DIR/$build/contrib/test_installed $process_folder/test_installed
chmod 755 $process_folder/test_installed

#Create temporary wrapper

rm $process_folder/wrapper-gcc $debug 1>/dev/null 2>/dev/null
rm $process_folder/wrapper-gcc-nokey $debug 1>/dev/null 2>/dev/null
rm $process_folder/wrapper-g++ $debug 1>/dev/null 2>/dev/null
rm $process_folder/wrapper-g++-nokey $debug 1>/dev/null 2>/dev/null
rm $process_folder/wrapper-gcov $debug 1>/dev/null 2>/dev/null
rm $process_folder/wrapper-nm $debug 1>/dev/null 2>/dev/null
echo Old wrappers removed...

echo Creating new wrappers...

cat >$process_folder/wrapper-gcc <<EOF
#!/bin/bash

$ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-gcc --sysroot=$ROOT_DIR/$NDK_DIR/$NDK_root $device_tune "\$@"
EOF

$ndebug echo "wrapper-gcc is below:"
$ndebug cat $process_folder/wrapper-gcc
$ndebug echo " "

cat >$process_folder/wrapper-gcc-nokey <<EOF
#!/bin/bash

$ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-gcc --sysroot=$ROOT_DIR/$NDK_DIR/$NDK_root $device_tune "\$@"
EOF

cat >$process_folder/wrapper-g++ <<EOF
#!/bin/bash

echo \$@ | grep " \-nostdlib" 1>/dev/null 2>/dev/null
if [ \$? != 0 ]; then
    echo \$@ | grep " \-static" 1>/dev/null 2>/dev/null
    if [ \$? != 0 ]; then
       $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-g++ --sysroot=$ROOT_DIR/$NDK_DIR/$NDK_root -I$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_include -I$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_lib/$NDK_include -L$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_lib $device_tune "\$@" -${stl_lib_name}_shared
    else
       $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-g++ --sysroot=$ROOT_DIR/$NDK_DIR/$NDK_root -I$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_include -I$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_lib/$NDK_include -L$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_lib $device_tune "\$@" -${stl_lib_name}_static
    fi
else
    $ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-g++ --sysroot=$ROOT_DIR/$NDK_DIR/$NDK_root -I$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_include -I$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_lib/$NDK_include -L$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_lib $device_tune "\$@"
fi
EOF

$ndebug echo "wrapper-g++ is below:"
$ndebug cat $process_folder/wrapper-g++
$ndebug echo " "

cat >$process_folder/wrapper-g++-nokey <<EOF
#!/bin/bash

$ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-g++ --sysroot=$ROOT_DIR/$NDK_DIR/$NDK_root -I$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_include -I$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_lib/$NDK_include -L$ROOT_DIR/$NDK_DIR/$NDK_libstdc/$NDK_lib $device_tune "\$@"
EOF

cat >$process_folder/wrapper-gcov <<EOF
#!/bin/bash

$ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-gcov "\$@"
EOF

cat >$process_folder/wrapper-nm <<EOF
#!/bin/bash

$ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-nm "\$@"
EOF

cat >$process_folder/wrapper-gdb <<EOF
#!/bin/bash

$ROOT_DIR/$NDK_DIR/$NDK_bin/$binary-gdb "\$@"
EOF

echo Set permissions...

chmod 755 $process_folder/wrapper-gcc
chmod 755 $process_folder/wrapper-gcc-nokey
chmod 755 $process_folder/wrapper-g++
chmod 755 $process_folder/wrapper-g++-nokey
chmod 755 $process_folder/wrapper-gcov
chmod 755 $process_folder/wrapper-nm
chmod 755 $process_folder/wrapper-gdb

#Go to process folder
cd $process_folder

$debug echo "Make check for $build for Android Phone"
$ndebug echo "Make check for the folder $build (you  may  observe being formed results in its ANDROID subfolder) for Android on Phone"
$ndebug echo "./test_installed is launched."
check_error=0
./test_installed --without-gfortran --without-objc --tmpdir="." --with-gcov="$process_folder/wrapper-gcov" --with-g++="$process_folder/wrapper-g++" --with-gcc="$process_folder/wrapper-gcc" --with-gdb="$process_folder/wrapper-gdb"  1>RESULT_output 2>RESULT_err
if [ $? != 0 ]; then
    $ndebug echo "$0:  ./test_installed returned NON-ZERO !"
    check_error=1
$ndebug else
    $ndebug echo "./test_installed is completed OK."
fi
# -v -v -v 1>/dev/null 2>/dev/null

#Clean up
echo "Cleaning up..."
rm ./test_installed $debug 1>/dev/null 2>/dev/null
rm ./ecn_rc $debug 1>/dev/null 2>/dev/null
rm ./ecn_stderr $debug 1>/dev/null 2>/dev/null
rm ./*.gcov $debug 1>/dev/null 2>/dev/null
rm ./*.gcda $debug 1>/dev/null 2>/dev/null
rm ./*.gcno $debug 1>/dev/null 2>/dev/null
rm ./*.exe $debug 1>/dev/null 2>/dev/null
rm ./*.o $debug 1>/dev/null 2>/dev/null
rm ./*.ii $debug 1>/dev/null 2>/dev/null
rm ./*.s $debug 1>/dev/null 2>/dev/null
rm -r ./*struct-layout* $debug 1>/dev/null 2>/dev/null
rm ./*.x* $debug 1>/dev/null 2>/dev/null
rm ./*.alias $debug 1>/dev/null 2>/dev/null
rm ./*.profile_estimate $debug 1>/dev/null 2>/dev/null
rm ./*.H $debug 1>/dev/null 2>/dev/null
rm ./*.gdb $debug 1>/dev/null 2>/dev/null
rm ./*.vect $debug 1>/dev/null 2>/dev/null
rm ./*.hoist $debug 1>/dev/null 2>/dev/null
rm ./*.profile $debug 1>/dev/null 2>/dev/null
rm ./*.optimized $debug 1>/dev/null 2>/dev/null
rm ./*.einline $debug 1>/dev/null 2>/dev/null
rm ./*.tracer $debug 1>/dev/null 2>/dev/null
rm ./*.tailc $debug 1>/dev/null 2>/dev/null
rm ./*.stdarg $debug 1>/dev/null 2>/dev/null
rm ./*.expand $debug 1>/dev/null 2>/dev/null
rm ./*.vcg $debug 1>/dev/null 2>/dev/null
rm ./*.tree_profile $debug 1>/dev/null 2>/dev/null
rm ./*.loop2_unroll $debug 1>/dev/null 2>/dev/null
rm ./*.gkd $debug 1>/dev/null 2>/dev/null
rm ./*.dse1 $debug 1>/dev/null 2>/dev/null
rm ./*.ira $debug 1>/dev/null 2>/dev/null
rm ./*.dse $debug 1>/dev/null 2>/dev/null
rm ./wrapper-* $debug 1>/dev/null 2>/dev/null

cd $ROOT_DIR

if [ $check_error == 0 ]; then
    $ndebug echo "$y is completed OK"
    exit 0
else
    $ndebug echo "$y returned NON-ZERO !"
    echo "Make check failed, therefore aborted"
    exit -1
fi
