#!/bin/bash
. "$(dirname "$0")"/init.sh

exec "$(dirname "$0")/ports-alarm.sh" "$@" -c 1800 -n "Eclipse" "/Applications/eclipse/"
