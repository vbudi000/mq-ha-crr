#!/bin/bash

source $(dirname "$0")/hacrrenv.sh

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

hosts=($host11 $host12 $host13 $host21 $host22 $host23)  # Creates an array containing these hosts
set -x
for host in "${hosts[@]}"; do
    echo "Processing $host"
    # Your commands for each host here
    ssh ${host} "echo \"dltmqm ${qmname} && endmqweb \" | sudo su - mqm" 2>/dev/null
done

