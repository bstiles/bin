#!/bin/bash
shopt -s extglob
set -o errexit

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function abort {
    [ $# -gt 0 ] && echo "$*"
    exit 1
}

function display_help {
cat <<EOF
usage: $(basename "$0") host port [local-port]
  host        Remote host to create a tunnel to.
  port        Port on the remote host to tunnel. Used locally as well.
  local-port  Optionally use a different port locally.
EOF
}

function abort_and_display_help {
    display_help && echo
    abort "$@"
}

[[ "$1" = @(--help|-h) ]] && display_help && exit 0

[ $# -lt 2 -o $# -gt 3 ] \
  && abort_and_display_help "Wrong number of args!"

HOST=$1
PORT=$2
LOCAL_PORT=$PORT
[ -n "$3" ] && LOCAL_PORT=$3

set -o nounset

~/bin/notify-result ssh -N -L $LOCAL_PORT:localhost:$PORT $HOST
