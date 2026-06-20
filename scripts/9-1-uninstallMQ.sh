#!/bin/bash
source hacrrenv.sh
sudo systemctl stop mqmonitor@${qmname}
sudo systemctl disable mqmonitor@${qmname}
sudo su - mqm endmqweb
sudo su - mqm dltmqinst Installation1

sudo dnf remove -y MQ* 
sudo rm -rf /var/mqm
sudo rm -rf /opt/mqm
