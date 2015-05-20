#!/bin/bash
shopt -s extglob
# set -o errexit

function abort {
    if [ $# -gt 0 ]; then
        echo "$*"
    fi
    exit 1
}

function display_help {
    echo "usage: $(basename "$0") path-to-pom.xml"
}

function abort_and_display_help {
    display_help
    abort "$@"
}

asking_for_help=false
case "$1" in
    --help|-h)
        asking_for_help=true
        ;;
esac

here="$(cd -L "$(dirname "$(readlink "$0" || echo "$0")")";pwd)"

if [ $asking_for_help = true ]; then
    display_help
    exit 0
fi

[ -f "$1" ] || abort_and_display_help

set -o nounset

REPOSITORY_URL=file:///Users/bstiles/Development/net.bstiles.repo
REPOSITORY_ID=net.bstiles.repo

POM="$1"
POM_DIR="$(cd -L "$(dirname "$(readlink "$POM" || echo "$POM")")";pwd)"
GROUP_ID=$(xpath "$POM" '/project/groupId/text()' 2> /dev/null)
ARTIFACT_ID=$(xpath "$POM" '/project/artifactId/text()' 2> /dev/null)
VERSION=$(xpath "$POM" '/project/version/text()' 2> /dev/null)
FILE="$POM_DIR/${ARTIFACT_ID}-${VERSION}.jar"

[ -n "$GROUP_ID" -a -n "$ARTIFACT_ID" -a -n "$VERSION" ] || abort "Missing GROUP_ID ($GROUP_ID), ARTIFACT_ID ($ARTIFACT_ID), and/or VERSION ($VERSION)."

mvn\
 deploy:deploy-file\
 -DgroupId=$GROUP_ID\
 -DartifactId=$ARTIFACT_ID\
 -Dversion=$VERSION\
 -Dpackaging=jar\
 -Dfile=$FILE\
 -Durl=$REPOSITORY_URL\
 -DrepositoryId=$REPOSITORY_ID\
 -DpomFile=$POM
