#!/bin/bash
shopt -s extglob
set -o errexit
set -o nounset

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

function abort {
    [ $# -gt 0 ] && echo "$*"
    exit 1
}

function display_help {
cat <<EOF
usage: $(basename "$0")
EOF
}

function abort_and_display_help {
    display_help && echo
    echo "-- ABORTED:"
    abort "$@"
}

[[ ${1-} = @(--help|-h) ]] && display_help && exit 1

exec emacsclient -t "$@"
