#!/bin/bash
# --------------------------------------------------------
# this is the primary envirnment variables file 
# --------------------------------------------------------

site1="SITE1"
host11="vbudi-mq-1"
host12="vbudi-mq-2"
host13="vbudi-mq-3"

site2="SITE2"
host21="vbudi-mq21"
host22="vbudi-mq22"
host23="vbudi-mq23"

lbhost="vbudi-lb"

qmname="MYQMGR"

mqserver="10.0.0.0-IBM-MQ-LinuxX64.tar.gz"
mqclient="10.0.0.0-IBM-MQC-LinuxX64.tar.gz"
# --------------------------------------------------------
# Do not modify the rest of the file
# --------------------------------------------------------

ip11=$(getent hosts ${host11} | awk '{print $1}')
ip12=$(getent hosts ${host12} | awk '{print $1}')
ip13=$(getent hosts ${host13} | awk '{print $1}')

ip21=$(getent hosts ${host21} | awk '{print $1}')
ip22=$(getent hosts ${host22} | awk '{print $1}')
ip23=$(getent hosts ${host23} | awk '{print $1}')


