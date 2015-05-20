#!/bin/bash
shopt -s extglob
# set -o errexit

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function abort {
    [ $# -gt 0 ] && echo "$*"
    exit 1
}

function display_help {
    echo "usage: $(basename "$0") [--short] [--activity-only] [--status-only]"
    echo "           [--since spec]"
    echo "  --short            Only print affected dir names."
    echo "  --activity-only    Only pay attention to commit activity."
    echo "  --status-only      Only pay attention to status."
    echo "  --since spec       Show activity since SPEC."
    echo
    echo "Reports on Git projects that have outstanding changes and/or"
    echo "commit activity by me in the last month."
}

function abort_and_display_help {
    display_help
    echo
    abort "$@"
}

asking_for_help=false
case "$1" in
    --help|-h)
        asking_for_help=true
        ;;
esac
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

short="false"
activity_only="false"
status_only="false"
since="one month ago"

while [ $# -gt 0 ]; do
    case "$1" in
        --short)
            short="true"
            shift
            ;;
        --activity-only)
            activity_only="true"
            shift
            ;;
        --status-only)
            status_only="true"
            shift
            ;;
        --since)
            since="$2"
            shift
            shift
            ;;
        *)
            abort_and_display_help "Unknown option: $1!"
    esac
done

[ "$activity_only" = "true" -a "$status_only" = "true" ] \
  && abort_and_display_help "--activity-only and --status-only are mutually exclusive!"

set -o nounset

echo "Data good as of $(stat -f "%Sm" /var/db/locate.database)"
locate .git | grep '[.]git$' | while read x
do
    if [ ! -e "$x" ]; then
        continue
    fi
    dir=$(dirname "$x")
    pushd "$dir" > /dev/null
    if git log --format='%an' -1000 --all | grep -i -q stiles; then
        status="$([ "$activity_only" = "false" ] && git status)"
        echo "$status" | grep -q "nothing to commit, working directory clean"
        nothing_uncommitted="$([ $? -eq 0 -o "$activity_only" = "true" ] && echo "true" || echo "false")"
        log=$([ "$status_only" = "false" ] && git l --since="$since" --all)
        echo "$log" | grep -q -i "stiles"
        no_log_entries="$([ $? -eq 1 -o "$status_only" = "true" ] && echo "true" || echo "false")"

        if ! [ "$nothing_uncommitted" = "true" -a "$no_log_entries" = "true" ]; then
            if [ "$short" = "true" ]; then
                if [ "$activity_only" = "false" ]; then
                    echo -n "$([ "$nothing_uncommitted" = "false" ] && echo "* " || echo "  ")"
                fi
                echo "$dir"
            else
                echo -en "\033[37m"
                echo " ________________________________________________________________________"
                echo "/ Git activity IN: $dir"
                echo -e "|\033[0m"

                if [ "$nothing_uncommitted" = "false" -a "$activity_only" = "false" ]; then
                    git status
                fi
                if [ "$no_log_entries" = "false" -a "$status_only" = "false" ]; then
                    echo "$log" | grep -i stiles | grep -v "Merge pull request"
                fi
            fi

        fi
    fi
    popd > /dev/null
done
