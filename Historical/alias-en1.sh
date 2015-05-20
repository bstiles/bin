#!/bin/bash

if [ "$1x" = "upx" ]; then
    /sbin/ifconfig en1 inet 172.16.123.11 netmask 255.255.255.0 alias
    /sbin/ifconfig en1 media autoselect
    /sbin/ifconfig en1 mediaopt hw-loopback
elif [ "$1x" = "downx" ]; then
    /sbin/ifconfig en1 -mediaopt hw-loopback
    /sbin/ifconfig en1 media autoselect
    /sbin/ifconfig en1 inet 172.16.123.11 netmask 255.255.255.0 -alias
else
    echo "usage: $0 up|down"
fi
