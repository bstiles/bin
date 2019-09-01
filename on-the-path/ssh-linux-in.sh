#!/usr/bin/env bash
[ $BASH_VERSINFO -gt 3 ] || { echo "Bash 4+ is required."; exit 1; }

set -o errexit -o pipefail -o nounset
shopt -s extglob nullglob
unset CDPATH

declare -ir ERR_GENERAL=1
declare -ir ERR_BAD_CMD_LINE=113
declare -ir ERR_PRECONDITION_VIOLATED=112
declare -ir ERR_MAX_LINK_DEPTH_EXCEEDED=111
declare -ir ERR_CMD_NOT_FOUND=110
declare -ir ERR_NON_EXISTENT_DIR=109
# Use 64-100 for other exit codes.

declare -r here=$(cd -- "${BASH_SOURCE[0]%/*}" && pwd)

display_help() {
cat <<EOF
usage: ${0##*/} [opts] DIR ....

-h|--help        Displays usage information.

Run \`ssh linux ...\` in a specific DIR on \`linux\`. Absolute
paths starting with \`/Users\` are replaced with \`/home/..\`.
EOF
}
require() {
    eval [[ \$\{${1:?require was called without arguments!}-\} ]] \
         '||' abort \$ERR_BAD_CMD_LINE \$\{2-\$1 is required!\} \$\{*:3\}
}
abort() {
    local -i err_code=${1:?abort called without err_code}
    (( err_code == ERR_BAD_CMD_LINE )) && {
        display_help; echo; echo "-- ABORTED:"
    }
    shift; (( $# > 0 )) && echo "$*" >&2
    exit $err_code
}

main() {
    if [[ -d $1 ]]; then
        dir=$(cd -- "$1" && pwd | sed -e 's/^\/Users/\/home/')
    else
        dir=$(sed -e 's/^\/Users/\/home/' <<< "$1")
    fi
    shift

    ssh linux cd "'""$dir""'" \|\| exit $ERR_BAD_CMD_LINE \; "$@"
}

# Handle help
[[ $# < 1 || ${1-} == @(--help|-h) ]] && { display_help; exit 0; }
main "$@"
