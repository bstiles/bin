#!/bin/bash
. "$(dirname "$0")"/init.sh

mkdir /Volumes/iomega\ HD/bstiles
rsync\
 --progress\
 --archive\
 --exclude=.Trash\
 --exclude=tmp\
 /Users/bstiles/\
 /Volumes/iomega\ HD/bstiles/