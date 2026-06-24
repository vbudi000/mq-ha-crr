#!/bin/bash
source $(dirname "$0")/hacrrenv.sh
if [[ $(hostname -s) != "$lbhost" ]]; then
    echo "Error: Not running on $lbhost (current host: $(hostname -s))" >&2
    exit 1
fi

# Check which site is active
site1status=$(ssh ${host11} dspmq -o nativeha -g -m ${qmname}  2>/dev/null | grep "QMNAME(${qmname})" | grep -oP 'GRPROLE\(\K[^)]+')
site2status=$(ssh ${host21} dspmq -o nativeha -g -m ${qmname}  2>/dev/null | grep "QMNAME(${qmname})" | grep -oP 'GRPROLE\(\K[^)]+')
QMGR=${qmname}
mkrec="sudo awk -i inplace '{gsub(/GroupRole=Live/, \"GroupRole=Recovery\")} 1' /var/mqm/qmgrs/${QMGR}/qm.ini"
mkliv="sudo awk -i inplace '{gsub(/GroupRole=Recovery/, \"GroupRole=Live\")} 1' /var/mqm/qmgrs/${QMGR}/qm.ini"

if [[ "$site1status" == "Live" && "$site2status" == "Recovery" ]]; then
    dir="L2R"
    echo "Moving Live section from ${site1} to ${site2}"
    ssh ${host11} ${mkrec} 2>/dev/null
    ssh ${host12} ${mkrec} 2>/dev/null
    ssh ${host13} ${mkrec} 2>/dev/null
    ssh ${host21} ${mkliv} 2>/dev/null
    ssh ${host22} ${mkliv} 2>/dev/null
    ssh ${host23} ${mkliv} 2>/dev/null
elif [[ "$site1status" == "Recovery" && "$site2status" == "Live" ]]; then
    dir="R2L"
    echo "Moving Live section from ${site2} to ${site1}"
    ssh ${host21} ${mkrec} 2>/dev/null
    ssh ${host22} ${mkrec} 2>/dev/null
    ssh ${host23} ${mkrec} 2>/dev/null
    ssh ${host11} ${mkliv} 2>/dev/null
    ssh ${host12} ${mkliv} 2>/dev/null
    ssh ${host13} ${mkliv} 2>/dev/null
else
    echo "Condition not matched - need to recheck"
    echo "${site1} status is ${site1status}"
    echo "${site2} status is ${site2status}"
    exit 9
fi

hosts=($host11 $host12 $host13 $host21 $host22 $host23)  # Creates an array containing these hosts

echo "Change ownership back to mqm for qm.ini files"
for host in "${hosts[@]}"; do
    ssh ${host} sudo chown mqm:mqm /var/mqm/qmgrs/${QMGR}/qm.ini 2>/dev/null
done

date '+%Y-%m-%d %H:%M:%S.%3N'

set -x
echo "Stopping QManagers"
for host in "${hosts[@]}"; do
    ssh ${host} sudo systemctl stop mqmonitor@${QMGR} 2>/dev/null
done

echo "Starting QManagers"
for host in "${hosts[@]}"; do
    ssh ${host} sudo systemctl start mqmonitor@${QMGR} 2>/dev/null
done
set +x
date '+%Y-%m-%d %H:%M:%S.%3N'
