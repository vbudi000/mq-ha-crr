#!/bin/bash
# This script sets up passwordless SSH from the bastion host to all QMGR hosts.
# It must be run as root on the bastion/load balancer node.
# Usage: echo "<password>" | ./1-1-setupssh.sh
#   or pipe one password per host line when all hosts share the same password.
# Requires: sshpass

source $(dirname "$0")/hacrrenv.sh

if [[ $(hostname -s) != "$lbhost" ]]; then
    echo "Error: Not running on $lbhost (current host: $(hostname -s))" >&2
    exit 1
fi
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root" >&2
    exit 1
fi

# Verify sshpass is available — required for non-interactive ssh-copy-id
if ! command -v sshpass &>/dev/null; then
    echo "Error: sshpass is not installed. Install it with: dnf install -y sshpass" >&2
    dnf install -y sshpass
fi

# Read the shared root password from stdin (piped in by the caller)
# Note: message goes to stderr so it is not consumed when stdin is a pipe
echo "Enter shared ssh password for root in MQ servers" >&2
read -r ssh_password

hosts=($host11 $host12 $host13 $host21 $host22 $host23)

# First make sure you can log in to the other hosts with a password,
# then generate a local key pair (if one does not already exist) and
# copy the public key to each host's authorized_keys.
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
fi

for host in "${hosts[@]}"; do
    echo "Processing $host"
    # Add the host's public key to known_hosts to avoid interactive prompts
    ssh-keyscan -H "${host}" >> ~/.ssh/known_hosts 2>/dev/null
    # Copy the local public key using the provided password
    sshpass -p "${ssh_password}" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no "root@${host}"
done

