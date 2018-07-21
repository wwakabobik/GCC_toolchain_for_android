#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    get_excel_summary.sh
# Purpose: parses gcc and g++ summaries for further pass to excel format (csv),
#          contains data: gcc, total. Additionally checks regressions.
#
# Author:      Iliya Vereshchagin
#
# Created:     20.09.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------

if [ -z $device_target_bits ]; then
    device_target_bits=32
fi

y=`basename $0`
$ndebug echo "$y started with parameters:"
$ndebug echo "   $1"
$ndebug echo "   $2"
$ndebug echo "   $3"
$ndebug echo "   $4"
$ndebug echo "   $5  $6  $7  $8  $9 ${10} ${11}"

out_file_dir_gcc=$1
out_file_dir_gpp=$2
svn_result_dir=$3
cur_date=$4
ndk_version=$5
post_result=$6

database=$7
compiler=$8
bits=$9
tested_object=${10}
image_type=${11}

path_to_ndk_regressions="/nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions"
fprefix=$path_to_ndk_regressions/$ndk_version/$database.$tested_object.$bits.$image_type.$cur_date.$USER
out_log=$path_to_ndk_regressions/$ndk_version/progressions_and_regressions_${tested_object}_${bits}_${image_type}_${cur_date}.log
tmp1_file=$fprefix.tmp1
tmp2_file=$fprefix.tmp2
stderr=$fprefix.stderr
stdout=$fprefix.stdout
grep_stdout=$fprefix.grep.stdout
temp_log=$fprefix.temp.log

echo "$y: current folder $PWD"

if [ -f $out_file_dir_gcc/gcc.log ]; then
    grep "=== gcc Summary ===" -B1 -A7 $out_file_dir_gcc/gcc.log >$tmp1_file
else
    touch $tmp1_file
fi

if [ -f $out_file_dir_gpp/g++.log ]; then
    grep "=== g++ Summary ===" -B1 -A7 $out_file_dir_gpp/g++.log >$tmp2_file
else
    touch $tmp2_file
fi

#MAIN_RESULTS
grep -v "Executing " $tmp1_file >$fprefix.mc1_summary_only.txt
grep -v "Executing " $tmp2_file >$fprefix.mc2_summary_only.txt
#delete formating
sed 's/\t\t/\t/' $fprefix.mc1_summary_only.txt >$tmp1_file
sed 's/\t\t/\t/' $fprefix.mc2_summary_only.txt >$tmp2_file
rm $fprefix.mc1_summary_only.txt $debug 1>/dev/null 2>/dev/null
rm $fprefix.mc2_summary_only.txt $debug 1>/dev/null 2>/dev/null

#gcc
GCC_XPASS=`grep "# of expected passes" $tmp1_file | sed 's/# of expected passes\t//'`
GCC_UFAIL=`grep "# of unexpected failures" $tmp1_file | sed 's/# of unexpected failures\t//'`
GCC_XFAIL=`grep "# of expected failures" $tmp1_file | sed 's/# of expected failures\t//'`
GCC_UNSUPPORTED=`grep "# of unsupported tests" $tmp1_file | sed 's/# of unsupported tests\t//'`
GCC_UNRESOLVED=`grep "# of unresolved testcases" $tmp1_file | sed 's/# of unresolved testcases\t//'`
GCC_UPASS=`grep "# of unexpected successes" $tmp1_file | sed 's/# of unexpected successes\t//'`

#fill empty results with zeros
if [ -z $GCC_XPASS ]; then
    GCC_XPASS=0
fi
if [ -z $GCC_UFAIL ]; then
    GCC_UFAIL=0
fi
if [ -z $GCC_XFAIL ]; then
    GCC_XFAIL=0
fi
if [ -z $GCC_UNSUPPORTED ]; then
    GCC_UNSUPPORTED=0
fi
if [ -z $GCC_UNRESOLVED ]; then
    GCC_UNRESOLVED=0
fi
if [ -z $GCC_UPASS ]; then
    GCC_UPASS=0
fi

#g++
GPP_XPASS=`grep "# of expected passes" $tmp2_file | sed 's/# of expected passes\t//'`
GPP_UFAIL=`grep "# of unexpected failures" $tmp2_file | sed 's/# of unexpected failures\t//'`
GPP_XFAIL=`grep "# of expected failures" $tmp2_file | sed 's/# of expected failures\t//'`
GPP_UNSUPPORTED=`grep "# of unsupported tests" $tmp2_file | sed 's/# of unsupported tests\t//'`
GPP_UNRESOLVED=`grep "# of unresolved testcases" $tmp2_file | sed 's/# of unresolved testcases\t//'`
GPP_UPASS=`grep "# of unexpected successes" $tmp2_file | sed 's/# of unexpected successes\t//'`

#fill empty results with zeros
if [ -z $GPP_XPASS ]; then
    GPP_XPASS=0
fi
if [ -z $GPP_UFAIL ]; then
    GPP_UFAIL=0
fi
if [ -z $GPP_XFAIL ]; then
    GPP_XFAIL=0
fi
if [ -z $GPP_UNSUPPORTED ]; then
    GPP_UNSUPPORTED=0
fi
if [ -z $GPP_UNRESOLVED ]; then
    GPP_UNRESOLVED=0
fi
if [ -z $GPP_UPASS ]; then
    GPP_UPASS=0
fi

rm $tmp1_file
rm $tmp2_file

#OLD RESULTS
if [ -f  $svn_result_dir/gcc.log ]; then
    grep "=== gcc Summary ===" -B1 -A7 $svn_result_dir/gcc.log >$tmp1_file
else
    touch $tmp1_file
fi

if [ -f  $svn_result_dir/g++.log ]; then
    grep "=== g++ Summary ===" -B1 -A7 $svn_result_dir/g++.log >$tmp2_file
else
    touch $tmp2_file
fi

grep -v "Executing " $tmp1_file >$fprefix.mc1_summary_only.txt
grep -v "Executing " $tmp2_file >$fprefix.mc2_summary_only.txt
#delete formating
sed 's/\t\t/\t/' $fprefix.mc1_summary_only.txt >$tmp1_file
sed 's/\t\t/\t/' $fprefix.mc2_summary_only.txt >$tmp2_file
rm $fprefix.mc1_summary_only.txt
rm $fprefix.mc2_summary_only.txt

#gcc
SVN_GCC_XPASS=`grep "# of expected passes" $tmp1_file | sed 's/# of expected passes\t//'`
SVN_GCC_UFAIL=`grep "# of unexpected failures" $tmp1_file | sed 's/# of unexpected failures\t//'`
SVN_GCC_XFAIL=`grep "# of expected failures" $tmp1_file | sed 's/# of expected failures\t//'`
SVN_GCC_UNSUPPORTED=`grep "# of unsupported tests" $tmp1_file | sed 's/# of unsupported tests\t//'`
SVN_GCC_UNRESOLVED=`grep "# of unresolved testcases" $tmp1_file | sed 's/# of unresolved testcases\t//'`
SVN_GCC_UPASS=`grep "# of unexpected successes" $tmp1_file | sed 's/# of unexpected successes\t//'`

#fill empty results with zeros
if [ -z $SVN_GCC_XPASS ]; then
    SVN_GCC_XPASS=0
fi
if [ -z $SVN_GCC_UFAIL ]; then
    SVN_GCC_UFAIL=0
fi
if [ -z $SVN_GCC_XFAIL ]; then
    SVN_GCC_XFAIL=0
fi
if [ -z $SVN_GCC_UNSUPPORTED ]; then
    SVN_GCC_UNSUPPORTED=0
fi
if [ -z $SVN_GCC_UNRESOLVED ]; then
    SVN_GCC_UNRESOLVED=0
fi
if [ -z $SVN_GCC_UPASS ]; then
    SVN_GCC_UPASS=0
fi

#g++
SVN_GPP_XPASS=`grep "# of expected passes" $tmp2_file | sed 's/# of expected passes\t//'`
SVN_GPP_UFAIL=`grep "# of unexpected failures" $tmp2_file | sed 's/# of unexpected failures\t//'`
SVN_GPP_XFAIL=`grep "# of expected failures" $tmp2_file | sed 's/# of expected failures\t//'`
SVN_GPP_UNSUPPORTED=`grep "# of unsupported tests" $tmp2_file | sed 's/# of unsupported tests\t//'`
SVN_GPP_UNRESOLVED=`grep "# of unresolved testcases" $tmp2_file | sed 's/# of unresolved testcases\t//'`
SVN_GPP_UPASS=`grep "# of unexpected successes" $tmp2_file | sed 's/# of unexpected successes\t//'`

#fill empty results with zeros
if [ -z $SVN_GPP_XPASS ]; then
    SVN_GPP_XPASS=0
fi
if [ -z $SVN_GPP_UFAIL ]; then
    SVN_GPP_UFAIL=0
fi
if [ -z $SVN_GPP_XFAIL ]; then
    SVN_GPP_XFAIL=0
fi
if [ -z $SVN_GPP_UNSUPPORTED ]; then
    SVN_GPP_UNSUPPORTED=0
fi
if [ -z $SVN_GPP_UNRESOLVED ]; then
    SVN_GPP_UNRESOLVED=0
fi
if [ -z $SVN_GPP_UPASS ]; then
    SVN_GPP_UPASS=0
fi

rm $tmp1_file
rm $tmp2_file

#CHECK REGRESSIONS
regression_detected=0
progression_detected=0
missed_detected=0
rm $out_log 1>/dev/null 2>/dev/null
touch $out_log
rm $temp_log 1>/dev/null 2>/dev/null
touch $temp_log

if [ -f $out_file_dir_gcc/gcc.log ] && [ -f  $svn_result_dir/gcc.log ]; then
    ./scan_regressions.sh $out_file_dir_gcc/gcc.log $svn_result_dir/gcc.log "FAIL:" $temp_log
    ./scan_regressions.sh $out_file_dir_gcc/gcc.log $svn_result_dir/gcc.log "UNRESOLVED:" $temp_log
    ./scan_regressions.sh $out_file_dir_gcc/gcc.log $svn_result_dir/gcc.log "XPASS:" $temp_log
fi

#write gcc regressions bellow right header if any
if [ $(stat -c%s "$temp_log") != 0 ]; then
    regression_detected=1
cat >$out_log <<EOF
    Regressions on $cur_date
    === gcc regressions: ===
EOF
    cat $temp_log >>$out_log
    rm $temp_log 1>/dev/null 2>/dev/null
    touch $temp_log
fi

if [ -f $out_file_dir_gcc/gcc.log ] && [ -f  $svn_result_dir/gcc.log ]; then
    ./scan_regressions.sh $out_file_dir_gcc/gcc.log $svn_result_dir/gcc.log "PASS:" $temp_log
    ./scan_regressions.sh $out_file_dir_gcc/gcc.log $svn_result_dir/gcc.log "XFAIL:" $temp_log
    ./scan_regressions.sh $out_file_dir_gcc/gcc.log $svn_result_dir/gcc.log "UNSUPPORTED:" $temp_log
fi

#write gcc progressions below right header if any
if [ $(stat -c%s "$temp_log") != 0 ]; then
    if [[ $regression_detected == 0 ]]; then
cat >>$out_log <<EOF
    Regressions on $cur_date
    === gcc progressions: ===
EOF
    else
cat >>$out_log <<EOF
    === gcc progressions: ===
EOF
    fi
    progression_detected=1
    cat $temp_log >>$out_log
    rm $temp_log 1>/dev/null 2>/dev/null
    touch $temp_log
fi

if [ -f $out_file_dir_gpp/g++.log ] && [ -f  $svn_result_dir/g++.log ]; then
    ./scan_regressions.sh $out_file_dir_gpp/g++.log $svn_result_dir/g++.log "FAIL:" $temp_log
    ./scan_regressions.sh $out_file_dir_gpp/g++.log $svn_result_dir/g++.log "UNRESOLVED:" $temp_log
    ./scan_regressions.sh $out_file_dir_gpp/g++.log $svn_result_dir/g++.log "XPASS:" $temp_log
else
    echo "WARNING: scan_regressions.sh WAS NOT CALLED for g++.log"
    echo "grep can issue No such file... errors below"
fi

#write g++ progressions bellow right header if any
if [ $(stat -c%s "$temp_log") != 0 ]; then
    if [[ $regression_detected == 0 ]] && [[ $progression_detected == 0 ]]; then
cat >>$out_log <<EOF
    Regressions on $cur_date
    === g++ regressions: ===
EOF
    else
cat >>$out_log <<EOF
    === g++ regressions: ===
EOF
    fi
    regression_detected=1
    cat $temp_log >>$out_log
    rm $temp_log 1>/dev/null 2>/dev/null
    touch $temp_log
fi

if [ -f $out_file_dir_gpp/g++.log ] && [ -f  $svn_result_dir/g++.log ]; then
    ./scan_regressions.sh $out_file_dir_gpp/g++.log $svn_result_dir/g++.log "PASS:" $temp_log
    ./scan_regressions.sh $out_file_dir_gpp/g++.log $svn_result_dir/g++.log "XFAIL:" $temp_log
    ./scan_regressions.sh $out_file_dir_gpp/g++.log $svn_result_dir/g++.log "UNSUPPORTED:" $temp_log
fi

#write g++ progressions bellow right header if any
if [ $(stat -c%s "$temp_log") != 0 ]; then
    if [[ $regression_detected == 0 ]]; then
cat >>$out_log <<EOF
    Regressions on $cur_date
    === g++ progressions: ===
EOF
    else
cat >>$out_log <<EOF
    === g++ progressions: ===
EOF
    fi
    progression_detected=1
    cat $temp_log >>$out_log
    rm $temp_log $debug 1>/dev/null 2>/dev/null
    touch $temp_log
fi

#check_missed tests
grep "FAIL: " $svn_result_dir/g++.log >$fprefix.g++.svn
grep "PASS: " $svn_result_dir/g++.log >>$fprefix.g++.svn
grep "UNRESOLVED: "  $svn_result_dir/g++.log >>$fprefix.g++.svn
grep "UNSUPPORTED: " $svn_result_dir/g++.log >>$fprefix.g++.svn

sed -e 's/.*XFAIL:\s//g' $fprefix.g++.svn | sed -e 's/.*XPASS:\s//g' | sed -e 's/.*FAIL:\s//g' | sed -e 's/.*PASS:\s//g' | sed -e 's/.*UNRESOLVED:\s//g' | sed -e 's/.*UNSUPPORTED:\s//g' | grep -v "should be" | sed -e 's/\([^ gcov:]\) gcov:.*/\1/' | sed -e 's/ gcov://g' >$fprefix.g++.cleaned.svn
rm $fprefix.g++.svn

grep "FAIL: " $svn_result_dir/gcc.log >$fprefix.gcc.svn
grep "PASS: " $svn_result_dir/gcc.log >>$fprefix.gcc.svn
grep "UNRESOLVED: "  $svn_result_dir/gcc.log >>$fprefix.gcc.svn
grep "UNSUPPORTED: " $svn_result_dir/gcc.log  >>$fprefix.gcc.svn

sed -e 's/.*XFAIL:\s//g' $fprefix.gcc.svn | sed -e 's/.*XPASS:\s//g' | sed -e 's/.*FAIL:\s//g' | sed -e 's/.*PASS:\s//g' | sed -e 's/.*UNRESOLVED:\s//g' | sed -e 's/.*UNSUPPORTED:\s//g' | grep -v "should be" | sed -e 's/\([^ gcov:]\) gcov:.*/\1/' | sed -e 's/ gcov://g' >$fprefix.gcc.cleaned.svn
rm $fprefix.gcc.svn

grep "FAIL: " $out_file_dir_gpp/g++.log  >$fprefix.g++.out
grep "PASS: " $out_file_dir_gpp/g++.log >>$fprefix.g++.out
grep "UNRESOLVED: "  $out_file_dir_gpp/g++.log >>$fprefix.g++.out
grep "UNSUPPORTED: " $out_file_dir_gpp/g++.log >>$fprefix.g++.out

sed -e 's/.*XFAIL:\s//g' $fprefix.g++.out | sed -e 's/.*XPASS:\s//g' | sed -e 's/.*FAIL:\s//g' | sed -e 's/.*PASS:\s//g' | sed -e 's/.*UNRESOLVED:\s//g' | sed -e 's/.*UNSUPPORTED:\s//g' | grep -v "should be" | sed -e 's/\([^ gcov:]\) gcov:.*/\1/' | sed -e 's/ gcov://g' >$fprefix.g++.cleaned.out
rm $fprefix.g++.out

grep "FAIL: " $out_file_dir_gcc/gcc.log >$fprefix.gcc.out
grep "PASS: " $out_file_dir_gcc/gcc.log >>$fprefix.gcc.out
grep "UNRESOLVED: "  $out_file_dir_gcc/gcc.log >>$fprefix.gcc.out
grep "UNSUPPORTED: " $out_file_dir_gcc/gcc.log >>$fprefix.gcc.out

sed -e 's/.*XFAIL:\s//g' $fprefix.gcc.out | sed -e 's/.*XPASS:\s//g' | sed -e 's/.*FAIL:\s//g' | sed -e 's/.*PASS:\s//g' | sed -e 's/.*UNRESOLVED:\s//g' | sed -e 's/.*UNSUPPORTED:\s//g' | grep -v "should be" | sed -e 's/\([^ gcov:]\) gcov:.*/\1/' | sed -e 's/ gcov://g' >$fprefix.gcc.cleaned.out
rm $fprefix.gcc.out

sort -o $fprefix.gcc.cleaned.svn $fprefix.gcc.cleaned.svn
sort -o $fprefix.gcc.cleaned.out $fprefix.gcc.cleaned.out
sort -o $fprefix.g++.cleaned.svn $fprefix.g++.cleaned.svn
sort -o $fprefix.g++.cleaned.out $fprefix.g++.cleaned.out

comm -23 $fprefix.gcc.cleaned.svn $fprefix.gcc.cleaned.out >$temp_log

if [ $(stat -c%s "$temp_log") != 0 ]; then
    if [[ $regression_detected == 0 ]] && [[ $progression_detected == 0 ]]; then
cat >>$out_log <<EOF
    Regressions on $cur_date
    === gcc missed tests: ===
EOF
    else
cat >>$out_log <<EOF
    === gcc missed tests: ===
EOF
    fi
    missed_detected=1
    cat $temp_log >>$out_log
    rm $temp_log $debug 1>/dev/null 2>/dev/null
    touch $temp_log
fi

rm $fprefix.gcc.cleaned.svn
rm $fprefix.gcc.cleaned.out

comm -23 $fprefix.g++.cleaned.svn $fprefix.g++.cleaned.out >$temp_log

if [ $(stat -c%s "$temp_log") != 0 ]; then
    if [[ $regression_detected == 0 ]] && [[ $progression_detected == 0 ]] && [[ $missed_detected == 0 ]]; then
cat >>$out_log <<EOF
    Regressions on $cur_date
    === g++ missed tests: ===
EOF
    else
cat >>$out_log <<EOF
    === g++ missed tests: ===
EOF
    fi
    missed_detected=1
    cat $temp_log >>$out_log
    rm $temp_log $debug 1>/dev/null 2>/dev/null
    touch $temp_log
fi

rm $fprefix.g++.cleaned.svn
rm $fprefix.g++.cleaned.out

#GENERATE SUMMARY

let "TOTAL_XPASS=GCC_XPASS+GPP_XPASS"
let "TOTAL_UFAIL=GCC_UFAIL+GPP_UFAIL"
let "TOTAL_XFAIL=GCC_XFAIL+GPP_XFAIL"
let "TOTAL_UNSUPPORTED=GCC_UNSUPPORTED+GPP_UNSUPPORTED"
let "TOTAL_UNRESOLVED=GCC_UNRESOLVED+GPP_UNRESOLVED"
let "TOTAL_UPASS=GCC_UPASS+GPP_UPASS"

cat >$path_to_ndk_regressions/$ndk_version/mc_summary_${tested_object}_${bits}_${image_type}_${cur_date}.log <<EOF
$TOTAL_XPASS,$TOTAL_UFAIL,$TOTAL_XFAIL,$TOTAL_UNSUPPORTED,$TOTAL_UNRESOLVED,$TOTAL_UPASS
EOF
#$GCC_XPASS,$GCC_UFAIL,$GCC_XFAIL,$GCC_UNSUPPORTED,$GCC_UNRESOLVED,$GCC_UPASS
#$GPP_XPASS,$GPP_UFAIL,$GPP_XFAIL,$GPP_UNSUPPORTED,$GPP_UNRESOLVED,$GPP_UPASS

rm $tmp1_file $debug 1>/dev/null 2>/dev/null
rm $tmp2_file $debug 1>/dev/null 2>/dev/null
rm $temp_log $debug 1>/dev/null 2>/dev/null
if [ $post_result == 1 ]; then
    $ndebug echo "$y: before creation of $stderr file PWD=$PWD"
    $ndebug ls -la $stderr
    tablename="Summaries"
    columns_list="xpass,ufail,xfail,unsupported,unresolved,upass,type,test_date,ndk_version,bits,tested_object,image_type,act_date,target_bits"
    #commit to database
    sqlite3 $path_to_ndk_regressions/$database "insert into $tablename($columns_list) values ($GCC_XPASS,$GCC_UFAIL,$GCC_XFAIL,$GCC_UNSUPPORTED,$GCC_UNRESOLVED,$GCC_UPASS,'gcc','${cur_date}', '$compiler', $bits, $tested_object, '$image_type',  datetime('now'), $device_target_bits)" 2>$stderr
    grep "Error: " $stderr 1>$grep_stdout
    if [ ! -s $grep_stdout ]; then
        sqlite3 $path_to_ndk_regressions/$database "UPDATE  $tablename SET xpass=$GCC_XPASS, ufail=$GCC_UFAIL, xfail=$GCC_XFAIL, unsupported=$GCC_UNSUPPORTED, unresolved=$GCC_UNRESOLVED, upass=$GCC_UPASS, act_date=datetime('now')  WHERE type='gcc' AND test_date='${cur_date}' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type' AND target_bits=$device_target_bits"
    fi

    sqlite3 $path_to_ndk_regressions/$database "insert into $tablename($columns_list) values ($GPP_XPASS,$GPP_UFAIL,$GPP_XFAIL,$GPP_UNSUPPORTED,$GPP_UNRESOLVED,$GPP_UPASS,'gpp','${cur_date}', '$compiler', $bits, $tested_object, '$image_type',  datetime('now'), $device_target_bits)" 2>$stderr
    grep "Error: " $stderr 1>$grep_stdout
    if [ ! -s $grep_stdout ]; then
        sqlite3 $path_to_ndk_regressions/$database "UPDATE  $tablename SET xpass=$GPP_XPASS, ufail=$GPP_UFAIL, xfail=$GPP_XFAIL, unsupported=$GPP_UNSUPPORTED, unresolved=$GPP_UNRESOLVED, upass=$GPP_UPASS, act_date=datetime('now')  WHERE type='gpp' AND test_date='${cur_date}' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type' AND target_bits=$device_target_bits"
    fi

    sqlite3 $path_to_ndk_regressions/$database "insert into $tablename($columns_list) values ($TOTAL_XPASS,$TOTAL_UFAIL,$TOTAL_XFAIL,$TOTAL_UNSUPPORTED,$TOTAL_UNRESOLVED,$TOTAL_UPASS,'total','${cur_date}', '$compiler', $bits, $tested_object, '$image_type',  datetime('now'), $device_target_bits)"  2>$stderr
    grep "Error: " $stderr  1>$grep_stdout
    if [ ! -s $grep_stdout ]; then
        sqlite3 $path_to_ndk_regressions/$database "UPDATE  $tablename SET xpass=$TOTAL_XPASS, ufail=$TOTAL_UFAIL, xfail=$TOTAL_XFAIL, unsupported=$TOTAL_UNSUPPORTED, unresolved=$TOTAL_UNRESOLVED, upass=$TOTAL_UPASS, act_date=datetime('now')  WHERE type='total' AND test_date='${cur_date}' AND ndk_version='$compiler' AND bits=$bits AND tested_object=$tested_object AND image_type='$image_type' AND target_bits=$device_target_bits"
    fi
    rm $stderr $debug 1>/dev/null 2>/dev/null
    rm $stdout $debug 1>/dev/null 2>/dev/null
    rm $grep_stdout $debug 1>/dev/null 2>/dev/null
fi

if [ $regression_detected == 1 ]; then
    exit -1
else
    exit 0
fi
