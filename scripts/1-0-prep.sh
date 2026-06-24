#!/bin/bash

# Source environment variables
source $(dirname "$0")/hacrrenv.sh

# Verify this host is the load balancer
if [ "$(hostname -s)" != "${lbhost}" ]; then
    echo "Error: this script must run on ${lbhost}, current host is $(hostname)"
    exit 1
fi
pass=${1:-"TheMQPassw0rd123!"}
cd $(dirname "$0")

echo "${pass}" | ./1-1-setupssh.sh
./1-2-haproxy.sh
./1-3-installxfce.sh
./1-4-mqclient.sh