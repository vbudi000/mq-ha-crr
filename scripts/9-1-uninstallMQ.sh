#!/bin/bash
source $(dirname "$0")/hacrrenv.sh
sudo systemctl stop mqmonitor@${qmname}
sudo systemctl disable mqmonitor@${qmname}
sudo su - mqm -c "endmqweb"
sudo su - mqm -c "dltmqinst Installation1"

sudo dnf remove -y MQ* 
sudo rm -rf /var/mqm
sudo rm -rf /opt/mqm
