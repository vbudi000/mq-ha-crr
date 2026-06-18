#!/bin/bash

source ./hacrrenv.sh

tarfile="9.4.5.0-IBM-MQ-LinuxX64_.tar.gz"
# Copy MQ install tar file and run the installation

hosts=($host11 $host12 $host13 $host21 $host22 $host23)  # Creates an array containing these hosts

for host in "${hosts[@]}"; do
    echo "Processing $host"
    # Your commands for each host here
    scp ${tarfile} ${host}:/tmp/${tarfile}
    scp hacrrenv.sh ${host}/tmp/hacrrenv.sh
    scp 2-1-install.sh ${host}:/tmp/2-1-install.sh
    scp 2-2-mqweb.sh ${host}:/tmp/2-2-mqweb.sh
    ssh ${host} "cd /tmp && bash 2-1-install.sh ${tarfile}"
    ssh ${host} "sudo su - mqm bash /tmp/2-2-mqweb.sh"
done

