#!/bin/bash
source ./hacrrenv.sh
if [ $# -ne 2 ]; then
    exit 1
fi
action=$2
site=$1

valid_actions=("start" "stop" "status" "restart")

if [[ " ${valid_actions[*]} " =~ " $action " ]]; then
    echo "Invoke ${action} on ${site}"
else
    echo "Invalid action: ${action}
    exit 2
fi

if [[ "$site" == "$site1"]]; then
    hosts=(host11 host12 host13)
    for host in "${hosts[@]}"; do
        ssh ${host} sudo systemctl ${action} mqmonitor@${QMGR} 2>/dev/null
    done
elif [[ "$site" == "$site2"]]; then
    hosts=(host21 host22 host23)
    for host in "${hosts[@]}"; do
        ssh ${host} sudo systemctl ${action} mqmonitor@${QMGR} 2>/dev/null
    done
else
    echo "Wrong site name ${site}"
fi

