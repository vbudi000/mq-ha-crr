#!/bin/bash

tar -xvzf 10.0.0.0-IBM-MQC-LinuxX64.tar.gz
cd MQClient
./mqlicense.sh -accept
dnf install -y MQ*

echo "source /opt/mqm/bin/setmqenv -s" > /etc/profile.d/mqm.sh
echo "export PATH=/opt/mqm/samp/bin:$PATH" >> /etc/profile.d/mqm.sh
chmod 755 /etc/profile.d/mqm.sh

source /etc/profile.d/mqm.sh && dspmqver