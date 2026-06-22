#!/bin/bash

source $(dirname "$0")/hacrrenv.sh
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

hosts=($host11 $host12 $host13 $host21 $host22 $host23)

for host in "${hosts[@]}"; do
    scp ${host}:/var/mqm/qmgrs/${qmname}/errors/AMQERR01.LOG ${host}-AMQERR01.LOG 2>/dev/null
done

