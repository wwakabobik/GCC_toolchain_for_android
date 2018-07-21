#!/bin/bash

#
# IF YOU CHANGE THIS FILE PLEASE SAVE THE OLD VERSION AS monitor.sh_old
#

#-------------------------------------------------------------------------------
# Name:    monitor.sh
# Purpose: adb device status monitor, run in schedule child tasks and provides
#          info about current workload, for further info refer to help: -h
#          provides info from adb status monitor.
#
# Author:      Ilya Vereshchagin
#
# Created:     31.01.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

#
# path:
#	/nfs/ims/proj/icl/gcc_cw/share/monitor/
#

JOB_ROOT="/nfs/ims/proj/icl/gcc_cw/share/monitor/job"
MONITOR_ROOT="/nfs/ims/proj/icl/gcc_cw/share/monitor"

usage() {
cat << EOF
usage: $0 options

OPTIONS:
   -j "<job>"           - Your script with commands
   -l                   - Cat log
   -s <serial number>   - Serial number for adb device
   -t <minutes>         - 1, 2, ... - timeout before start job
                          0 - wait until all other jobs are finished
   -m                   - Monopoly usage.
   -m -t 0              - If some jobs already is run wait until they will be finished.
   -m -t <minutes>      - If some jobs already is run wait until they will be finished for
                          N minutes. Then stop your job if other jobs have not been finished yet.
   <none>               - Listen mode
EOF
}

delete_job() { 
  if [ -f $JOB_DIR/$JOB_NAME ] ; then
    END_DATE=`date +%d\ %h\ %Y\,\ %T`
    cd $JOB_DIR
#    mv $JOB_NAME $MONITOR_ROOT/done/$JOB_NAME
    rm -rf $JOB_NAME
  fi
}

trap_job() {
  echo
  if [ -f $JOB_DIR/$JOB_NAME ] ; then
    delete_job
    echo "$JOB_NAME $END_DATE: Job is trapped" >> $MONITOR_ROOT/monitor.log
    echo Job $JOB_NAME is trapped
  fi
  exit 0
}
trap "trap_job" 1 2 9 15

get_status() {
  res=`ls $JOB_DIR/* >/dev/null 2>/dev/null && echo $?`;
  JOBS=`echo $JOB_DIR/* | sed "s/\/nfs\/ims\/proj\/icl\/gcc\_cw\/share\/monitor\/job\/${ADB_DEVICE}\/*//g"`
  check_mono=`grep Monopoly $JOB_DIR/* >/dev/null 2>/dev/null && echo $?`;
}

echo Adb path: `which adb`

ADB_DEVICE=
TIMEOUT=1
JOB=
MONOPOLY=0
while getopts “hlmj:s:t:” OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    j)
      JOB=$OPTARG
      ;;
    l)
      tail -20 $MONITOR_ROOT/monitor.log
      exit 0
      ;;
    m)
      MONOPOLY=1
      echo "Device will be used in monopoly mode"
      ;;
    s)
      ADB_DEVICE=$OPTARG
      ;;
    t)
      TIMEOUT=$OPTARG
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [[ -z $ADB_DEVICE ]] ; then
  ADB_DEVICE="MedfieldE906493B"
  #ADB_DEVICE="MedfieldB12636D7"
fi

# check adb status
adb -s $ADB_DEVICE shell exit >/dev/null 2>/dev/null
status=`echo $?`
if [[ status -ne 0 ]] ; then
  echo $USER
  echo Device $ADB_DEVICE not available
  exit 1
fi

if ! [[ $TIMEOUT =~ ^[0-9]+$ ]] ; then
  usage
  exit 1

# listen-mode
elif [[ -z $JOB ]] ; then
  JOB_DIR=$JOB_ROOT/$ADB_DEVICE
  get_status
  while [[ $res == "0" ]] ; do
    echo "Now are running: $JOBS"
    sleep 60
    get_status
  done

  echo "Device is free!"

# run-mode
else
  JOB_DIR=$JOB_ROOT/$ADB_DEVICE
  if ! [ -d $JOB_DIR ] ; then
    mkdir -p $JOB_DIR
    chown $USER $JOB_DIR
    chmod 775 $JOB_DIR
  fi
  get_status
  
  while [[ $res == "0" ]] && [[ $TIMEOUT -ne 1 ]]; do
    if [[ $check_mono == "0" ]] ; then
      echo "Device is used by $JOBS in monopoly mode."
    else
      echo "Now are running: $JOBS"
    fi
    sleep 60
    ((TIMEOUT--))
    get_status
  done

  if [[ $res == "0" ]] ; then
    echo "Device is busy. Now are running:"
    echo $JOBS
    read -t 60 -p " Do you want to continue? [Y/n]: " answer
    if ( [[ $answer != 'y' ]] && [[ $answer != "" ]] && [[ $answer != 'Y' ]] || [[ $check_mono == "0" ]] || [[ $MONOPOLY -eq 1 ]] ) ; then
      exit 0
    fi 
  fi

  DATE=`date +%d\ %h\ %Y\,\ %T`
  JOB_NAME="`echo $JOB | sed 's/\ .*//' | sed 's/.*\///'`""#""`date +%d%h%Y_%H%M%S`""#"$USER
  touch $JOB_DIR/$JOB_NAME
  chown $USER $JOB_DIR/$JOB_NAME
  chmod 664 $JOB_DIR/$JOB_NAME
  echo "           $JOB" > $JOB_DIR/$JOB_NAME
  if [[ $MONOPOLY -eq 1 ]] ; then
    echo "Monopoly" >> $JOB_DIR/$JOB_NAME
  fi
  echo "$JOB_NAME $DATE: Job is started" >> $MONITOR_ROOT/monitor.log
  echo " $JOB" >> $MONITOR_ROOT/monitor.log

  # run job
  echo "Run $JOB"
  $JOB
  res=`echo $?`;

  delete_job
  echo "$JOB_NAME $END_DATE: Job is finished with status $res" >> $MONITOR_ROOT/monitor.log
  echo Job $JOB_NAME is finished with status $res
  exit $res
fi

