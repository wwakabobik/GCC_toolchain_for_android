#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    daily_mc_ndk.sh
# Purpose: daily NDK compiler make check testing using adb method
#
# Author:      Iliya Vereshchagin
#
# Created:     20.09.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------

y=`basename $0`
$ndebug echo "$y started with parameters:"
$ndebug echo "   $1"
$ndebug echo "   $2"
$ndebug echo "   $3  $4  $5  $6  $7  $8  $9"
$ndebug echo "   ${10}   ${11}   ${12}    ${13}"

if [ -z $1 ]; then
    echo " no current directory specified, use pwd=$PWD"
    rootme=$PWD
else
    rootme=$1
fi

if [ -z $2 ]; then
    adb_device="MedfieldE906493B"
    echo " no device specified, use default = $adb_device"
else
    adb_device="$2"
fi

if [ -z $3 ]; then
    compiler="4.7.2"
    echo " no ndk version specified, use $compiler"
else
    compiler=$3
fi

if [ -z $4 ]; then
    update_dejagnu=0
else
    if [ $4 != 1 ]; then
        $ndebug echo "Local copy of DejaGnu will not be updated"
        update_dejagnu=0
    else
        update_dejagnu=$4
    fi
fi

if [ -z $5 ]; then
    post_results=0
else
    post_results=$5
fi

if [ -z $6 ]; then
    test_arch="x86"
else
    test_arch=$6
fi

if [ -z $7 ]; then
    rooted=1
else
    rooted=$7
fi

if [ -z $8 ]; then
    device_alias="Medfield"
else
    device_alias=$8
fi

if [ -z $9 ]; then
    device_android_platform=9
else
    device_android_platform=$9
fi

if [ -z $device_target_bits ]; then
    device_target_bits=32
fi

bits=${10}
tested_object=${11}
image_type=${12}
trunk_version=${13}

NDK_subf0=""
if [ $compiler == "trunk" ]; then
    compiler_repo="file:///gnumnt/msticlel02_gnu_server/svn/replica/gcc"
    #NDK_subf0="NDK_current_$compiler"
    NDK_subf0="NDK_current"
    recent_gcc_under_test=$compiler
    compiler=$trunk_version    #   "4.9.0"
    #  when trunk will become > 4.9.0 then don't forget to do:  rm -rf gcc_4_9_0_release of gcc (including tests themselves) locally being stored
else
    compiler_repo="file:///gnumnt/msticlel02_gnu_server/svn/replica/gcc/tags"
    NDK_subf0="NDK_current"
    compiler_folder=`echo $compiler | sed -r 's/[.]/_/g'`
    recent_gcc_under_test="gcc_"$compiler_folder"_release"
fi

NDK_subf=""
if [ $bits -eq 64 ]; then
    NDK_subf="${NDK_subf0}_$bits"
else
    NDK_subf=$NDK_subf0
fi
$ndebug echo "NDK_subf=$NDK_subf"

database="ndk_regressions_$device_alias.db"

#check-up of proper environment
# ndk_alias can be defined via export equaled to some subfolder of .../share/, for one, NDK_Special,
# in $rootme where some different NDK is for usage
if [ -z $ndk_alias ]; then
    ndk_alias=$NDK_subf
    $rootme/check_prequisites.sh $rootme $device_alias /nfs/ims/proj/icl/gcc_cw/share/$NDK_subf
else
    # ndk_alias is set via export
    update_ndk=0
    archive=$ndk_alias
    $rootme/check_prequisites.sh $rootme $device_alias $ndk_alias
fi
if [ $? != 0 ]; then
    echo "Some critical files of directories missed, aborted"
    exit -1
fi

prefix_dir=MC

#we should not use the same device at the same time for make check
monopoly_dir="$rootme/$prefix_dir/MONOPOLY"
if [[ -d "$monopoly_dir" && "$(ls -A $monopoly_dir)" ]]; then
# folder exists and is not empty
    if [ -f $monopoly_dir/$adb_device ]; then
        echo "$monopoly_dir/$adb_device file EXISTS, that is, $adb_device is busy, aborted"
        exit -1
    else
        touch $monopoly_dir/$adb_device
    fi
else
    mkdir -p $monopoly_dir 1>/dev/null 2>/dev/null
    touch $monopoly_dir/$adb_device
fi

ndk_dir=$rootme/$ndk_alias
$ndebug echo "ndk_dir=$ndk_dir"

#check against changes, update NDK only when versions mismatch
if [ -z $update_ndk ]; then
    if [ -f $ndk_dir/RELEASE.TXT ]; then
        content=`cat $ndk_dir/RELEASE.TXT | sed 's/ (64-bit)//g'`
        $ndebug echo "Date of Local NDK is $content"
        $ndebug echo "ls /nfs/ims/proj/icl/gcc_cw/share/$NDK_subf/*$content*.tar.bz2 1>/dev/null 2>/dev/null"
        ls /nfs/ims/proj/icl/gcc_cw/share/$NDK_subf/*$content*.tar.bz2 $debug 1>/dev/null 2>/dev/null
        if [ $? == 0 ]; then
            $ndebug echo "Local NDK is up-to-date, NO UPDATE NEEDED"
            archive=`ls /nfs/ims/proj/icl/gcc_cw/share/$NDK_subf/*$content*.tar.bz2`
            update_ndk=0
        else
            update_ndk=1
            $ndebug echo "Local NDK is not up-to-date, UPDATE NEEDED"
        fi
    else
        $ndebug echo "$ndk_dir/RELEASE.TXT IS ABSENT: we will update Local NDK"
        update_ndk=1
    fi
fi

cd $rootme
if [ "$update_ndk" = "1" ]; then
    if [[ -d "$monopoly_dir" && "$(ls -A $monopoly_dir)" ]]; then
    # folder exists and is not empty
    if [ -f $monopoly_dir/$NDK_subf ]; then
        echo "$monopoly_dir/$NDK_subf file EXISTS, that is, $NDK_subf subfolder is busy, aborted"
        we_touched_lock_on_NDK_subf=1
        rm $monopoly_dir/$adb_device
        exit -1
    else
        we_touched_lock_on_NDK_subf=0
        touch $monopoly_dir/$NDK_subf
    fi
fi

    archive=`ls /nfs/ims/proj/icl/gcc_cw/share/$NDK_subf/*.tar.bz2`

    echo "Obtaining of the most recent version of NDK from $archive"
    tar xvjf $archive -C $rootme 1>/dev/null 2>/dev/null
    x=`echo "$archive" |  sed -e 's/.*android//g' | sed -e 's/-linux-x86.*.tar.bz2//g'`
    x1="./android"
    RecentNDK=$x1$x

    $ndebug echo "RecentNDK=$RecentNDK"
    if [ -d $ndk_dir ]; then
        $ndebug echo "  erase old ndk version with 'rm -rf $ndk_dir'"
        rm -rf $ndk_dir 1>/dev/null 2>/dev/null
        rmdir $ndk_dir 1>/dev/null 2>/dev/null
    fi

    mv $RecentNDK $ndk_dir #should pass!
    if [ "$?" = "0" ]; then
        $ndebug echo "Recent NDK $archive will be used for test"
        rm -rf $RecentNDK
        chmod -R ug+rw $ndk_dir
    else
        echo "mv $RecentNDK $ndk_dir FAILED."
        rm -rf $RecentNDK
        rm $monopoly_dir/$adb_device
        exit -1
    fi

else
    echo "Local NDK will not be updated"
    if [ -f $monopoly_dir/$NDK_subf ]; then
        echo "$monopoly_dir/$NDK_subf file EXISTS, that is, $NDK_subf subfolder is being used by another process. We will use it as well!"
        we_touched_lock_on_NDK_subf=1
        # the other process can delete this lock file before our completion... sure...  (It's not very good...)
        # we continue our executioecentNDK $ndk_dir #should pass!
    else
        we_touched_lock_on_NDK_subf=0
        touch $monopoly_dir/$NDK_subf
    fi
fi

if [ ! -d $ndk_dir ]; then
    echo "$ndk_dir is not exists, aborted"
    rm $monopoly_dir/$adb_device
    rm $monopoly_dir/$NDK_subf
    exit -1
fi

#make them rewritable to any person
chmod ug+rw -R $ndk_dir/*
chmod ug+rw $ndk_dir

#setup infrastructure

results_repo="file:///nfs/ims/proj/icl/gcc_cw/share/Make_Check_Adb_Results"
regressions_dir="/nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions"

compiler_for_db=`echo $compiler | sed -r 's/[.]//g'`
compiler_for_db="ndk"$compiler_for_db"_$device_alias"

if [ "$compiler" != "4.4.3" ]; then
   compiler_for_script=`echo $compiler | sed -r 's/[.]/_/' | sed 's/\([^\.]\)\..*/\1/' |  sed -r 's/[_]/./'`
else
   compiler_for_script=$compiler
fi

cur_date=`date +%d`
cur_date=$cur_date/`date +%m`
cur_date=$cur_date/`date +%Y`
cur_date_for_write=`date +%Y`_`date +%m`_`date +%d`
cur_date_for_post=`date +%Y`/`date +%m`/`date +%d`

dejagnu_dir="$rootme/DejaGnu"
specific_device=$test_arch/$device_alias
out_dir=$rootme/$prefix_dir/$specific_device
svn_dir=$rootme/Make_Check_Adb_Results
gcc_ver=$out_dir/$compiler
run_dir=$prefix_dir/$specific_device/$compiler

#force output folder if something missed, this is not so important now
mkdir -p $out_dir $debug 1>/dev/null 2>/dev/null
mkdir -p $gcc_ver $debug 1>/dev/null 2>/dev/null

echo "Synchronizing results repo..."
revisn=0
revisn=`sqlite3 $regressions_dir/$database "select revision from ndk_timing  where   tested_object=$tested_object  AND ndk_version='$compiler' AND bits=$bits AND image_type='$image_type'  ORDER BY date_of_run DESC LIMIT 1"`
$ndebug echo "$y: sqlite3 $regressions_dir/$database \"select revision from ndk_timing  where   tested_object=$tested_object  AND ndk_version='$compiler' AND bits=$bits AND image_type='$image_type'  ORDER BY date_of_run DESC LIMIT 1\""
$ndebug echo "$y:  revisn=$revisn (the revision number of svn commit for the previous make check with parameters specified above in the where conditon of the select)"

if [ ! -d $svn_dir ]; then
    echo " no previous versions were found, checking out new one..."
    svn checkout $results_repo $debug 1>/dev/null 2>/dev/null
fi

if [ -d $svn_dir ]; then
    cd $svn_dir
    #reset locks
    svn cleanup $debug 1>/dev/null 2>/dev/null

    if [ $compiler = "trunk"  ]; then
       ndk_v=$trunk_version
    else
       ndk_v=$compiler
    fi

    cd $specific_device/Android_${ndk_v}_Patched
    if [ "$?" = "0" ]; then
        if [ "$revisn" = "0" ]; then
            svn update $debug 1>/dev/null 2>/dev/null
        else
            if [ "$revisn" = ""  ]; then
                touch ./gcc.log $debug 1>/dev/null 2>/dev/null
                touch ./g++.log $debug 1>/dev/null 2>/dev/null
            else
                svn update -r $revisn $debug 1>/dev/null 2>/dev/null
            fi
        fi
        cd $rootme
    else
        $ndebug echo "  $svn_dir$specific_device/Android_${ndk_v}_Patched folder IS ABSENT"
        rm $monopoly_dir/$adb_device
        if [ "$we_touched_lock_on_NDK_subf" = "0" ]; then
            rm $monopoly_dir/$NDK_subf
        fi
        echo "SVN destination folder is missed, aborted"
        cd $rootme
        exit -1
    fi
else
    echo "SVN repo missed, aborted"
    rm $monopoly_dir/$adb_device
    if [ "$we_touched_lock_on_NDK_subf" = "0" ]; then
        rm $monopoly_dir/$NDK_subf
    fi
    cd $rootme
    exit -1
fi

#update dejagnu, to trigger, set first argument to 1
$rootme/check_dejagnu.sh $update_dejagnu $dejagnu_dir $rootme $svn_dir/DejaGnu
if [ $? != 0 ]; then
    echo " something goes wrong during dejagnu update, aborted"
    rm $monopoly_dir/$adb_device
    if [ "$we_touched_lock_on_NDK_subf" = "0" ]; then
        rm $monopoly_dir/$NDK_subf
    fi
    exit -1
fi

#Start testing

echo "Obtaining of the most recent $recent_gcc_under_test version of GCC"
if [ -d $gcc_ver/$recent_gcc_under_test ]; then
    cd $gcc_ver/$recent_gcc_under_test
    $ndebug echo "                 we go to $gcc_ver/$recent_gcc_under_test"
    $ndebug echo "                 we launched svn cleanup"
    svn cleanup $debug 1>/dev/null 2>/dev/null
    $ndebug echo "                 the svn cleanup is completed with $?"
    $ndebug echo "                 we launched svn update"
    svn update $debug 1>/dev/null 2>/dev/null
    $ndebug echo "                 the svn update is completed with $?"
    cd $rootme
else
    echo "no previous versions were found"
    cd $gcc_ver
    $ndebug echo "               we go to $gcc_ver to launch:"
    $ndebug echo "               svn checkout $compiler_repo/$recent_gcc_under_test"
    svn checkout $compiler_repo/$recent_gcc_under_test $debug 1>/dev/null 2>/dev/null
    $ndebug echo "               the svn checkout is completed with $?"
    cd $gcc_ver/$recent_gcc_under_test
    $ndebug echo "               we go to $gcc_ver/$recent_gcc_under_test to launch:"
    $ndebug echo "               svn update"
    svn update $debug 1>/dev/null 2>/dev/null
    $ndebug echo "               the svn update is completed with $?"
    cd $rootme
fi

#prepare correct patch
exec_folder=$gcc_ver/$recent_gcc_under_test/ANDROID
exec_folder=`echo $exec_folder | sed 's/users/data/'`
adb -s $adb_device shell mkdir -p $exec_folder | grep "mkdir failed"
if [ $? == 0 ]; then
    adb -s $adb_device shell "su -c 'mkdir -p $exec_folder'"
    adb -s $adb_device shell "su -c 'chmod -R 777 $exec_folder'"
else
    adb -s $adb_device shell "chmod -R 777 $exec_folder"
fi
adb -s $adb_device shell ls $exec_folder | grep "No such file or directory"
if [ $? == 0 ]; then
    echo "no exec folder is avaliable, aborted"
    exit -1
fi
adb -s $adb_device shell rm $exec_folder/*.*
adb -s $adb device shell rm -r /mnt/sdcard/logs/*

$rootme/generate_ti_patch.sh $dejagnu_dir $adb_device $test_arch $device_alias $exec_folder

#run testing
$rootme/Make_Check_Android.sh $run_dir/$recent_gcc_under_test $gcc_ver $ndk_alias $adb_device $compiler_for_script $test_arch $device_android_platform $rooted $device_alias $bits
MCA_rc=$?
$ndebug echo "$y: Make_Check_Android.sh returned $MCA_rc"
$ndebug echo "$y: post_results=$post_results"
if [ "$MCA_rc" = "0" ] && [ "$post_results" = "1" ]; then
    #checking regressions and generate csv report
    $rootme/get_excel_summary.sh $gcc_ver/ANDROID_MAKE_CHECK $gcc_ver/ANDROID_MAKE_CHECK $svn_dir/$specific_device/Android_${compiler}_Patched ${cur_date_for_write} $compiler_for_db 1 $database $compiler $bits $tested_object $image_type
    if [[ $? != 0 ]]; then
        # regression detected!
        echo " sending e-mail with list of regressions..."
        # email subject
        SUBJECT="NDK regression on $compiler $device_alias $bits ${cur_date}"
        # Email To ?
        if test -z "$email_receiver"
        then
            EMAIL="ilyax.g.vereschagin@intel.com"
        else
            EMAIL="$email_receiver"
        fi
        # Email text/message
        EMAILMESSAGE="emailmessage.txt"
        rm $EMAILMESSAGE $debug 1>/dev/null 2>/dev/null
        touch $EMAILMESSAGE
        cat $regressions_dir/$compiler_for_db/progressions_and_regressions_${tested_object}_${bits}_${image_type}_${cur_date_for_write}.log >$EMAILMESSAGE
        # send an email using /bin/mail
        /bin/mail -s "$SUBJECT" "$EMAIL" < $EMAILMESSAGE
        rm $EMAILMESSAGE
    fi
    ./check_stable_regression.sh ${cur_date_for_write} $compiler_for_db $database $compiler $bits $tested_object $image_type
    #copy and cleanup
    echo "Copying results to $svn_dir/$specific_device/Android_${compiler}_Patched/"
    svn up $svn_dir/$specific_device/Android_${compiler}_Patched $debug 1>/dev/null 2>/dev/null
    #copy gcc results
    cp -f $gcc_ver/ANDROID_MAKE_CHECK/gcc.log $svn_dir/$specific_device/Android_${compiler}_Patched/gcc.log $debug 1>/dev/null 2>/dev/null
    #copy gpp results
    cp -f $gcc_ver/ANDROID_MAKE_CHECK/g++.log $svn_dir/$specific_device/Android_${compiler}_Patched/g++.log $debug 1>/dev/null 2>/dev/null
    #copy output logs
    cp -f $gcc_ver/ANDROID_MAKE_CHECK/RESULT_err $svn_dir/$specific_device/Android_${compiler}_Patched/RESULT_err $debug 1>/dev/null 2>/dev/null
    cp -f $gcc_ver/ANDROID_MAKE_CHECK/RESULT_output $svn_dir/$specific_device/Android_${compiler}_Patched/RESULT_output $debug 1>/dev/null 2>/dev/null
    cp -f $gcc_ver/ANDROID_MAKE_CHECK/site.exp $svn_dir/$specific_device/Android_${compiler}_Patched/site.exp $debug 1>/dev/null 2>/dev/null

    #update compiler info
    rm -f $svn_dir/$specific_device/Android_${compiler}_Patched/README $debug 1>/dev/null 2>/dev/null
    $ndebug echo "$y: ./get_start_end.exp is launched with parameters:"
    $ndebug echo "   $gcc_ver $test_arch $device_alias $compiler $database $bits $tested_object $image_type $device_target_bits"
    timing_totals=`./get_start_end.exp $gcc_ver $test_arch $device_alias $compiler $database $bits $tested_object $image_type $device_target_bits  `
    cat >$svn_dir/$specific_device/Android_${compiler}_Patched/README <<EOF
Used NDK: $archive
$timing_totals
EOF

else
    if [ "$MCA_rc" != "0" ]; then
        echo "Make_Check_Android.sh failed for $recent_gcc_under_test, aborted"
        rm $monopoly_dir/$adb_device
        if [ "$we_touched_lock_on_NDK_subf" = "0" ]; then
            rm $monopoly_dir/$NDK_subf
        fi
        cd $rootme
        exit -1
    fi
fi

#go back for next one
cd $rootme

$ndebug echo "FOR TOTALS of the make check GO TO the folder:"
$ndebug echo "   $regressions_dir/"

$ndebug echo " - for STATISTICS execute 'sqlite3 $database' and see tables:"
$ndebug echo "     ndk_timing, Summaries and BadTests (use .schema to have seen their columns names and format)"

$ndebug mc_summ_log="$compiler_for_db/mc_summary_${tested_object}_${bits}_${image_type}_${cur_date_for_write}.log"
$ndebug echo " - for the most total SUMMARY see $mc_summ_log"

$ndebug out_log="$compiler_for_db/progressions_and_regressions_${tested_object}_${bits}_${image_type}_${cur_date_for_write}.log"
$ndebug echo " - for PRO(and RE)GRESSIONS, MISSED TESTS see $out_log"

$ndebug stable_log="$compiler_for_db/stable_regression_${tested_object}_${bits}_$image_type.log"
$ndebug echo " - for STABLE BAD TESTS see $stable_log"

cd $svn_dir
cd $specific_device/Android_${compiler}_Patched/
$ndebug echo "$y: we go to $svn_dir/$specific_device/Android_${compiler}_Patched"
$ndebug echo "               svn commit"
svn commit -m "${cur_date}" $debug 1>/dev/null 2>/dev/null
svn_commit_rc=$?
$ndebug echo "               the svn commit is completed with $svn_commit_rc"

$ndebug echo "An attempt to detect the svn revision number in order to write it to ndk-timing table in sqlite3"
readme_f="$svn_dir/$specific_device/Android_${compiler}_Patched/README"

$ndebug echo "readme_f=$readme_f"

if [ "$post_results" = "1" ]; then
    x=`tail -n  3 $readme_f | grep "GCC_START_DATE"`
    $ndebug echo "x=$x"
    y=${x:15}
    substr=" *"
    GCC_START_DATE=${y%%${substr}}
    $ndebug echo "GCC_START_DATE=${GCC_START_DATE}"

    if [ "$svn_commit_rc" -eq "0" ]; then
        rev_com=`svn info $path_to_results_repo | grep "Revision:" | grep -oP "\d+"`
    else
        rev_com=""
    fi
    $ndebug echo "revision=$rev_com compiler=$compiler"

    qq=`sqlite3 $regressions_dir/$database "UPDATE ndk_timing set revision=$rev_com where ndk_version='$compiler' AND bits=$bits AND date_of_run='${GCC_START_DATE}' AND tested_object=$tested_object AND image_type='$image_type'"`

    #commit into traqs
    cd /nfs/ims/proj/icl/gcc_cw/share/submit_mc/
    #add 32/64 bit target switch
    target_bits=32
    $ndebug echo "./create_xml.py $cur_date_for_post ${target_bits} $compiler $device_alias"
    ./create_xml.py $cur_date_for_post ${target_bits} $compiler $device_alias $debug 1>/dev/null 2>/dev/null
    mv report.xml report_${device_alias}_${target_bits}_${compiler}_${cur_date_for_write}.xml $debug 2>/dev/null
    if [ $? != 0 ]; then
        $ndebug echo "report_${device_alias}_${target_bits}_${compiler}_${cur_date_for_write}.xml failed to get right data"
    fi
    $ndebug echo "./submit.sh report_${device_alias}_${target_bits}_${compiler}_${cur_date_for_write}.xml"
    ./submit.sh report_${device_alias}_${target_bits}_${compiler}_${cur_date_for_write}.xml $debug 1>/dev/null 2>/dev/null
    mv report_${device_alias}_${target_bits}_${compiler}_${cur_date_for_write}.xml ./Reports/report_${device_alias}_${target_bits}_${compiler}_${cur_date_for_write}.xml $debug 1>/dev/null 2>/dev/null
    mv report_${device_alias}_${target_bits}_${compiler}_${cur_date_for_write}.zip ./Reports/report_${device_alias}_${target_bits}_${compiler}_${cur_date_for_write}.zip $debug 1>/dev/null 2>/dev/null
fi

cd $rootme

rm $monopoly_dir/$adb_device
if [ "$we_touched_lock_on_NDK_subf" = "0" ]; then
    rm $monopoly_dir/$NDK_subf
fi

if [ $compiler == $trunk_version ] && [ "$MCA_rc" = "0" ]; then
    tablename=$compiler_for_db
    table_name="BadTests"
    Linux_database="ndk_regressions_Linux.db"
    Linux_type="Fedora"
    tn_trail=`echo $compiler_for_db | sed -e 's/ndk.*_//g'`
    Linux_subfolder=`echo $compiler_for_db | sed -e "s/${tn_trail}/Linux/g"`
    LinStabBug_file=$regressions_dir/$Linux_subfolder/stable_bugs_${tested_object}_${bits}_${Linux_type}.log
    $ndebug echo "Linux_subfolder=$Linux_subfolder"
    $ndebug echo "we are in rootme=$rootme"
    cd $run_dir/$recent_gcc_under_test
    $ndebug echo "We are in the folder $PWD"
    patch -p0 -i $rootme/make_check_adb_bridge_united_49.patch $debug 1>/dev/null 2>/dev/null
    $rootme/make_check_linux.sh branch 32 ./
    rc=$?
    patch -p0 -R  -i $rootme/make_check_adb_bridge_united_49.patch $debug 1>/dev/null 2>/dev/null
    cd $rootme
    if [ "$rc" == "0" ]; then
        echo "Linux trunk make check failed, please see related logs"
    fi
    $rootme/get_excel_summary.sh $rootme/$run_dir/$recent_gcc_under_test/work/branch/$bits/build/gcc/testsuite/gcc  $rootme/$run_dir/$recent_gcc_under_test/work/branch/$bits/build/gcc/testsuite/g++ $rootme/Make_Check_Adb_Results/linux/trunk/patched  ${cur_date_for_write} $Linux_subfolder 1 $Linux_database $compiler $bits $tested_object $Linux_type
    cp $run_dir/$recent_gcc_under_test/work/branch/$bits/build/gcc/testsuite/gcc/gcc.log  $svn_dir/linux/trunk/patched/
    cp $run_dir/$recent_gcc_under_test/work/branch/$bits/build/gcc/testsuite/gcc/site.exp $svn_dir/linux/trunk/patched/site.exp.gcc
    cp $run_dir/$recent_gcc_under_test/work/branch/$bits/build/gcc/testsuite/g++/g++.log  $svn_dir/linux/trunk/patched/
    cp $run_dir/$recent_gcc_under_test/work/branch/$bits/build/gcc/testsuite/g++/site.exp $svn_dir/linux/trunk/patched/site.exp.g++
    svn commit $svn_dir/linux/trunk/patched -m "" $debug 1>/dev/null 2>/dev/null
    $rootme/check_stable_regression.sh ${cur_date_for_write} $Linux_subfolder $Linux_database $compiler $bits $tested_object $Linux_type
    comm -13 $LinStabBug_file $regressions_dir/$compiler_for_db/stable_bugs_${tested_object}_${bits}_$image_type.log >$regressions_dir/$compiler_for_db/stable_bugs_${tested_object}_${bits}_${image_type}_Android_unique.log
    $ndebug echo "See Android stable unique bugs in"
    $ndebug echo "     $regressions_dir/$compiler_for_db/stable_bugs_${tested_object}_${bits}_${image_type}_Android_unique.log"
    $ndebug echo "The bugs from the above file are absent in"
    $ndebug echo "     $LinStabBug_file"
    rm -f $LinStabBug_file
    rm -f $regressions_dir/$compiler_for_db/stable_bugs_${tested_object}_${bits}_$image_type.log
    adb -s $adb device shell rm -r /mnt/sdcard/logs/* $debig 1>/dev/null 2>/dev/null
fi

exit $svn_commit_rc
