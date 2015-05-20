#!/bin/bash
shopt -s extglob
set -o errexit
set -o nounset
unset CDPATH

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

function abort {
    [ $# -gt 0 ] && echo "$*"
    exit 1
}

function display_help {
cat <<EOF
usage: $(basename "$0") KEYGRIP

Retrieve the passphrase associated with KEYGRIP from the gpg-agent if
cached.
EOF
}

function abort_and_display_help {
    display_help && echo
    echo "-- ABORTED:"
    abort "$@"
}

[[ ${1-} = @(--help|-h) ]] && display_help && exit 1

while [ $# -gt 0 ]; do
    case $1 in
        *)
            keygrip=$1
    esac
    shift
done

cmd="GET_PASSPHRASE --no-ask --data ${keygrip:-} error prompt description"
response=$(builtin echo "$cmd" | gpg-connect-agent)
[[ $response =~ ^ERR ]] && abort "$response"
password=$(builtin echo "$response" | sed -n -e 's/D \(.*\)/\1/p')
builtin printf '%s' "$password"
