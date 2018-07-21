#!/bin/bash

cur_date=`date +%Y`/`date +%m`/`date +%d`@`date +%H`:`date +%M`:`date +%S`
monitor_share=/nfs/ims/proj/icl/gcc_cw/share/monitor
info_file=$monitor_share/info.html
temp_file=$monitor_share/info.temp.html
out_temp=$monitor_share/info.out.tmp.html
static_file=$monitor_share/disconnected_phones.html
cw_users="classified@intel.com"
intel_qa_users="classified@intel.com"


for fail_count in 0 1 2 3 4 5 6 7 8
do
    cp ${info_file} ${temp_file}
    grep disconnected ${temp_file} | grep -v HarrisBeach >${out_temp}
    if [ "$?" != "0" ]; then
	rm ${static_file} 2>/dev/null
	break
    else
	if [ ${fail_count} == "8" ]; then
	    out_file=$monitor_share/info.out.html
	    static_file=$monitor_share/disconnected_phones.html
	    echo "<HTML><HEAD><TITLE>Phones are disconnected</TITLE></HEAD><BODY><H1>Please reboot/reconnect following phones:</H1>" >${out_file}
	    cat ${out_temp} >>${out_file}
	    echo "</BODY></HTML>" >>${out_file}
	    cmp ${out_file} ${static_file} 1>/dev/null 2>/dev/null
	    if [ "$?" != "0" ] || [ -z $1 ]; then
		cp ${out_file} ${static_file}
		FROM=gnucwtester
		TO=ilyax.g.vereschagin@intel.com
		subject="Phones are disconnected for $cur_date"
		if [ -z $1 ]; then
		    CC="${intel_qa_users},${cw_users}"
		else
		    CC="${cw_users}"
		fi
		Reciever="$TO,$CC"
		Sender="gnucwtester@ecsmtp.ims.intel.com"
		(echo -e "Subject: ${subject}\nMIME-Version: 1.0\nFrom: ${FROM}\nTo:${TO}\CC:${CC}\nContent-Type: text/html\nContent-Disposition: inline\n\n";cat ${out_file}) | sendmail -f  ${Sender} ${Reciever}
		echo "sendmail -f  ${Sender} ${Reciever}"
	    fi
	    rm ${out_file}
	fi
    fi
    rm ${temp_file} 2>/dev/null
    rm ${out_temp} 2>/dev/null
    sleep 114s
done
rm ${temp_file} 2>/dev/null
rm ${out_temp} 2>/dev/null


