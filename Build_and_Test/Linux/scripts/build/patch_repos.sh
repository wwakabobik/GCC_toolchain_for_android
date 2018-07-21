#!/bin/bash

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi

source $baseDir/scripts/path.sh

cp $patchFolder/build.patch $androidExternal/ndk/
cd $androidExternal/ndk/
patch -p1 < build.patch



exit 0

