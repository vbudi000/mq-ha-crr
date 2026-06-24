#!/bin/bash
source $(dirname "$0")/hacrrenv.sh

if [[ $(hostname -s) != "$lbhost" ]]; then
    echo "Error: Not running on $lbhost (current host: $(hostname -s))" >&2
    exit 1
fi
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root" >&2
    exit 1
fi

dnf -y install haproxy

systemctl stop haproxy

mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

# Use > not >> because the original file was just moved away
cat <<EOF >/etc/haproxy/haproxy.cfg
defaults
    mode                    tcp
    log                     global
    option                  tcplog
    option                  tcp-check
    timeout connect         500ms
    timeout client          50000ms
    timeout server          50000ms
    timeout check           20ms

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend mqlistener
    bind *:1414
    mode tcp
    option tcplog
    default_backend             myqmgr

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend myqmgr
    balance roundrobin
    option tcp-check
    tcp-check connect port 1414

    server  ${host11} ${ip11}:1414 check inter 50ms rise 2 fall 2 maxconn 1000
    server  ${host12} ${ip12}:1414 check inter 50ms rise 2 fall 2 maxconn 1000
    server  ${host13} ${ip13}:1414 check inter 50ms rise 2 fall 2 maxconn 1000
    server  ${host21} ${ip21}:1414 check inter 50ms rise 2 fall 2 maxconn 1000
    server  ${host22} ${ip22}:1414 check inter 50ms rise 2 fall 2 maxconn 1000
    server  ${host23} ${ip23}:1414 check inter 50ms rise 2 fall 2 maxconn 1000
EOF

sudo systemctl start haproxy