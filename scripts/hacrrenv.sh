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

# --------------------------------------------------------
# Do not modify the rest of the file
# --------------------------------------------------------

ip11=$(dig +short ${host11})
ip12=$(dig +short ${host12})
ip13=$(dig +short ${host13})

ip21=$(dig +short ${host21})
ip22=$(dig +short ${host22})
ip23=$(dig +short ${host23})


