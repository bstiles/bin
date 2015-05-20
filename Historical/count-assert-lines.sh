#!/bin/bash
. "$(dirname "$0")"/init.sh

if [ $# -lt 1 ]; then
    echo "usage: $(basename "$0") dir [dir...]"
    exit 1
fi
find "$@" -type f \( -name \*.java -o -name \*.js -o -name \*.py \) -exec cat {} \; | grep '\(rp_assert\|\<assert\>\)' | wc
