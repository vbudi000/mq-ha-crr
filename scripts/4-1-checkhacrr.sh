#!/bin/bash

source $(dirname "$0")/hacrrenv.sh

if [[ $(hostname -s) != "$lbhost" ]]; then
    echo "Error: Not running on $lbhost (current host: $(hostname))" >&2
    exit 1
fi

set -x
ssh ${host11} dspmq -o nativeha -g -x 2>/dev/null
ssh ${host21} dspmq -o nativeha -g -x 2>/dev/null
