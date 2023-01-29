#!/usr/bin/env bash

set -o errexit -o pipefail -o nounset
shopt -s extglob nullglob
unset CDPATH

declare -ir ERR_GENERAL=1
declare -ir ERR_BAD_CMD_LINE=113
declare -ir ERR_PRECONDITION_VIOLATED=112
declare -ir ERR_MAX_LINK_DEPTH_EXCEEDED=111
declare -ir ERR_CMD_NOT_FOUND=110
declare -ir ERR_NON_EXISTENT_DIR=109
declare -ir ERR_FILE_NOT_FOUND=108
# Use 64-100 for other exit codes.

declare -r here=$(cd -- "${BASH_SOURCE[0]%/*}" && pwd)

display_help() {
cat <<EOF
usage: ${0##*/} [opts]

-h|--help        Display usage information

Back up timecards from the Tim application.
EOF
}
abort() {
    local -i err_code=${1:?abort called without err_code}
    (( err_code == ERR_BAD_CMD_LINE )) && {
        display_help; echo; echo "-- ABORTED:"
    }
    shift; (( $# > 0 )) && echo "$*" >&2
    exit $err_code
}

commit() {
    git add .
    if [[ ! $(git status --porcelain) =~ ^$ ]]; then
        git commit --quiet -m "$(date)"
    fi
}

main() {
    local message

    cd "/Users/$USER/Stiles Technologies/Time Cards"
    osascript -e 'tell Application "Tim" to export' \
              > tim.json
    if ! commit ; then
        osascript -e 'display notification "Failed to commit!" with title "Time card backup"' > /dev/null
        osascript -e 'display alert "Failed to commit time card backup!"' > /dev/null
    fi
}

# Handle help
[[ ${1-} == @(--help|-h) ]] && { display_help; exit 0; }
main "$@"
