#!/bin/bash
. "$(dirname "$0")"/init.sh

export JAVA_HOME=$(java5home.sh)
exec ${JAVA_HOME}/bin/java "$@"
