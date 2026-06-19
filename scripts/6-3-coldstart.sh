#!/bin/bash
qmgr="${1:-MYQMGR}"
curnode=$(hostname -s)
# run as mqm
sudo systemctl stop mqmonitor@$qmgr
cp /var/mqm/qmgrs/$qmgr/qm.ini /tmp/qm.ini
dltmqm $qmgr
crtmqm -lr ${curnode} -lf 8192 -lp 10 -ls 10 -p 1414 ${qmgr}
cp /tmp/qm.ini /var/mqm/qmgrs/$qmgr/qm.ini
sudo systemctl start mqmonitor@$qmgr