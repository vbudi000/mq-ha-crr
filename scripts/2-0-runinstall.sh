#!/bin/bash

source ./hacrrenv.sh
tarfile="9.4.5.0-IBM-MQ-LinuxX64_.tar.gz"
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

# Check if file exists
if [ ! -f "/root/${tarfile}" ]; then
    echo "Error: /root/${tarfile} does not exist"
    exit 1
fi

# Copy MQ install tar file and run the installation

hosts=($host11 $host12 $host13 $host21 $host22 $host23)  # Creates an array containing these hosts

for host in "${hosts[@]}"; do
    echo "Processing $host"
    # Your commands for each host here
    scp /root/${tarfile} ${host}:/tmp/${tarfile}
    scp hacrrenv.sh ${host}/tmp/hacrrenv.sh
    scp 2-1-install.sh ${host}:/tmp/2-1-install.sh
    scp 2-2-mqweb.sh ${host}:/tmp/2-2-mqweb.sh
    ssh ${host} "cd /tmp && bash 2-1-install.sh ${tarfile}"
    ssh ${host} "echo \"bash /tmp/2-2-mqweb.sh\" | sudo su - mqm "
done

