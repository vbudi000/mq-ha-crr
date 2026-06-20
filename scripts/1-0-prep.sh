#!/bin/bash

cat <<EOF | ./1-1-setupssh.sh
TheMQPassw0rd123!
TheMQPassw0rd123!
TheMQPassw0rd123!
TheMQPassw0rd123!
TheMQPassw0rd123!
TheMQPassw0rd123!
EOF
./1-2-haproxy.sh
./1-3-installxfce.sh
./1-4-mqclient.sh