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
declare -ir ERR_FILE_NOT_FOUND=108
# Use 64-100 for other exit codes.

declare -r here=$(cd -- "${BASH_SOURCE[0]%/*}" && pwd)

display_help() {
cat <<EOF
usage: ${0##*/} [opts]

-h|--help        Display usage information.

DESCRIPTION                                        << EDIT DESCRIPTION
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

main() {
                                                :; exit 101 # USE OR DELETE OPT PARSING
    while (( $# > 0 )); do
        case $1 in
                                                :; exit 101 # REPLACE
            -X|--XxXxXxXxXxXx)
                xxxxxxxxxxxx=${2:?--XxXxXxXxXxXx requires an argument}
                shift
                ;;
            *)
                                                :; exit 101 # ASSUMES OPTS ONLY
                abort $ERR_BAD_CMD_LINE "Invalid option: $1"
        esac
        shift
    done

                                                :; exit 101 # IF OPT IS REQUIRED
    : ${xxxxxxxxxxxx:?}
}

 # Handle help
[[ ${1-} == @(--help|-h) ]] && { display_help; exit 0; }
[[ $# < 1 || ${1-} == @(--help|-h) ]] && { display_help; exit 0; }
main "$@"
