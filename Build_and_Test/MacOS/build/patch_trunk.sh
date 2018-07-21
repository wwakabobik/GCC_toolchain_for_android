#!/bin/bash

source %path_file_path%


##BUILD PROJECT DIR
cp $patchFolder/trunk/0001-Message-TBD-build-project-tuning-for-4.8.patch  $androidToolchain_synced/build/
cd $androidToolchain_synced/build/
patch -p1 < 0001-Message-TBD-build-project-tuning-for-4.8.patch


##GCC-4.8 DIR
cp $patchFolder/trunk/0001-Message-TBD-fix-libgomp-and-libatomic-configure-pthr.patch  $androidToolchain_synced/gcc/gcc-4.9/
cd  $androidToolchain_synced/gcc/gcc-4.9/
patch -p1 < 0001-Message-TBD-fix-libgomp-and-libatomic-configure-pthr.patch

cp $patchFolder/trunk/0002-Message-TBD-0001-Enable-C-exceptions-and-RTTI-by-def.patch  $androidToolchain_synced/gcc/gcc-4.9/
cd  $androidToolchain_synced/gcc/gcc-4.9/
patch -p1 < 0002-Message-TBD-0001-Enable-C-exceptions-and-RTTI-by-def.patch

cp $patchFolder/trunk/0003-Message-TBD-0001-gcc-4.6-and-4.7-Disable-sincos-opti.patch  $androidToolchain_synced/gcc/gcc-4.9/
cd  $androidToolchain_synced/gcc/gcc-4.9/
patch -p1 < 0003-Message-TBD-0001-gcc-4.6-and-4.7-Disable-sincos-opti.patch

cp $patchFolder/trunk/0004-Message-TBD-0002-gcc-prevent-crash-on-Eclair-and-old.patch  $androidToolchain_synced/gcc/gcc-4.9/
cd  $androidToolchain_synced/gcc/gcc-4.9/
patch -p1 < 0004-Message-TBD-0002-gcc-prevent-crash-on-Eclair-and-old.patch

cp $patchFolder/trunk/0005-Message-TBD-0006-Disable-libstdc-versioning.patch.patch  $androidToolchain_synced/gcc/gcc-4.9/
cd  $androidToolchain_synced/gcc/gcc-4.9/
patch -p1 < 0005-Message-TBD-0006-Disable-libstdc-versioning.patch.patch

cp $patchFolder/trunk/gcc-trunk-Disable-libstdc-versioning.patch  $androidToolchain_synced/gcc/gcc-4.9/
cd  $androidToolchain_synced/gcc/gcc-4.9/
patch -p1 < gcc-trunk-Disable-libstdc-versioning.patch

cp $patchFolder/trunk/gcc_48_lpthread.patch  $androidToolchain_synced/gcc/
cd  $androidToolchain_synced/gcc/
patch -p1 < gcc_48_lpthread.patch



##GDB DIR
cp $patchFolder/trunk/0001-Message-TBD-gdb-project-tuning-for-4.8.patch  $androidToolchain_synced/gdb/
cd  $androidToolchain_synced/gdb/
patch -p1 < 0001-Message-TBD-gdb-project-tuning-for-4.8.patch


