#!/bin/bash

for i in $(ls /sys/class/net/) ; do
    if [[ $i == "tap"* ]] ; then 
        sudo /usr/sbin/ip addr flush $i;
    fi;
done; 
