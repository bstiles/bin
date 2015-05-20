#!/bin/bash
. "$(dirname "$0")"/init.sh

tempfile="/tmp/$(basename $0).$$"
touch "$tempfile"
dd <&0 >"$tempfile"
plutil "$@" "$tempfile"
dd <"$tempfile" >&1
