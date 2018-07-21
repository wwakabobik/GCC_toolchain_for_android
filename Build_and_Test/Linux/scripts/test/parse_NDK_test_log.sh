#!/bin/sh

if [ -z $baseDir ] ; then
    echo "Please setup work directory as baseDir variable"
    exit 1
fi

if [ -z $1 ] ; then
	echo "Example: $0 4.7 RHBEC245500390 20130628"
	exit 1
fi
version=$1
export ANDROID_SERIAL=$2
if [ -z $ANDROID_SERIAL ] ; then
    echo "Device serial doesn't specified! Setup it as second argument"
    exit 1
fi
cur_date=$3
if [ -z $cur_date ]; then
    hour=`date +%_H`
    if  [[ "$hour" -le 14 ]]; then
        cur_date=`date +%Y%m%d -d "yesterday"`
    else
        cur_date=`date +%Y%m%d`
    fi
fi

dir=${baseDir}/results/Devices/${cur_date}/${ANDROID_SERIAL}/${version}
cd $dir
pwd
file="$(ls *tests.log)"

if ! grep -Fxq 'Done.' ${file} ; then
    echo -n "Warning! Log isn't full! continue? (y/n): "
	read ans
	if [ $ans != "y" ] || [ $ans != '\n' ] ; then
		exit 1
	fi
fi
echo '### Build failures: ###'
awk '/BUILD\ FAILURE/{print x;next}{x=$0;}' ${file}
echo
echo '### Run failures: ###'
awk '/TEST\ FAILED/{print x;next}{x=$0;}' ${file}

exit 0

