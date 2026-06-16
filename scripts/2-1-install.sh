#!/bin/bash

# Create mqm user and group with consistent GID
groupadd -g 1000 mqm
useradd -u 1000 -g 1000 -d /home/mqm mqm 

cat << EOF > /etc/security/limits.d/30-ibmmq.conf
mqm - nofile 65536
mqm - nproc  32768
EOF

dnf -y install bc ca-certificates openssl libstdc++ wget util-linux
dnf -y install shadow-utils glibc-common findutils gawk

# use the following if firewalld is active
firewall-cmd --permanent --add-port=mqlistener-1414/tcp
firewall-cmd --permanent --add-port=mqadmin-1415/tcp
firewall-cmd --permanent --add-port=mqhalistener-9414/tcp
firewall-cmd --permanent --add-port=mqhaadmin-9415/tcp
firewall-cmd --permanent --add-port=mqweb-9443/tcp

mkdir /var/mqm
mkdir /opt/mqm

chown mqm:mqm /var/mqm
chown mqm:mqm /opt/mqm

# the following are to make it easier for mqm communication - not needed
mkdir /home/mqm/.ssh
chown mqm:mqm /home/mqm/.ssh
chmod 700 /home/mqm/.ssh
sudo -u mqm ssh-keygen -t rsa -b 4096 -f /home/mqm/.ssh/id_rsa -N "" -q
 
cd /tmp
tar -xzvf 9.4.4.0-IBM-MQ-LinuxX64_.tar.gz

cd MQServer
./mqlicense.sh -accept

dnf install -y MQSeries*.rpm

echo "source /opt/mqm/bin/setmqenv -s" > /etc/profile.d/mqm.sh
echo "" >> /etc/profile.d/mqm.sh
chmod 755 /etc/profile.d/mqm.sh

source /etc/profile.d/mqm.sh && dspmqver

