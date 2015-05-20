#!/bin/bash
shopt -s extglob

function abort {
    if [ -n "$1" ]; then
        echo "$1"
    fi
    exit 1
}

asking_for_help=false
case "$1" in
    --help|-h)
        asking_for_help=true
        ;;
esac

here="$(cd "$(dirname "$0")";pwd)"

## END TEMPLATE

function usage {
    echo "usage: $(basename "$0") left-x right-x squeeze-top-or-bottom file [file...]"
    echo "           left-x: x coordinate to squeeze the left edge toward"
    echo "           right-x: x coordinate to squeeze the right edge toward"
    echo "           squeeze-top-or-bottom: either 'top' or 'bottom' to determine"
    echo "               whether the top or bottom gets squeezed"
}


if [ $asking_for_help = true -o $# -lt 4 ]; then
    usage
    exit 0
fi

left=$1
shift
right=$1
shift
edge=$1
shift

for x in "$@"; do
    echo "Undistorting $x"
    width=$(convert "$x" info: | awk '{ print $3; }' | awk -F x '{ print $1; }')
    height=$(convert "$x" info: | awk '{ print $3; }' | awk -F x '{ print $2; }')
    if [ $edge = top ]; then
        distort_param="0,0 $left,0  $left,$height $left,$height  $right,$height $right,$height  $width,0 $right,0"
    elif [ $edge = bottom ]; then
        distort_param="$left,0 $left,0  0,$height $left,$height  $width,$height $right,$height  $right,0 $right,0"
    else
        usage
        exit 1
    fi
    convert "$x" -virtual-pixel black \
        -distort Barrel "0.0 0.0 -0.045 1.045" \
        -distort Perspective "$distort_param" \
        "${x/%.*/}_undistorted.jpg"
done
