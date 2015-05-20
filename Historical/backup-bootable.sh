#!/bin/sh

# To use Apple's rsync switch commented lines below
# To use rsyncx:
# To use built-in rsync (OS X 10.4 and later):
RSYNC="/usr/bin/rsync -E"
  
# sudo runs the backup as root
# -E enables HFS+ mode
# -a turns on archive mode (recursive copy + retain attributes)
# -x don't cross device boundaries (ignore mounted volumes)
# -S handle sparse files efficiently
# --delete deletes any files that have been deleted locally
# "$@" expands to any extra command line options you may give

sudo $RSYNC -a -x -S --delete --progress \
--exclude-from backup-bootable.excludes.txt "$@" / /Volumes/Brian\'s\ Backup/

# make the backup bootable - comment this out if needed

sudo bless -folder /Volumes/Brian\'s\ Backup/System/Library/CoreServices