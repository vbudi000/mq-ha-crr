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


hosts=($host11 $host12 $host13 $host21 $host22 $host23)  # Creates an array containing these hosts

for host in "${hosts[@]}"; do
    echo "Processing $host"
    # Your commands for each host here
    scp hacrrenv.sh ${host}:/tmp/hacrrenv.sh 2>/dev/null
    scp 3-1-qmgr.sh ${host}:/tmp/3-1-qmgr.sh 2>/dev/null
    scp 3-2-mqmonitor.sh ${host}:/tmp/3-2-mqmonitor.sh 2>/dev/null
    ssh ${host} "echo \"cd /tmp && bash 3-1-qmgr.sh ${qmname}\" | sudo su - mqm" 2>/dev/null
    ssh ${host} "sudo bash /tmp/3-2-mqmonitor.sh @qmname" 2>/dev/null
done

