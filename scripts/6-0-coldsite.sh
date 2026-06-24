#!/bin/bash

source $(dirname "$0")/hacrrenv.sh
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi
if [[ $(hostname -s) != "$lbhost" ]]; then
    echo "Error: Not running on $lbhost (current host: $(hostname -s))" >&2
    exit 1
fi

cd $(dirname "$0")

if [ $# -ne 1 ]; then
    echo "Must supply site name as first argument"
    exit 1
fi
site=$1

if [[ "$site" == "$site1" ]]; then
    hosts=($host11 $host12 $host13)
elif [[ "$site" == "$site2" ]]; then
    hosts=($host21 $host22 $host23)
else
    echo "Wrong site name ${site}"
    exit 1
fi

for host in "${hosts[@]}"; do
    scp 6-3-coldstart.sh ${host}:/tmp/6-3-coldstart.sh 2>/dev/null
    ssh ${host} "echo \"bash /tmp/6-3-coldstart.sh\" | sudo su - mqm" 2>/dev/null
done

