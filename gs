#!/bin/bash

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GS=$(which -a gs | grep -v "$here/$(basename "$0")" | head -1)

# 2015-11-02 bstiles: Protect against typos when trying to run the
# 'git status' abbreviation 'g s'
read -p "Really run gs? (y/N) "
[[ $REPLY =~ [yY] ]] && exec $GS "$@"
