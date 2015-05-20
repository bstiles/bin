#!/bin/bash
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

display_help() {
cat <<EOF
usage: $(basename "$0") [opts]

-h|--help        Displays usage information.

Offers several commands that roduce output for TextBar.
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
[[ $# -eq 0 || ${1-} == @(--help|-h) ]] && { display_help; exit 0; }

VMRUN="/Applications/VMware Fusion.app/Contents/Library/vmrun"

case $1 in
    vms)
        vbox=$(VBoxManage list runningvms)
        vbox_count=$(sed -ne '/./ p' <<< "$vbox" | wc -l)
        vmware=$("$VMRUN" list)
        vmware_count=$(sed -En \
                           -e 's/Total running VMs: //' \
                           -e '/^[0-9]+$/ p' \
                           <<< "$vmware")
        (( vbox_count > 0 )) && echo -n VB:$vbox_count
        (( vbox_count > 0 && vmware_count > 0 )) && echo -n ", "
        (( vmware_count > 0 )) && echo -n "VMW: $vmware_count"
        if (( vbox_count > 0 || vmware_count > 0 )); then
            echo
        else
            echo -e "No VMs"
        fi
        (( vbox_count > 0 )) && {
            echo -e "-- VirtualBox"
            sed -Ee 's/"((.*)_default_[0-9].*"|(.*)").*/\2\3/' <<< "$vbox"
        }
        (( vmware_count > 0 )) && {
            echo -e "-- VMWare"
            sed -E \
                -e '/Total running VMs: / d' \
                -e 's_(.*VMWare/(.*).vmwarevm.*|.*/([^/]+).vmx$)_\2\3_' \
                <<< "$vmware"
        }
        ;;
    git)
        git_count=$(cd /Users/bstiles/iRise/Projects/bnw; git status -s | wc -l)
        echo -n 'BNW: '
        if (( git_count > 0 )); then
            echo $git_count
        else
            echo •
        fi
        ;;
    *)
        abort $ERR_BAD_CMD_LINE "Invalid option: $1"
esac
