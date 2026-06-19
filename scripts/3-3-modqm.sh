#! /bin/bash

# must be run as mqm at the active instance
source ./hacrrenv.sh
# Check which site is active
site1status=$(ssh ${host11} dspmq -o nativeha -g -m ${qmname}  2>/dev/null | grep "QMNAME(${qmname})" | grep -oP 'GRPROLE\(\K[^)]+')
site2status=$(ssh ${host21} dspmq -o nativeha -g -m ${qmname}  2>/dev/null | grep "QMNAME(${qmname})" | grep -oP 'GRPROLE\(\K[^)]+')
QMGR=${qmname}


cat <<EOF > /tmp/infile
ALTER QMGR CONNAUTH('')
SET CHLAUTH(SYSTEM.DEF.SVRCONN) 
DEFINE QLOCAL(QUEUE1) DEFPSIST(YES)
EXIT
EOF

if [[ "$site1status" == "Live" && "$site2status" == "Recovery" ]]; then
    active_instance=$(ssh ${host11} dspmq -o nativeha -x -m ${qmname}  2>/dev/null | grep -v QMNAME | grep "ROLE(Active)" | grep -oP 'INSTANCE\(\K[^)]+')
    echo "Restarting Queue Manager in ${active_instance}"
    cat /tmp/infile | ssh ${active_instance} sudo su - mqm runmqsc ${qmname} 2>/dev/null"
elif [[ "$site1status" == "Recovery" && "$site2status" == "Live" ]]; then
    active_instance=$(ssh ${host21} dspmq -o nativeha -x -m ${qmname}  2>/dev/null | grep -v QMNAME | grep "ROLE(Active)" | grep -oP 'INSTANCE\(\K[^)]+')
    echo "Restarting Queue Manager in ${active_instance}"
    cat /tmp/infile | ssh ${active_instance} sudo su - mqm runmqsc ${qmname} 2>/dev/null"
else
    echo "Condition not matched - need to recheck"
    echo "${site1} status is ${site1status}"
    echo "${site2} status is ${site2status}"
    exit 9
fi

date '+%Y-%m-%d %H:%M:%S.%3N'

rm /tmp/infile