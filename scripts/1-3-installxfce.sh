#!/bin/bash

source ./hacrrenv.sh

sudo dnf -y install tigervnc-server
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf --enablerepo=epel group
sudo dnf -y groupinstall "Xfce"
sudo systemctl set-default graphical.target

printf "passw0rd\npassw0rd\n" | vncpasswd
vncserver
vncserver -kill :1
cat <<EOF > ~/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
xrdb $HOME/.Xresources
startxfce4 &
EOF

vncserver

# install firefox

#sudo dnf config-manager addrepo --id=mozilla --set=baseurl=https://packages.mozilla.org/rpm/firefox --set=gpgkey=https://packages.mozilla.org/rpm/firefox/signing-key.gpg --set=gpgcheck=1 --set=repo_gpgcheck=0 --set=priority=10
sudo dnf makecache --refresh
sudo dnf -y install firefox


## create an SSH tunnel
## ssh -i ~/.ssh/id_001 -L 5901:localhost:5901 root@vbudi-haproxy1.dev.fyre.ibm.com