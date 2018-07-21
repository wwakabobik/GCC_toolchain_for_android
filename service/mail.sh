#!/bin/bash

Today_report=/nfs/ims/proj/icl/gcc_cw/share/monitor/report_today.html
Yesterday_report=/nfs/ims/proj/icl/gcc_cw/share/monitor/report.html
Mail_file=/nfs/ims/proj/icl/gcc_cw/share/monitor/attachment.html
NDK_testing_report=/nfs/ims/proj/icl/gcc_cw/share/monitor/NDK_testing_report.html
MC_Report=/nfs/ims/proj/icl/gcc_cw/share/monitor/MC_Report.html
/nfs/ims/proj/icl/gcc_cw/share/monitor/build_info.sh report.tmp >${Mail_file}
/nfs/ims/proj/icl/gcc_cw/share/monitor/NDK_testing_Monitor.sh >${NDK_testing_report}
/nfs/ims/proj/icl/gcc_cw/share/monitor/MC_Monitor.sh >${MC_Report}

FROM=gnucwtester
TO=ilyax.g.vereschagin@intel.com

cur_date=`date +%Y`/`date +%m`/`date +%d`
cur_date_for_file=`date +%Y`_`date +%m`_`date +%d`
subject="Build status for $cur_date"
Intel_team="classified@intel.com"
CW_team="classified@intel.com"
CC="$Intel_team,$CW_team"

Reciever="$TO,$CC"
Sender="gnucwtester@ecsmtp.ims.intel.com"

#Build info
(echo -e "Subject: ${subject}\nMIME-Version: 1.0\nFrom: ${FROM}\nTo:${TO}\CC:${CC}\nContent-Type: text/html\nContent-Disposition: inline\n\n";cat ${Mail_file}) | sendmail -f  ${Sender} ${Reciever}
cp -L ${Today_report} ${Yesterday_report}
cp -L ${Mail_file} ${Yesterday_report}
mv ${Mail_file} /gnucwmnt/msticlxl102_users/gnucwtester/Backup/Mail/${cur_date_for_file}_Build_Status.log

#Ndk testing info
subject="NDK testing report for $cur_date"
(echo -e "Subject: ${subject}\nMIME-Version: 1.0\nFrom: ${FROM}\nTo:${TO}\CC:${CC}\nContent-Type: text/html\nContent-Disposition: inline\n\n";cat ${NDK_testing_report}) | sendmail -f  ${Sender} ${Reciever}
cp ${NDK_testing_report} /gnucwmnt/msticlxl102_users/gnucwtester/Backup/Mail/${cur_date_for_file}_NDK_Testing_Status.log

#MC testing info
subject="MC testing report for $cur_date"
(echo -e "Subject: ${subject}\nMIME-Version: 1.0\nFrom: ${FROM}\nTo:${TO}\CC:${CC}\nContent-Type: text/html\nContent-Disposition: inline\n\n";cat ${MC_Report}) | sendmail -f  ${Sender} ${Reciever}
mv ${MC_Report} /gnucwmnt/msticlxl102_users/gnucwtester/Backup/Mail/${cur_date_for_file}_MC_Testing_Status.log