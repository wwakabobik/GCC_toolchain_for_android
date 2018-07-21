#!/bin/bash

if [ -z $baseDir ] ; then
	echo "Please setup work directory as baseDir variable"
	exit 1
fi

export cur_date=`date +%Y%m%d` #Current date (example: 20121109) 9 november 2012

source $baseDir/scripts/path.sh

echo "### START building repos ###" 
echo "see log in $rootDir/log/${cur_date}_build_all.log"
$rootDir/scripts/build/build_all.sh > $rootDir/log/${cur_date}_build_all.log 2>&1
echo "### END building repos ###" 

exit 0

