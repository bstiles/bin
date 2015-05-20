#!/bin/bash
here="$(cd "$(dirname "$0")";pwd)"

asking_for_help=false
case "$1" in
    --help|-h)
        asking_for_help=true
        ;;
esac

function display_help {
    echo "usage: $(basename "$0") args..."
    echo "    --show-locations    Show the locations of the repositories to be acted on."
    echo
    echo "Calls 'git args...' in each git project here and below."
    echo
    echo "Based on:"
    echo
    "$here/do-in-git-projects" --help
}

if [ $# -eq 0 -o $asking_for_help = true ]; then
    display_help
    exit 0
fi

if [ "$1" == "--show-locations" ]; then
    exec "$here/do-in-git-projects" $no_banner pwd
fi


no_banner="--banner"
if [ "$1x" = "--no-bannerx" ]; then
    no_banner=
    shift
fi

exec "$here/do-in-git-projects" $no_banner git "$@"
