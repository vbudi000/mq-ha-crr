#!/bin/bash

if [ "$(whoami)" != "mqm" ]; then
    echo "Error: This script must be run as user 'abc'"
    exit 1
fi
host=$(hostname -s)

# initialize mqweb structure
strmqweb
endmqweb

cd /var/mqm/web/installations/Installation1/servers/mqweb/
cp mqwebuser.xml mqwebuser.xml.bak
cp /opt/mqm/web/mq/samp/configuration/basic_registry.xml mqwebuser.xml

cat <EOF >>mqwebuser.xml
<variable name="httpsPort" value="9443"/>
<variable name="httpHost" value="*"/>
<variable name="mqRestMessagingEnabled" value="true”/>
EOF

strmqweb
curl -k https://${host}:9443/ibmmq/rest/v3/admin/qmgr/ -X GET -u mqadmin:mqadmin
