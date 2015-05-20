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

function display_help {
    echo "usage: $(basename "$0")"
}

if [ $asking_for_help = true ]; then
    display_help
    exit 0
fi

## END TEMPLATE

curl \
--silent \
-o /dev/null \
-X TRACE \
--write-out '%{http_code}' \
'http://localhost:80/'
