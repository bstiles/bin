#!/bin/bash
shopt -s extglob
set -o errexit
set -o nounset
unset CDPATH

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

function abort {
    [ $# -gt 0 ] && echo "$*"
    exit 1
}

function display_help {
cat <<EOF
usage: $(basename "$0") [opts] [FILENAME]

-s|--seed         Seed (or prefix) value to combine with the generated
                  random characters. A value of '-' causes the seed
                  value to be read from stdin up to and exclusive of
                  the first end of line.
-c|--console      Print the password to the console.
-r|--recipient ID Encrypt for recipient id ID. Defaults to the current
                  user as reported by '$(id -un)'. You may have to add
                  that name as a comment to your key. (See GnuPG's
                  -r|--recipient option for more information.)
-R|--hidden-recipient ID
                  Encrypt for recipient id ID, but hide the key of this
                  user's key. This will make it impossible to determine
                  which key to use to decrypt, and so management of the
                  key ID must be handled separately. (See GnuPG's
                  -R|--hidden-recipient option for more information.
                  Use gpg2 --try-secret-key ID ... to decrypt.)
-f|--overwrite    Overwrite FILENAME if it exists.
-l|--length LEN   Length of the password. The length is the sum of
                  the length of the seed plus random characters. The
                  default is 128 characters. NOTE: because the random
                  characters are Base64-encoded bytes, the password
                  length must be 4/3 the length of the underlying
                  bytes to capture the same entropy.
-n|--batch        Never prompt. Used for non-interactive batch scripts.
-b|--blocking     Use /dev/random instead of /dev/urandom to produce
                  random characters. On non-FreeBSD-based operating
                  systems, /dev/random may block while the systems
                  gathers enough entropy to produce true
                  cryptographically random bytes. This can take
                  minutes for a long password.  FreeBSD-based OSes
                  (including OS X and iOS) use a high-quality
                  pseudo-random number generator for /dev/urandom and
                  /dev/random, so this option will have no effect on
                  those OSes. /dev/random is theoretically a better
                  source of randomness on some OS implementations, but
                  it is debatable whether that difference has
                  pracitical implications in most cases.

Generates a high-quality random password and writes it encrypted with
GnuPG to a file. Alternatively, the password can be written unencrypted
to stdout.
EOF
}

function abort_and_display_help {
    display_help && echo
    echo "-- ABORTED:"
    abort "$@"
}

[[ ${1-} = @(--help|-h) ]] && display_help && exit 1

random=/dev/urandom
length=128
recipient=$(id -un)
recipient_opt=-r
while [ $# -gt 0 ]; do
    [[ ${file:-} ]] && abort_and_display_help "FILENAME should be the last argument."
    case $1 in
        -b|--blocking)
            random=/dev/random
            ;;
        -c|--console)
            console=true
            ;;
        -f|--overwrite)
            overwrite=true
            ;;
        -n|--batch)
            batch=true
            ;;
        -r|--recipient)
            recipient=$2
            shift
            ;;
        -R|--hidden-recipient)
            recipient_opt=-R
            recipient=$2
            shift
            ;;
        -l|--length)
            length=$2
            shift
            ;;
        -s|--seed)
            seed=$2
            shift
            ;;
        -*)
            abort_and_display_help "Invalid option: $1"
            ;;
        *)
            file=$1
    esac
    shift
done

[[ ! ${file:-} && ! ${console:-} ]] && abort_and_display_help "FILENAME not specified."
[[ ${file:-} && ${console:-} ]] \
    && abort_and_display_help "No FILENAME should be specified when using -c|--console."

[[ ${seed:-} = - ]] && {
    [[ -t 0 && ${batch:-} = true ]] \
        && abort "--seed - and --batch are incompatible when stdin is a terminal."
    if [[ -t 0 ]]; then
        read -s -r -p "Enter a seed value: " seed < /dev/tty
        echo
    else
        read -r seed
    fi
}

[[ ${batch:-} != true && ${file:-} && ${file%.gpg} = $file ]] && {
    read -r -p "Password file names should end with .gpg. Should I add that? (y/N) " \
         < /dev/tty
    [[ $REPLY =~ ^[yY][eE]?[sS]?$ ]] && file="$file.gpg"
}

[[ ${file:-} && -e ${file:-} ]] && {
    if [[ ${overwrite:-} != true ]]; then
        abort "File exists: $file"
    else
        rm "$file"
    fi
}

function generate {
    [[ ${seed:-} ]] && builtin printf '%s' "$seed"
    cat -u $random | base64 | tr -d $'\r'$'\n'
}

password=$(generate | head -c $length)
if [[ ${console:-} = true ]]; then
    builtin printf '%s' "$password"
else
    umask 0377
    builtin printf '%s' "$password" | gpg2 -e $recipient_opt "$recipient" -o "$file"
fi
