#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ "${1}" == "unifi" ]
then
	if [ -z "${MEM_LIMIT+x}" ]
	then
		MEM_LIMIT='1024M'
	fi
	
	set -- java -Xmx"${MEM_LIMIT}" -jar '/usr/lib/unifi/lib/ace.jar' 'start'
fi

exec "${@}"
