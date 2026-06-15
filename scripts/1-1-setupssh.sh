#!/bin/bash

source hacrrenv.sh

if [[ $(hostname -s) != "$lbhost" ]]; then
    echo "Error: Not running on $lbhost (current host: $(hostname))" >&2
    exit 1
fi
ssh-keyscan ${host11} >> ~/.ssh/known_hosts
ssh-keyscan ${host12} >> ~/.ssh/known_hosts
ssh-keyscan ${host13} >> ~/.ssh/known_hosts
ssh-keyscan ${host21} >> ~/.ssh/known_hosts
ssh-keyscan ${host22} >> ~/.ssh/known_hosts
ssh-keyscan ${host23} >> ~/.ssh/known_hosts

ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""

# First make sure you can login to the other hosts with password

scp ~/.ssh/id_rsa.pub ${host11}:/tmp/id_rsa.pub
ssh "${host11}" <<'EOF' 
  cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  echo " PubkeyAuthentication yes"  >> /etc/ssh/sshd_config.d/99-mqhacrr.conf
  systemctl restart sshd
EOF

scp ~/.ssh/id_rsa.pub ${host12}:/tmp/id_rsa.pub
ssh "${host12}" <<'EOF' 
  cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  echo " PubkeyAuthentication yes"  >> /etc/ssh/sshd_config.d/99-mqhacrr.conf
  systemctl restart sshd
EOF

scp ~/.ssh/id_rsa.pub ${host13}:/tmp/id_rsa.pub
ssh "${host13}" <<'EOF' 
  cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  echo " PubkeyAuthentication yes"  >> /etc/ssh/sshd_config.d/99-mqhacrr.conf
  systemctl restart sshd
EOF

scp ~/.ssh/id_rsa.pub ${host21}:/tmp/id_rsa.pub
ssh "${host21}" <<'EOF' 
  cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  echo " PubkeyAuthentication yes"  >> /etc/ssh/sshd_config.d/99-mqhacrr.conf
  systemctl restart sshd
EOF

scp ~/.ssh/id_rsa.pub ${host22}:/tmp/id_rsa.pub
ssh "${host22}" <<'EOF' 
  cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  echo " PubkeyAuthentication yes"  >> /etc/ssh/sshd_config.d/99-mqhacrr.conf
  systemctl restart sshd
EOF

scp ~/.ssh/id_rsa.pub ${host23}:/tmp/id_rsa.pub
ssh "${host23}" <<'EOF' 
  cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  echo " PubkeyAuthentication yes"  >> /etc/ssh/sshd_config.d/99-mqhacrr.conf
  systemctl restart sshd
EOF

