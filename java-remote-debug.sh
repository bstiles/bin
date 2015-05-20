#!/bin/bash
shopt -s extglob

function abort {
    if [ -n "$1" ]; then
        echo "$1"
    fi
    exit 1
}

asking_for_help=false
case "$1" in
    --help|-h)
        asking_for_help=true
        ;;
esac

here="$(cd "$(dirname "$0")";pwd)"

function display_help {
    echo "usage: $(basename "$0") port [JAVA_ARGS]"
    echo "  port          port for the debugger to connect to"
    echo "  JAVA_ARGS     args passed to java"
}

if [ $asking_for_help = true ]; then
    display_help
    exit 0
fi

## END TEMPLATE

if [ $# -lt 1 ]; then
    display_help
    exit 1
fi

PORT=$1
shift

exec java -Xdebug -Xrunjdwp:transport=dt_socket,address=${PORT},server=y,suspend=n "$@"
