#!/bin/bash
. "$(dirname "$0")"/init.sh

rsync\
 --progress\
 --archive\
 --exclude=.Trash\
 --exclude=Desktop/Downloads\
 --exclude=tmp\
 /Users/bstiles/\
 192.168.1.11:/home/data/PowerBookBackup/