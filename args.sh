#!/bin/bash
shopt -s extglob
# set -o errexit

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function abort {
    [ $# -gt 0 ] && echo "$*"
    exit 1
}

function display_help {
    echo "usage: $(basename "$0") args..."
    echo "Display the args passed to this script."
}

function abort_and_display_help {
    display_help
    abort "$@"
}

asking_for_help=false
case "$1" in
    --help|-h)
        asking_for_help=true
        ;;
esac
[ $asking_for_help = true ] && display_help && exit 0

if [ $# -eq 0 ]; then
    echo "No args!"
else
    argnum=0
    while [ $# -gt 0 ]; do
        argnum=$(($argnum + 1))
        echo "$argnum: ==|$1|=="
        shift
    done
fi
if [ -t 0 ]; then
    echo "No stdin!"
else
    echo -n "stdin: ==|"
    cat /dev/stdin
    echo "|=="
fi

