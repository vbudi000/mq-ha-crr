#!/bin/bash

source hacrrenv.sh

if [[ $(hostname -s) != "$lbhost" ]]; then
    echo "Error: Not running on $lbhost (current host: $(hostname))" >&2
    exit 1
fi

tar -xvzf /root/10.0.0.0-IBM-MQC-LinuxX64.tar.gz
cd MQClient
./mqlicense.sh -accept
dnf install -y MQ*

echo "source /opt/mqm/bin/setmqenv -s" > /etc/profile.d/mqm.sh
echo "export PATH=/opt/mqm/samp/bin:\$PATH" >> /etc/profile.d/mqm.sh
chmod 755 /etc/profile.d/mqm.sh

source /etc/profile.d/mqm.sh && dspmqver