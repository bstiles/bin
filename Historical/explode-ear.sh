#!/bin/bash
. "$(dirname "$0")"/init.sh

if [ $# -ne 1 ]; then
    echo usage: $0 path-to-ear
    exit 1
fi

ear="$1"
if [ ! -f "${ear}" ]; then
    echo "${ear} is not a regular file or does not exist!"
    exit 1
fi
deploy_dir="$(dirname "${ear}")"
ear_dir="${deploy_dir}/$(basename "${ear}")"

mv "${ear}" "${ear}.zip"
mkdir -p "${ear_dir}"
unzip "${ear}.zip" -d "${ear_dir}"
rm "${ear}.zip"
for x in "${ear_dir}"/*.[jw]ar; do
    mv "${x}" "${x}.zip"
    mkdir "${x}"
    unzip "${x}.zip" -d "${x}"
    rm "${x}.zip"
done

