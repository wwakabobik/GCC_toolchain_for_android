#!/bin/bash

if [[ -z $1 ]] ; then
	echo 'Example: script.sh test.xml'
	exit 1
fi

perl /users/common/submit.pl scstraqs2new.sc.intel.com GCC GCC $USER $1

