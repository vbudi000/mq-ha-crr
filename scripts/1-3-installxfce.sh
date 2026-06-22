#!/bin/bash

source $(dirname "$0")/hacrrenv.sh

if [[ $(hostname -s) != "$lbhost" ]]; then
    echo "Error: Not running on $lbhost (current host: $(hostname))" >&2
    exit 1
fi
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf --enablerepo=epel group
sudo dnf -y groupinstall "Xfce"
sudo systemctl set-default graphical.target
sudo dnf -y install tigervnc-server

printf "passw0rd\npassw0rd\n" | vncpasswd
echo ":1=root" >> /etc/tigervnc/tigervnc.users
sed -i 's/gnome/xfce/g' "/etc/tigervnc/vncserver-config-defaults"

systemctl enable vncserver@:1
systemctl start vncserver@:1

# install firefox

#sudo dnf config-manager addrepo --id=mozilla --set=baseurl=https://packages.mozilla.org/rpm/firefox --set=gpgkey=https://packages.mozilla.org/rpm/firefox/signing-key.gpg --set=gpgcheck=1 --set=repo_gpgcheck=0 --set=priority=10
sudo dnf makecache --refresh
sudo dnf -y install firefox


## create an SSH tunnel
## ssh -i ~/.ssh/id_001 -L 5901:localhost:5901 root@vbudi-haproxy1.dev.fyre.ibm.com