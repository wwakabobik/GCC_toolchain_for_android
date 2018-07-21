#!/bin/bash

hostname=`hostname`
hosts=(msticlxl100 msticlxl101 msticlxl102)

#host check
rc=0
for arg in ${hosts[*]}
do
    if [ "$hostname" == $arg ]; then
        let rc=rc+1
        break
    fi
done
if [ $rc == 0 ]; then
    echo "your host $hostname is not listed in supportable list"
    exit -1
fi

bits_to_test=(32 64)
compilers=(443 462 472 480 490)
devices=(Linux Medfield CloverTrail Merrifield GalaxyNexus Nexus4 HarrisBeach)

comm_root=$PWD
rootme=$(cd $(dirname $0) && pwd)

#install local infrastructure
daily_folder=MC_Daily
log_folder=logs

mkdir -p /users/$USER/$daily_folder
mkdir -p /users/$USER/$daily_folder/$log_folder
for arg in ${devices[*]}
do
    mkdir -p /users/$USER/$daily_folder/$log_folder/$arg
done
svn co file:///nfs/ims/proj/icl/gcc_cw/share/Make_Check_Adb_Results /users/$USER/$daily_folder/Make_Check_Adb_Results 1>/dev/null
if [ $? != 0 ]; then
    echo "svn repo sync failed, aborted"
    exit -1
fi
cp -r /users/$USER/$daily_folder/Make_Check_Adb_Results/Scripts/Make_Check_Adb/* /users/$USER/$daily_folder/
cp $rootme/activate_debug.sh.exec /users/$USER/$daily_folder/activate_debug.sh.exec
mkdir -p /users/$USER/$daily_folder/DejaGnu
cp -R ../DejaGnu/* /users/$USER/$daily_folder/DejaGnu/
cd /users/$USER/$daily_folder/DejaGnu
./install_dejagnu.sh $PWD 1>/dev/null
if [ $? != 0 ]; then
   echo "dejagnu installation failed, aborted"
   exit -1
fi
cd /users/$USER/$daily_folder
./activate_debug.sh.exec 1>/dev/null
chmod -R ug+rw /users/$USER/$daily_folder
cd $comm_root

#install share infrastructure
share=/nfs/ims/proj/icl/gcc_cw/share
Regressions_dir=NDK_Regressions
for arg in ${devices[*]}
do
    for arg2 in ${compilers[*]}
    do
        mkdir -p $share/$Regressions_dir/ndk${arg2}_${arg}
        chmod -R ug+rw $share/$Regressions_dir/ndk${arg2}_${arg}
    done
    if [ ! -f $share/$Regressions_dir/ndk_regressions_${arg}.db ]; then
        touch $share/$Regressions_dir/ndk_regressions_${arg}.db
        sqlite3 $share/$Regressions_dir/ndk_regressions_${arg}.db "CREATE TABLE BadTests(testname text, ndk_version text, bits int default 0, tested_object int default 0, image_type text,  status text, activefail int default 0, timesoccured int, dt datetime default current_timestamp, laststatuschanged datetime, PRIMARY KEY (testname,ndk_version,bits,tested_object,image_type));"
        sqlite3 $share/$Regressions_dir/ndk_regressions_${arg}.db "CREATE TABLE Summaries(xpass int default 0,ufail int default 0,xfail int default 0,unsupported int default 0,unresolved int default 0,upass int default 0,type text,test_date text, ndk_version text, bits int default 0, tested_object int default 0, image_type text, act_date datetime default current_timestamp, revision int default 0,PRIMARY KEY (type,test_date,ndk_version,bits,tested_object,image_type));"
        sqlite3 $share/$Regressions_dir/ndk_regressions_${arg}.db "CREATE TABLE ndk_timing(ndk_version text, bits int default 0, tested_object int default 0, image_type text, date_of_run text,gcc_start text,gcc_end text,gpp_start text, gpp_end text, gcc_time text, gpp_time text, total_time text, act_date datetime default current_timestamp, revision int default 0,PRIMARY KEY (ndk_version,date_of_run,bits,tested_object,image_type));"
        chmod ug+rw $share/$Regressions_dir/ndk_regressions_${arg}.db
    fi
done

#install main scripts
if [ ! -f $share/$Regressions_dir/date_diff.sh ]; then
    cp $rootme/date_diff.sh  $share/$Regressions_dir/
    chmod ug+rwx $share/$Regressions_dir/date_diff.sh
fi
if [ ! -f $share/$Regressions_dir/MC_Monitor.sh ]; then
    cp $rootme/MC_Monitor.sh $share/$Regressions_dir/
    chmod ug+rwx $share/$Regressions_dir/MC_Monitor.sh
fi
if [ ! -f $share/$Regressions_dir/make_check_integral.sh ]; then
    cp $rootme/make_check_integral.sh $share/daily_testing
    chmod ug+rwx $share/$Regressions_dir/make_check_integral.sh
fi

#install cron
#be careful with cron, check if you really need them
#let rc=rc-1
#crontab -l | { cat; echo "15      */2     *       *       *        $share/$Regressions_dir/MC_Monitor.sh >$share/$Regressions_dir/MC_Monitor.html 2>/dev/null"; } | crontab -
#for bits in ${bits_to_test[*]}
#    for arg in ${devices[*]}
#    do
#        count=${#hosts[@]}
#        let time_shift=60/count
#        let time_shift=time_shift*rc
#        if [ "$arg" != "Linux" ]; then
#            crontab -l | { cat; echo "$time_shift      $ctime     *       *       *        $share/daily_testing/make_check_integral.sh $arg $bits 1>>/users/$USER/$daily_folder/$log_folder/${arg}/MC_integral_${arg}_${bits}.log 2>&1"; } | crontab -
#        fi
#        let ctime=ctime+1
#    done
#done
