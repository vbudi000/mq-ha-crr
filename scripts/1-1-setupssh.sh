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

ssh-copy-id ${host11}
ssh-copy-id ${host12}
ssh-copy-id ${host13}
ssh-copy-id ${host21}
ssh-copy-id ${host22}
ssh-copy-id ${host23}

