#!/bin/bash

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi

source $baseDir/scripts/path.sh



cp $patchFolder/trunk/ordered/*  $androidToolchain_synced/gcc/

cd $androidToolchain_synced/gcc/
for f in *.patch ; do patch -p1 < "$f"; done


exit 0

