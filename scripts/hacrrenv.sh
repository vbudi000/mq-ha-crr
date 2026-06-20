#!/bin/bash
# --------------------------------------------------------
# this is the primary envirnment variables file 
# --------------------------------------------------------

site1="SITE1"
host11="mq-hacrr-01"
host12="mq-hacrr-02"
host13="mq-hacrr-03"

site2="SITE2"
host21="mq-hacrr-04"
host22="mq-hacrr-05"
host23="mq-hacrr-06"

lbhost="mq-hacrr-lb"

qmname="MYQMGR"

mqserver="9.4.5.0-IBM-MQ-LinuxX64_.tar.gz"
mqclient="9.4.5.1-IBM-MQC-LinuxX64.tar.gz"
# --------------------------------------------------------
# Do not modify the rest of the file
# --------------------------------------------------------

ip11=$(getent hosts ${host11} | awk '{print $1}')
ip12=$(getent hosts ${host12} | awk '{print $1}')
ip13=$(getent hosts ${host13} | awk '{print $1}')

ip21=$(getent hosts ${host21} | awk '{print $1}')
ip22=$(getent hosts ${host22} | awk '{print $1}')
ip23=$(getent hosts ${host23} | awk '{print $1}')


