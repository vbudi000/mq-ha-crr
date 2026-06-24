#!/bin/bash

source $(dirname "$0")/hacrrenv.sh

curpath="${1:-/root}"  

tarfile=${mqserver}
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Check if file exists
if [ ! -f "${curpath}/${tarfile}" ]; then
    echo "Error: ${curpath}/${tarfile} does not exist"
    exit 1
fi
cd $(dirname "$0")

# Copy MQ install tar file and run the installation

hosts=($host11 $host12 $host13 $host21 $host22 $host23)  # Creates an array containing these hosts

for host in "${hosts[@]}"; do
    echo "Processing $host"
    # Your commands for each host here
    scp ${curpath}/${tarfile} ${host}:/tmp/${tarfile}
    scp hacrrenv.sh ${host}:/tmp/hacrrenv.sh 2>/dev/null
    scp 2-1-install.sh ${host}:/tmp/2-1-install.sh 2>/dev/null
    scp 2-2-mqweb.sh ${host}:/tmp/2-2-mqweb.sh 2>/dev/null
    ssh ${host} "cd /tmp && bash 2-1-install.sh ${tarfile}" 2>/dev/null
    ssh ${host} "echo \"bash /tmp/2-2-mqweb.sh\" | sudo su - mqm " 2>/dev/null
done

