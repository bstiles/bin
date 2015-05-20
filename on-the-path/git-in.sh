#!/usr/bin/env bash
[ $BASH_VERSINFO -gt 3 ] || { echo "Bash 4+ is required."; exit 1; }

set -o errexit -o pipefail -o nounset
shopt -s extglob
unset CDPATH

declare -ir ERR_GENERAL=1
declare -ir ERR_BAD_CMD_LINE=113
declare -ir ERR_PRECONDITION_VIOLATED=112
declare -ir ERR_MAX_LINK_DEPTH_EXCEEDED=111
declare -ir ERR_CMD_NOT_FOUND=110
declare -ir ERR_NON_EXISTENT_DIR=109
# Use 64-108 for other exit codes.

declare -r here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
declare maxdepth=${maxdepth:-5}

display_help() {
cat <<EOF
usage: gin [-C dir] REPO_DIR [git-opts]
usage: gin [-C dir] [ REPO_DIR ... ] [git-opts]
usage: gr [-C dir] [git-opts]

-C DIR           Change to DIR before running the command. Must be
                 the first argument to the command.
-h|--help        Displays usage information.

Runs a Git command in one or more non-current directories.

NOTE: gr only searches a maximum depth of $maxdepth directories below
the working directory. This can be overridden by setting the
maxdepth environment variable as in 'maxdepth=10 gr ...'.
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

# Handle help
[[ $# == 0 || ${1-} == @(--help|-h) ]] && { display_help; exit 0; }

[[ ${1-} == -C ]] && {
    cd -- "${2:?-C requires an argument.}"
    shift 2
}

(( $# > 0 )) || abort $ERR_BAD_CMD_LINE "Invalid command line."

main() {
    local -a repos
    if [ "${TERM:-dumb}" != "dumb" ]; then
        if [ "$TERM" = "emacsclient" ]; then
            TERM_TYPE=-Txterm-256color
        else
            TERM_TYPE=
        fi
        local -r bold=$(tput $TERM_TYPE bold)
        local -r warn=$(tput $TERM_TYPE setaf 1)
        local -r bright=$(tput $TERM_TYPE setaf 3)
        local -r dim=$(tput $TERM_TYPE setaf 7)
        if [ "$TERM" = "emacsclient" ]; then
            local -r default="\e[0m"
        else
            local -r default="$(tput $TERM_TYPE sgr0)"
        fi
    fi

    if [[ $(basename -- "$0") = gr ]]; then
        readarray -t repos < <(find . \
                                    -maxdepth $maxdepth \
                                    -type d \
                                    -name .git \
                                    -exec dirname -- {} \;)
    elif [[ $1 == \[ ]]; then
        shift
        while [[ ${1:?']' not found.} != \] ]]; do
            repos=(${repos[@]:+"${repos[@]}"} "$1")
            shift
        done
        shift
    else
        repos=("$1")
        shift
    fi

    for x in "${repos[@]}"; do
        (
            [[ -d $x ]] || abort $ERR_NON_EXISTENT_DIR "Repository dir not found: $x"
            cd "$x"
            if (( ${#repos[@]} > 1 )); then
                echo -en "${dim-}"
                cat <<EOF
 _______________________________________________________________________________
/ IN: $(
echo -en ${bright-}; echo -n $(dirname -- "$PWD")/
echo -en ${bright-}${bold-}; echo -n $(basename -- "$PWD"); echo -en ${dim-}
)
|
EOF
                echo -en "${default-}"
            fi
            git "$@"
        ) || cat <<EOF
$(echo -en ${warn-})\
==========
FAILURE in: $(echo -en ${bright-}; echo -n $PWD; echo -en ${warn-})
==========\
$(echo -en ${default-})
EOF
    done
}

main "$@"
