#!/bin/bash

function usage {
    echo "usage: $(basename "$0") [-d output_dir] file [file...]"
    exit 1
}

output_dir=.

if [ -n "$1" -a "$1" = "-d" ]; then
    shift
    if [ $# -eq 0 ]; then
        usage
    elif [ -d "$1" ]; then
        output_dir="$1"
        shift
    else
        echo "$1 does not exist!"
        usage
    fi
fi

if [ $# -eq 0 ]; then
    usage
fi

for x in "$@"; do
    name="$(basename "${x%.pdf}")"
    if [ -n "$(file "$x" | grep "PDF document")" ]; then
        texexec --pages=odd --pdfcopy --result="$name (odd)" $x > /dev/null
        texexec --pages=even --pdfcopy --result="$name (even)" $x > /dev/null
        echo "Split $x"
    else
        echo "!! $x is not a PDF"
    fi
done
