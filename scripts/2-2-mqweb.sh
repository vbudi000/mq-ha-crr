#!/bin/bash

if [ "$(whoami)" != "mqm" ]; then
    echo "Error: This script must be run as user 'mqm'"
    exit 1
fi
host=$(hostname -s)

# initialize mqweb structure
strmqweb
endmqweb

cd /var/mqm/web/installations/Installation1/servers/mqweb/
cp mqwebuser.xml mqwebuser.xml.bak
cp /opt/mqm/web/mq/samp/configuration/basic_registry.xml mqwebuser.xml

xmlstarlet ed -L \
    -s "/server" -t elem -n "variable" \
    --var mynode1 '$prev' \
    -i '$mynode1' -t attr -n "name" -v "httpHost" \
    -i '$mynode1' -t attr -n "value" -v "*" \
    -s  "/server" -t elem -n "variable" \
    --var mynode2 '$prev' \
    -i '$mynode2' -t attr -n "name" -v "httpsPort" \
    -i '$mynode2' -t attr -n "value" -v "9443" \
    -s "/server" -t elem -n "variable" \
    --var mynode3 '$prev' \
    -i '$mynode3' -t attr -n "name" -v "mqRestMessagingEnabled" \
    -i '$mynode3' -t attr -n "value" -v "true" \
    "mqwebuser.xml"

strmqweb
curl -k https://${host}:9443/ibmmq/rest/v3/admin/qmgr/ -X GET -u mqadmin:mqadmin
