#!/bin/bash

source ./hacrrenv.sh

ssh ${host11} dspmq -o nativeha -g -x
ssh ${host21} dspmq -o nativeha -g -x
