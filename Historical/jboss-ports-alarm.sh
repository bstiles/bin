#!/bin/bash
. "$(dirname "$0")"/init.sh

exec "$(dirname "$0")/ports-alarm.sh" "$@" -n "JBoss" "org.jboss.Main"
