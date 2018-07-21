#!/bin/bash

#device=$1
#compiler=$2
#bits_supported=(32 64)

#devices=(Medfield CloverTrail Nexus4 GalaxyNexus HarrisBeach Merrifield)
devices=(GalaxyNexus Nexus4)
compilers=(4.4.3 4.6.2 4.7.2 4.8.0 4.8.1 4.9.0)

db_command=sqlite3
share=/nfs/ims/proj/icl/gcc_cw/share
ndkR=NDK_Regressions
dbname=ndk_regressions_${device}.db

#for bits in ${bits_supported[*]}
#do
    for device in ${devices[*]}
    do
	dbname=ndk_regressions_${device}.db
	for compiler in ${compilers[*]}
	do
	    echo "EXECUTING: $db_command $share/$ndkR/$dbname \"select test_date from Summaries where ndk_version='$compiler' and type='total'\""
	    dbquery=`$db_command $share/$ndkR/$dbname "select test_date from Summaries where ndk_version='$compiler' and type='total'"`
	    array=( $( for i in $dbquery ; do echo $i ; done ) )
	    #echo $array
	    for i in ${array[@]}
	    do
		revision=`echo $i | sed 's/_/\//g'`
		#echo $revision
		./create_xml.py $revision 32 $compiler $device 1>>out.log 2>>err.log
		mv report.xml report_${device}_${compiler}_${i}.xml 2>/dev/null
		if [ $? != 0 ]; then
		    echo "report_${device}_${compiler}_${i}.xml failed to get right data" >>err.log
		fi
		./submit.sh report_${device}_${compiler}_${i}.xml >>submit.log
		mv report_${device}_${compiler}_${i}.xml ./Reports/report_${device}_${compiler}_${i}.xml
		mv report_${device}_${compiler}_${i}.zip ./Zip/report_${device}_${compiler}_${i}.zip
	    done
	done
    done
#done