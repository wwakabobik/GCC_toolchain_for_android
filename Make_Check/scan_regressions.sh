#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    scan_regressions.sh
# Purpose: script compares two logs and writes into temporary log result of
#          comparison. For FAIL and PASS cases unexpected behaviour will be
#          ignored.
#
# Author:      Iliya Vereshchagin
#
# Created:     30.10.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------

y=`basename $0`
$ndebug echo "$y started with parameters:"
$ndebug echo "   $1"
$ndebug echo "   $2"
$ndebug echo "   $3"
$ndebug echo "   $4"

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
    echo "no input\output criteria specified for regression scan, aborted"
    exit -1
fi

random=`echo $RANDOM`.`echo $$`

current_log=$1
last_log=$2
criteria=$3

if [ -z $4 ]; then
    out_file="./temp.log"
else
    out_file=$4
fi

$ndebug echo "$y: current folder is $PWD"
$ndebug echo "$y: PATH=$PATH"

grep $criteria $current_log >${random}.$criteria.new
sed -i 's/\x2A/æ/g' ${random}.$criteria.new
if [ "$criteria" = "FAIL:" ]; then
    grep -v "XFAIL: " ${random}.$criteria.new | grep -v "percentages not found" >${random}.$criteria.new2
    rm ${random}.$criteria.new
    mv ${random}.$criteria.new2 ${random}.$criteria.new
elif [ "$criteria" = "PASS:" ]; then
    grep -v "XPASS: " ${random}.$criteria.new >${random}.$criteria.new2
    rm ${random}.$criteria.new
    mv ${random}.$criteria.new2 ${random}.$criteria.new
else
    x=0
fi
if [ -f ${random}.$criteria.new2 ]; then
    rm ${random}.$criteria.new2
fi

touch ${random}.$criteria.new2
yy="*${criteria} "

while read line
do
    xx=`echo ${line#$yy}`
    xx1="${criteria} "$xx
    xx=$xx1
    echo $xx >>${random}.$criteria.new2
done < ${random}.$criteria.new
cat ${random}.$criteria.new2 >${random}.$criteria.new

echo "There are number of lines and file name:"
wc -l ${random}.$criteria.new

grep $criteria $last_log >${random}.$criteria.old
sed -i 's/\x2A/æ/g' ${random}.$criteria.old
if [ "$criteria" = "FAIL:" ]; then
    grep -v "XFAIL: " ${random}.$criteria.old | grep -v "percentages not found"  >${random}.$criteria.old2
    rm ${random}.$criteria.old
    mv ${random}.$criteria.old2 ${random}.$criteria.old
elif [ "$criteria" = "PASS:" ]; then
    grep -v "XPASS: " ${random}.$criteria.old >${random}.$criteria.old2
    rm ${random}.$criteria.old
    mv ${random}.$criteria.old2 ${random}.$criteria.old
else
    x=0
fi
if [ -f ${random}.$criteria.old2 ]; then
    rm ${random}.$criteria.old2
fi
touch ${random}.$criteria.old2
yy="*${criteria} "
while read line
do
    xx=`echo ${line#$yy}`
    xx1="${criteria} "$xx
    xx=$xx1
    echo $xx >>${random}.$criteria.old2
done < ${random}.$criteria.old
cat ${random}.$criteria.old2 >${random}.$criteria.old

wc -l ${random}.$criteria.old

sort -o ${random}.$criteria.old ${random}.$criteria.old
sort -o ${random}.$criteria.new ${random}.$criteria.new

#display unique rows of 1st file:
comm -23 ${random}.$criteria.new ${random}.$criteria.old >tmp1

if [ "$criteria" = "FAIL:" ]; then
    #ignore gcov noise
    grep -v ":should be " tmp1 >tmp2
    #ignore XFAIL
    grep -v "XFAIL: " tmp2 >tmp1
fi

if [ "$criteria" = "PASS:" ]; then
    #ignore XPASS
    grep -v "XPASS: " tmp1 >tmp2
    cat tmp2 >tmp1
fi
sed -i 's/æ/\x2A/g' tmp1

cat tmp1 >>$out_file
rm ${random}.$criteria.old $debug 1>/dev/null 2>/dev/null
rm ${random}.$criteria.new $debug 1>/dev/null 2>/dev/null
rm ${random}.$criteria.new2 $debug 1>/dev/null 2>/dev/null
rm ${random}.$criteria.old2 $debug 1>/dev/null 2>/dev/null
rm tmp1 $debug 1>/dev/null 2>/dev/null
rm tmp2 $debug 1>/dev/null 2>/dev/null

exit 0
