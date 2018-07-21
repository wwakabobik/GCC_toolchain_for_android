#!/bin/bash

if [ -z $1 ] ; then
	echo "use: $0 /path/to/traq_report.xml"
	exit 1
else
	cd $(dirname $1)
	pwd
	perl /users/common/submit.pl scstraqs2new.sc.intel.com GCC GCC $USER traq_report.xml
fi
