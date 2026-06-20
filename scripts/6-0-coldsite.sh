#!/bin/bash

source ./hacrrenv.sh
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi
path=$(pwd)  # Get current path
last_two=$(basename "$(dirname "$path")")/$(basename "$path")
if [[ "$last_two" == "mq-ha-crr/scripts" ]]; then
    echo "Checking path, checking tar file"
else
    echo "You must run this script from mq-ha-crr/scripts"
    exit 1
fi

if [ $# -ne 1 ]; then
    exit 1
fi
site=$1

if [[ "$site" == "$site1" ]]; then
    hosts=($host11 $host12 $host13)
elif [[ "$site" == "$site2" ]]; then
    hosts=($host21 $host22 $host23)
else
    echo "Wrong site name ${site}"
fi

for host in "${hosts[@]}"; do
    scp 6-3-coldstart.sh ${host}:/tmp/6-3-coldstart.sh 2>/dev/null
    ssh ${host} "echo \"bash /tmp/6-3-coldstart.sh\" | sudo su - mqm" 2>/dev/null
done

