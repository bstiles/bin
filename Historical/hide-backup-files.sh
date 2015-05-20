#!/bin/bash
. "$(dirname "$0")"/init.sh

if [ $# -ne 1 ]; then
    echo "usage: $(basename "$0") dir [[dir...] [find_options...]]"
    exit 1
fi

find "$@" -type f -name \*~ -exec /Developer/Tools/SetFile -a V {} \;
