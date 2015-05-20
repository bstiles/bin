#!/bin/bash
. "$(dirname "$0")"/init.sh

rsync -a --include='**.m4p' --exclude='**.[^m]*' --exclude='**.[Mm]*' "/Volumes/iomega HD/iTunes Music/" "/Users/bstiles/Music/Purchased Music Backups/"

