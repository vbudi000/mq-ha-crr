#!/bin/bash

source ./hacrrenv.sh

hosts=($host11 $host12 $host13 $host21 $host22 $host23)  # Creates an array containing these hosts

for host in "${hosts[@]}"; do
    echo "Processing $host"
    # Your commands for each host here
    scp scripts/hacrrenv.sh ${host}:/tmp/hacrrenv.sh
    scp scripts/3-1-qmgr.sh ${host}:/tmp/3-1-qmgr.sh
    scp scripts/3-2-mqmonitor.sh ${host}:/tmp/3-2-mqmonitor.sh
    ssh ${host} "sudo su - mqm cd /tmp && bash 3-1-qmgr.sh ${qmname}"
    ssh ${host} "sudo bash /tmp/3-2-mqmonitor.sh"
done

