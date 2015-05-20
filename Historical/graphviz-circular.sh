#!/bin/bash
. "$(dirname "$0")"/init.sh
. "$(dirname "$0")"/bashrc.macports

if [ $# -ne 1 ]; then
    echo "usage: $(basename "$0") inputfile"
    exit 0
fi

tempfile="/tmp/$(basename $0).$$"

#-Gsize=9.75,7.5 -Gratio=fill 
circo -Tps2 -o "$tempfile" "$1"
epstopdf "$tempfile" --outfile="${tempfile}.pdf"
cat "${tempfile}.pdf"

rm "${tempfile}.pdf" "${tempfile}"
