#!/bin/bash
. "$(dirname "$0")"/init.sh

base="/Users/bstiles/Development/Projects"
if [ $1. != . ]; then
    base="$1"
fi

declare -a all_dirs
for x in \
"Kinesis/src" \
"Kinesis Administrator/src" \
"Kinesis Application/src" \
"Kinesis Application Metadata/src" \
"Kinesis Bootstrap/src" \
"Kinesis Cache/src" \
"Kinesis Client/src" \
"Kinesis Client/alternates" \
"Kinesis Common/src" \
"Kinesis Data/src" \
"Kinesis Feed/src" \
"Kinesis JAAS/src" \
"Kinesis Metamodel/src" \
"Kinesis Persistence//src" \
"Kinesis Repository/src" \
"Kinesis Rules/src" \
"Kinesis Rules Engine/src" \
"Kinesis Shared Configuration" \
"Kinesis UI Model/src" \
"Kinesis Web/src" \
"Kinesis Web Common/src" \
"Kinesis Wire/src" \
; do
    if [ ! -d "$base/$x" ]; then
        echo "$base/$x doesn't exist"
    else
        if [ ! -L "$(dirname "$base/$x")" ]; then
            all_dirs[${#all_dirs[@]}]="$base/$x"
        else
            echo "Skipping link: $base/$x"
        fi
    fi
done
echo "Java source lines:"
find "${all_dirs[@]}" -type f -name \*.java -exec cat {} \; | grep -v '^[[:space:]]*\(/\*\*\|\*\|#\|}[[:space:]]*$\|[[:space:]]*$\)' | wc
echo "Java files:"
find "${all_dirs[@]}" -type f -name \*.java | wc

echo "Java test lines:"
find "$base/Kinesis Tests/" "$base/Kinesis GWT Tests/" -type f -name \*.java -exec cat {} \; | grep -v '^[[:space:]]*\(/\*\*\|\*\|#\|}[[:space:]]*$\|[[:space:]]*$\)' | wc
echo "Java test files:"
find "$base/Kinesis Tests/" "$base/Kinesis GWT Tests/" -type f -name \*.java | wc

echo "Javascript source lines:"
find "$base/Kinesis/webapp/Kinesis.war/javascript" \( -path "*/javascript/ext" -o -path "*/javascript/UNUSED" \) -prune -o -type f -name \*.js -exec cat {} \; | grep -v '^[[:space:]]*\(/\*\*\|\*\|#\|}[[:space:]]*$\|[[:space:]]*$\)' | wc
echo "Javascript files:"
find "$base/Kinesis/webapp/Kinesis.war/javascript" \( -path "*/javascript/ext" -o -path "*/javascript/UNUSED" \) -prune -o -type f -name \*.js | wc
