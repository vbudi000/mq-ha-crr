#! /bin/bash

# must be run as mqm at the active instance
source ./hacrrenv.sh
# Check which site is active
site1status=$(ssh ${host11} dspmq -o nativeha -g -m ${qmname}  2>/dev/null | grep "QMNAME(${qmname})" | grep -oP 'GRPROLE\(\K[^)]+')
site2status=$(ssh ${host21} dspmq -o nativeha -g -m ${qmname}  2>/dev/null | grep "QMNAME(${qmname})" | grep -oP 'GRPROLE\(\K[^)]+')
QMGR=${qmname}


cat <<EOF > /tmp/infile
ALTER QMGR CONNAUTH('') CHLAUTH(DISABLED)
SET CHLAUTH(SYSTEM.DEF.SVRCONN) TYPE(ADDRESSMAP) ADDRESS(*) USERSRC(CHANNEL)
DEFINE QLOCAL(QUEUE1) DEFPSIST(YES)
REFRESH SECURITY (*)
END
EOF

if [[ "$site1status" == "Live" && "$site2status" == "Recovery" ]]; then
    active_instance=$(ssh ${host11} dspmq -o nativeha -x -m ${qmname}  2>/dev/null | grep -v QMNAME | grep "ROLE(Active)" | grep -oP 'INSTANCE\(\K[^)]+')
    echo "Finding Queue Manager in ${active_instance}"
elif [[ "$site1status" == "Recovery" && "$site2status" == "Live" ]]; then
    active_instance=$(ssh ${host21} dspmq -o nativeha -x -m ${qmname}  2>/dev/null | grep -v QMNAME | grep "ROLE(Active)" | grep -oP 'INSTANCE\(\K[^)]+')
    echo "Finding Queue Manager in ${active_instance}"
else
    echo "Condition not matched - need to recheck"
    echo "${site1} status is ${site1status}"
    echo "${site2} status is ${site2status}"
    exit 9
fi

scp /tmp/infile ${active_instance}:/tmp/modqm.txt
ssh ${active_instance} "echo \"cat /tmp/modqm.txt | runmqsc ${qmname}\" | sudo su - mqm" 2>/dev/null

date '+%Y-%m-%d %H:%M:%S.%3N'

rm /tmp/infile