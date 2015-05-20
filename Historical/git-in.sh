#!/bin/bash
shopt -s extglob
# set -o errexit

function abort {
    if [ $# -gt 0 ]; then
        echo "$*"
    fi
    exit 1
}

asking_for_help=false
case "$1" in
    --help|-h)
        asking_for_help=true
        ;;
esac

here="$(cd -L "$(dirname "$(readlink "$0" || echo "$0")")";pwd)"

function display_help {
    echo "usage: $(basename "$0") dir args..."
    echo "   or: $(basename "$0") [ dir1 dir2 ] args..."
    echo
    echo "Calls git args... in dir."
}

if [ $asking_for_help = true ]; then
    display_help
    exit 0
fi

[ $# -lt 2 ] && { display_help; abort "Too few arguments."; }

if [ "$1" = "[" ]; then
    shift
    dirs=()
    while [ "$#" -gt 0 -a "$1" != "]" ]; do
        if [ -n "${dirs}" ]; then
            dirs=("${dirs[@]}" "$1")
        else
            dirs=("$1")
        fi
        shift
    done
    [ "$1" = "]" ] || { display_help; abort "Missing ']'"; }
    shift
    [ $# -lt 1 ] && { display_help; abort "Too few arguments."; }
    for x in "${dirs[@]}"; do
        echo " _______________________________________________________________________________"
        echo "/ DO: $* IN: ${x}"
        echo "|"
        "$0" "$x" "$@"
    done
else
    dir="$1"
    shift

    [ -d "$dir" ] || abort "Invalid dir: $dir."

    cd "$dir"
    exec git "$@"
fi

