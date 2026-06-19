#!/bin/bash

curnode=$(hostname -s)

source ./hacrrenv.sh
cluster1=($host11 $host12 $host13)
cluster2=($host21 $host22 $host23)

if [[ " ${cluster1[*]} " =~ " $curnode " ]]; then
  curgrp=${site1}
elif [[ " ${cluster2[*]} " =~ " $curnode " ]]; then
  curgrp=${site2}
fi

crtmqm -lr ${curnode} -lf 8192 -lp 10 -ls 10 -p 1414 ${qmname}

# edit qm.ini 
if [[ "$curgrp" == "$site1" ]]; then
cat << EOF >> /var/mqm/qmgrs/${qmname}/qm.ini
   GroupName=${site1}
   GroupRole=Live
   GroupLocalAddress=(9415)
NativeHARecoveryGroup:
   GroupName=${site2}
   ReplicationAddress=${ip21}(9415),${ip22}(9415),${ip23}(9415)
   Enabled=Yes
NativeHAInstance:
  Name=${host11}
  ReplicationAddress=${ip11}(9414)
NativeHAInstance:
  Name=${host12}
  ReplicationAddress=${ip12}(9414)
NativeHAInstance:
  Name=${host13}
  ReplicationAddress=${ip13}(9414)
EOF
elif [[ "$curgrp" == "$site2" ]]; then
cat << EOF >> /var/mqm/qmgrs/${qmname}/qm.ini
   GroupName=${site2}
   GroupRole=Recovery
   GroupLocalAddress=(9415)
NativeHARecoveryGroup:
   GroupName=${site1}
   ReplicationAddress=${ip21}(9415),${ip22}(9415),${ip23}(9415)
   Enabled=Yes
NativeHAInstance:
  Name=${host21}
  ReplicationAddress=${ip21}(9414)
NativeHAInstance:
  Name=${host22}
  ReplicationAddress=${ip22}(9414)
NativeHAInstance:
  Name=${host23}
  ReplicationAddress=${ip23}(9414)
EOF
fi

/opt/mqm/bin/strmqm ${qmname}

sleep 10 

/opt/mqm/bin/dspmq -o nativeha -x -g

