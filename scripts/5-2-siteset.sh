#!/bin/bash
source $(dirname "$0")/hacrrenv.sh

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi
path=$(pwd)  # Get current path
last_two=$(basename "$(dirname "$path")")/$(basename "$path")
if [[ "$last_two" == "mq-ha-crr/scripts" ]]; then
    echo "Checking path, checking tar file"
else
    echo "You must run this script from mq-ha-crr/scripts"
    exit 1
fi

if [ $# -ne 2 ]; then
    echo "${0} site {Recovery|Live}"
    exit 1
fi

site=$1
dir=${2}
QMGR=${qmname}
mkrec="sudo awk -i inplace '{gsub(/GroupRole=Live/, \"GroupRole=Recovery\")} 1' /var/mqm/qmgrs/${QMGR}/qm.ini"
mkliv="sudo awk -i inplace '{gsub(/GroupRole=Recovery/, \"GroupRole=Live\")} 1' /var/mqm/qmgrs/${QMGR}/qm.ini"
if [[ "$site" == "$site1" ]]; then
    hosts=($host11 $host12 $host13)
elif [[ "$site" == "$site2" ]]; then
    hosts=($host21 $host22 $host23)
else
    echo "Wrong site name ${site} - only $site1 or $site2 are valid"
    exit 1
fi

if [[ "$dir" == "Recovery" ]]; then
    for host in "${hosts[@]}"; do
        ssh ${host} ${mkrec} 2>/dev/null
        ssh ${host} sudo chown mqm:mqm /var/mqm/qmgrs/${QMGR}/qm.ini 2>/dev/null
    done
elif [[ "$dir" == "Live" ]]; then
    for host in "${hosts[@]}"; do
        ssh ${host} ${mkliv} 2>/dev/null
        ssh ${host} sudo chown mqm:mqm /var/mqm/qmgrs/${QMGR}/qm.ini 2>/dev/null
    done
else
    echo "Condition not matched - need to recheck"
    echo "${dir} status is not Recovery or Live}"
    exit 9
fi

date '+%Y-%m-%d %H:%M:%S.%3N'
