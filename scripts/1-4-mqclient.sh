#!/bin/bash

source $(dirname "$0")/hacrrenv.sh

curpath="${1:-/root}"  
tarfile=${mqclient}

if [[ $(hostname -s) != "$lbhost" ]]; then
    echo "Error: Not running on $lbhost (current host: $(hostname))" >&2
    exit 1
fi
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi
# Check if file exists
if [ ! -f "${curpath}/${tarfile}" ]; then
    echo "Error: ${curpath}/${tarfile} does not exist"
    exit 1
fi

tar -xvzf ${curpath}/${tarfile}
cd MQClient
./mqlicense.sh -accept
dnf install -y MQ*

echo "source /opt/mqm/bin/setmqenv -s" > /etc/profile.d/mqm.sh
echo "export PATH=/opt/mqm/samp/bin:\$PATH" >> /etc/profile.d/mqm.sh
chmod 755 /etc/profile.d/mqm.sh

source /etc/profile.d/mqm.sh && dspmqver