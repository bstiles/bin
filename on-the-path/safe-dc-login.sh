#!/bin/bash
shopt -s extglob
set -o errexit
set -o nounset

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

function abort {
    [ $# -gt 0 ] && echo "$*"
    exit 1
}

function display_help {
cat <<EOF
usage: $(basename "$0") [--non-tls] [--trace] user@host:port
--non-tls      Use HTTP instead of HTTPS.
--trace        Trace the CURL command to standard output.

Returns an oauth token after prompting for a password.
EOF
}

function abort_and_display_help {
    display_help && echo
    abort "$@"
}

[ $# -eq 0 ] || [[ ${1-} = @(--help|-h) ]] && display_help && exit 0

client_id=${client_id-"eef3485f-52b8-41b3-9d05-b051a9d5a2b0%3A*"}
protocol=https
while [ $# -gt 0 ]; do
    case $1 in
        --non-tls)
            protocol=http
            shift
            ;;
        --trace)
            trace=(--trace-ascii -)
            shift
            ;;
        *@*:*)
            url=$1
            shift
            ;;
        *)
            abort_and_display_help "Invalid arg: $1"
    esac
done

a=($(builtin echo $url | sed -e 's/\(.*\)@\(.*\):\(.*\)/\1 \2 \3/'))

[ ${#a[@]} -eq 3 ] || abort_and_display_help "Malformed URL."
user=${a[0]}
host=${a[1]}
port=${a[2]}

function pass {
    local PASS
    read -sp "Password: " PASS > /dev/tty
    builtin echo "password=$PASS"
}

response=$(curl ${trace-} -X POST \
                -sq \
                --data "type=username" \
                --data "client_id=${client_id}" \
                --data "username=${user}" \
                --data @- \
                -w "%{http_code}" \
                "$protocol://$host:$port/iRise/oauth/authorize" \
                < <(pass))
builtin echo > /dev/tty

if grep -q '200$' <<< "$response"; then
    builtin echo "$response" | sed -e 's/.*"access_token": "\(.*\)".*/\1/'
else
    builtin echo "Error logging in."
    exit 1
fi
