#!/bin/bash
shopt -s extglob

function abort {
    if [ -n "$1" ]; then
        echo "$1"
    fi
    exit 1
}

asking_for_help=false
case "$1" in
    --help|-h)
        asking_for_help=true
        ;;
esac

here="$(cd "$(dirname "$0")";pwd)"

## END TEMPLATE

java -jar /Users/bstiles/Development/Library/BND/Versions/0.0.384/bnd-0.0.384.jar "$@"
