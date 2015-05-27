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
declare -r VMRUN="/Applications/VMware Fusion.app/Contents/Library/vmrun"
declare -rx MACHINE_STORAGE_PATH=/Users/bstiles/Machine
PATH=/usr/local/bin:$PATH

display_help() {
cat <<EOF
usage: $(basename "$0") [opts]

vms              Display information about virtual machine usage.
git              Display information about Git status.
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

case $1 in
    vms)
        vbox=$(VBoxManage list runningvms)
        vbox_count=$(sed -ne '/./ p' <<< "$vbox" | wc -l)
        vmware=$("$VMRUN" list)
        vmware_count=$(sed -En \
                           -e 's/Total running VMs: //' \
                           -e '/^[0-9]+$/ p' \
                           <<< "$vmware")
        if (( vbox_count > 0 && vmware_count > 0 )); then
            echo -n ▞
        elif (( vbox_count > 0 )); then
            echo -n ▖
        elif (( vmware_count > 0 )); then
            echo -n ▝
        else
            echo -n ⋰
        fi
        if /Users/bstiles/iRise/Projects/bnw/tools/check-docker-host; then
            echo -n '▐'
            docker_active=$(/Users/bstiles/iRise/Projects/bnw/tools/docker-host active)
        fi
        echo
        (( vbox_count > 0 )) && {
            echo "-- VirtualBox"
            sed -Ee 's/"((.*)_default_[0-9].*"|(.*)").*/\2\3/' <<< "$vbox"
        }
        (( vmware_count > 0 )) && {
            echo "-- VMWare"
            sed -E \
                -e '/Total running VMs: / d' \
                -e 's_(.*VMWare/(.*).vmwarevm.*|.*/([^/]+).vmx$)_\2\3_' \
                <<< "$vmware"
        }
        [[ ${docker_active-} ]] && {
            echo "-- Docker"
            echo $docker_active
        }
        ;;
    git)
        git_count=$(cd /Users/bstiles/iRise/Projects/bnw; git status -s | wc -l)
        if (( git_count > 0 )); then
            echo ╪
            echo "BNW: Git Status"
            echo "Out of sync"
        else
            echo ═
            echo "BNW: Git Status"
            echo "In sync"
        fi
        ;;
    build-status)
        set +o errexit
        make_status=$(cd /Users/bstiles/iRise/Projects/bnw;
                      make --dry-run 2>&1 | grep -v '^make: Nothing to be done')
        docker_not_configured="Docker host is not configured"
        if [[ -z $make_status ]]; then
            status=●
            make_message="Up to date"
        elif [[ $make_status =~ $docker_not_configured ]]; then
            status=•
            make_message="Docker not configured"
        else
            status=○
            make_message="Out of date"
        fi
        if [[ -z $(cd /Users/bstiles/iRise/Projects/bnw;
                   make no-docker --dry-run | grep -v '^make: Nothing to be done') ]]; then
            status="$status ●"
            make_no_docker_message="Up to date"
        else
            status="$status ○"
            make_no_docker_message="Out of date"
        fi
        echo "$status"
        echo "BNW: make"
        echo "-- all"
        echo "$make_message"
        echo "-- no-docker"
        echo "$make_no_docker_message"
        ;;
    textbar-ports)
        ports=$(top -l 1 | awk '/TextBar/ { print $7 }' | sed -E 's/[^0-9]//g')
        if (( ports > 1000 )); then
            echo -en "\033[41;1;37m"
        fi
        echo $ports
        ;;
    *)
        abort $ERR_BAD_CMD_LINE "Invalid option: $1"
esac
