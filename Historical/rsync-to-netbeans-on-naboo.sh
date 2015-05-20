#!/bin/bash
. "$(dirname "$0")"/init.sh

if [ $# = 1 -a $1. != "-update." ]; then
    echo "usage: $0 [-update]"
    exit 1
fi

update=false
if [ $# = 1 -a $1. = "-update." ]; then
    update=true
fi

target_host=192.168.1.11

if [ $update != "true" ]; then
    fake_dir=/tmp/sync$$
    mkdir -p $fake_dir/src

    rsync\
     --progress\
     --stats\
     --archive\
     --delete\
      "$fake_dir/src"\
      $target_host:/home/bslocal/

    rmdir $fake_dir/src
    rmdir $fake_dir
fi

for src_dir in /Users/bstiles/Development/Projects/K*/src /Users/bstiles/Development/Projects/TableDefinitions; do
    if [ -n "$src_dir" -a -d "$src_dir" ]; then
        rsync\
         --progress\
         --stats\
         --archive\
         --exclude=CVS\
         --exclude=metaedit\
         --exclude=feed\
         "$src_dir"\
         $target_host:/home/bslocal/
    fi
done

rsync\
 --progress\
 --stats\
 --archive\
 --copy-links\
 --exclude=CVS\
 --exclude=metaedit\
 --exclude=feed\
 --exclude=appdb-ds.xml\
 --exclude=bstest-ds.xml\
 /Users/bstiles/Development/Servers/Deploy\
 $target_host:/home/bslocal/
