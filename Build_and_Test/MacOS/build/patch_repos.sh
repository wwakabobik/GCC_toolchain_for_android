#!/bin/bash

source %path_file_path%

cp $patchFolder/build.patch $androidExternal/ndk/
cd $androidExternal/ndk/
patch -p1 < build.patch

cp $patchFolder/dev-rebuild-ndk-final.patch $androidExternal/ndk/
cd $androidExternal/ndk/
patch -p1 < dev-rebuild-ndk-final.patch



