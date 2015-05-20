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
    echo "usage: $(basename "$0") baseline new target"
    echo "    baseline          Original baseline file contents intended to be changed"
    echo "    new               New contents to replace the existing contents"
    echo "    target            File to be changed"
    echo "Replaces the contents of target with new if the existing contents of target"
    echo "are identical to baseline."
}

if [ $asking_for_help = true ]; then
    display_help
    exit 0
fi

## END TEMPLATE

if [ $# -ne 3 ]; then
    abort "Wrong number of arguments!"
fi

BASELINE="$1"
NEW="$2"
TARGET="$3"

if [ ! -f "$BASELINE" ]; then
    abort "$BASELINE does not exist!"
fi
if [ ! -f "$NEW" ]; then
    abort "$NEW does not exist!"
fi
if [ ! -f "$TARGET" ]; then
    abort "$TARGET does not exist!"
fi

if ! (diff -q "$BASELINE" "$TARGET"); then
    abort "Target doesn't match baseline!"
fi

cp "$NEW" "$TARGET"
