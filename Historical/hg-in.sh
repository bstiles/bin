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
    echo
    echo "Calls hg args... in dir."
}

if [ $asking_for_help = true ]; then
    display_help
    exit 0
fi

set -o nounset

[ $# -lt 2 ] && { display_help; abort; }

dir="$1"
shift

[ -d "$dir" ] || abort "Invalid dir: $dir."

cd "$dir"
exec hg "$@"

