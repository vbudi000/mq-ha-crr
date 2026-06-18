#!/bin/bash
source ./hacrrenv.sh

sudo dnf -y install haproxy

sudo systemctl stop haproxy

mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

cat <<EOF >>/etc/haproxy/haproxy.cfg
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