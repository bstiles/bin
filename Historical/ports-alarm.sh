#!/bin/bash
. "$(dirname "$0")"/init.sh

function usage() {
    echo "$(basename "$0"): [-d] [-c max_port_count] [-n 'app name'] process_regex"
}

debugging=
while [ "$1" ]; do
    case "$1" in
        -d)
            debugging=true
            ;;
        -c)
            shift
            [ $1 -ge 0 ]
            if [ $? -ne 0 ]; then
                usage
                exit 1
            fi
            max_ports=$1
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
if [ "$max_ports." == "." ]; then
    max_ports=1600
fi
bin_dir="$(dirname "$0")"
pid_file="$bin_dir/var/run/${app_regex//\//_}.pid"
app_pid=$(ps -xwww | grep "$app_regex" | grep -v "grep\|bash" | awk '{ print $1 }')
growl="$bin_dir/growlnotify -s -t $app_name Alarm"

debug "max_ports=$max_ports"
debug "bin_dir=$bin_dir"
debug "pid_file=$pid_file"
debug "app_pid=$app_pid"
debug "app_regex=$app_regex"
debug "app_name=$app_name"

if [ -z "$app_pid" ]; then
    log "$app_name PID not determined."
    exit 0
fi

port_count=$("$bin_dir/MachPortDump" $app_pid | wc | awk '{ print $1 }')
debug "port_count=$port_count"
log $port_count
if [ $port_count == 0 ]; then
    debug "Couldn't get port count"
    $growl -m "Couldn't get port count"
    exit 0
fi
if [ -f "$pid_file" ]; then
    debug "$pid_file exists"
    if [ "$(< "$pid_file")" != "$app_pid" ]; then
        debug "Removing stale $pid_file"
        rm "$pid_file"
    elif [ $port_count -lt $max_ports ]; then
        $growl <<EOF
Cancel ports alarm: $port_count
$(date '+% %m/%d %H:%m')
EOF
        rm "$pid_file"
    fi
fi
if [ $port_count -gt $max_ports -a ! -f "$pid_file" ]; then
    debug "Port count exceeded"
    $growl <<EOF
Too many ports: $port_count
$(date '+% %m/%d %H:%m')
EOF
    echo -n $app_pid > "$pid_file"
    debug "Wrote to $pid_file"
fi
exit 0
