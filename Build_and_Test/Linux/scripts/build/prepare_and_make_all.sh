#!/bin/bash

if [ -z $baseDir ] ; then
	echo "Please setup work directory as baseDir variable"
	exit 1
fi

export cur_date=`date +%Y%m%d` #Current date (example: 20121109) 9 november 2012

source $baseDir/scripts/path.sh

echo "### START Preparing repos ###" 
echo "see log in $rootDir/log/${cur_date}_sync_repos.log"
$rootDir/scripts/build/sync_repos.sh > $rootDir/log/${cur_date}_sync_repos.log 2>&1
echo "### END Preparing repos ###" 

echo "### START Preparing toolchains ###" 
echo "see log in $rootDir/log/${cur_date}_sync_toolchains.log"
$rootDir/scripts/build/sync_toolchains.sh > $rootDir/log/${cur_date}_sync_toolchains.log 2>&1
echo "### END Preparing toolchains ###" 

echo "### START Preparing trunk ###" 
cd $rootDir/repositories/gcc_trunk
svn rever -R .
svn update
mkdir -p $androidToolchain_synced/gcc/gcc-4.9/
cp -R $rootDir/repositories/gcc_trunk/* $androidToolchain_synced/gcc/gcc-4.9/
echo "### END Preparing trunk ###" 

echo "### START Patching repos ###"
echo "see log in $rootDir/log/${cur_date}_patch.log"
$rootDir/scripts/build/patch_repos.sh > $rootDir/log/${cur_date}_patch.log 2>&1
$rootDir/scripts/build/patch_trunk.sh >> $rootDir/log/${cur_date}_patch.log 2>&1
$rootDir/scripts/build/patch_werror_workaround.sh >> $rootDir/log/${cur_date}_patch.log 2>&1
echo "### END Patching repos ###"  

echo "### START building repos ###" 
echo "see log in $rootDir/log/${cur_date}_build_friday.log"
$rootDir/scripts/build/build_friday.sh > $rootDir/log/${cur_date}_build_friday.log 2>&1
echo "### END building repos ###" 


/nfs/ims/proj/icl/gcc_cw/share/monitor/TRAQs/NDKres2xml.sh 32
/nfs/ims/proj/icl/gcc_cw/share/monitor/TRAQs/NDKres2xml.sh 64


/nfs/ims/proj/icl/gcc_cw/share/monitor/TRAQs/imageres2xml.sh Merrifield 32
/nfs/ims/proj/icl/gcc_cw/share/monitor/TRAQs/imageres2xml.sh Merrifield 64

/nfs/ims/proj/icl/gcc_cw/share/monitor/TRAQs/imageres2xml.sh HarrisBeach 32
/nfs/ims/proj/icl/gcc_cw/share/monitor/TRAQs/imageres2xml.sh HarrisBeach 64
#/nfs/ims/proj/icl/gcc_cw/share/monitor/TRAQs/imageres2xml.sh Harrisbeach 32




exit 0

