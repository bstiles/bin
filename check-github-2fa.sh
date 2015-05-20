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
usage: $(basename "$0") [-h|--help]

List iRise GitHub users for whom two-factor authentication is not
enabled.
EOF
}

function abort_and_display_help {
    display_help && echo
    echo "-- ABORTED:"
    abort "$@"
}

[[ ${1-} = @(--help|-h) ]] && display_help && exit 1

token_file=~/.keys/GitHub/github_token_brianatirise_read
curl 'https://api.github.com/orgs/irise/members?filter=2fa_disabled' \
     -K - <<EOF
header="Authorization: token $(cat $token_file | tr -d $'\n')"
EOF
