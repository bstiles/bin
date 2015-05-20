#!/bin/bash
. "$(dirname "$0")"/init.sh

function usage() {
    echo "$(basename "$0"): [-d] [-n 'app name'] process_regex"
}

debugging=
while [ "$1" ]; do
    case "$1" in
        -d)
            debugging=true
            ;;
        -n)
            shift
            app_name="$1"
            ;;
        *)
            app_regex="$1"
            ;;
    esac
    shift
done

if [ "$app_regex." == "." ]; then
    usage
    exit 0
fi


function debug() {
    if [ "$debugging." == "true." ]; then
        echo "$1"
    fi
}

function log() {
    if [ -t 0 ]; then
        echo "$1"
    fi
}

if [ "$app_name." == "." ]; then
    app_name="$app_regex"
fi
bin_dir="$(dirname "$0")"
app_pid=$(ps -xwww | grep "$app_regex" | grep -v "grep\|bash" | awk '{ print $1 }')
growl="$bin_dir/growlnotify -t $app_name Alarm"

if [ -z $app_pid ]; then
    echo "No PID"
fi

last_port_count=0
while true
do
    port_count=$("$bin_dir/MachPortDump" $app_pid | wc | awk '{ print $1 }')
    if [ $last_port_count -eq 0 ]; then
        last_port_count=$port_count
    fi
    if [ $last_port_count -gt 0 -a $(( ($port_count - $last_port_count) ** 2 )) -gt 25 ]; then
        $growl -m " $(($port_count - $last_port_count)) / $port_count"
        last_port_count=$port_count
    fi
    sleep 5
done
