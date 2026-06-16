#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <qmgr_name>"
    exit 1
else 
    qmgr=$1
fi

sudo ln -s /opt/mqm/samp/mqmonitor@.service /etc/systemd/system 
sudo systemctl enable mqmonitor@${qmgr}
sudo systemctl start mqmonitor@${qmgr}