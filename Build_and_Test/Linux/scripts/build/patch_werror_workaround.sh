#!/bin/bash

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi

source $baseDir/scripts/path.sh

cp $patchFolder/All_in_one_MCG.patch  $androidInternal
cd  $androidInternal
patch -p1 < All_in_one_MCG.patch

cp $patchFolder/All_in_one_OTC.patch  $androidInternal_OTC
cd  $androidInternal_OTC
patch -p1 < All_in_one_OTC.patch

cp $patchFolder/patch_werror_workaround_aosp.patch  $androidExternal
cd  $androidExternal
patch -p1 < patch_werror_workaround_aosp.patch

exit 0

