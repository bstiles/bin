#!/bin/bash
shopt -s extglob

function abort {
    if [ -n "$1" ]; then
        echo "$1"
    fi
    exit 1
}

here="$(cd "$(dirname "$0")";pwd)"

## END TEMPLATE

for x in "$@"; do
    convert "$x" \( -thumbnail 80 -matte -virtual-pixel transparent -channel A -blur 0x2 -level 0,50% +channel \) -flatten -quality 80% -interlace line -strip "${x/%.*/}_tiny.jpg"
    convert "$x" \( \( -resize 320 -filter Lanczos \) -matte -virtual-pixel transparent -channel A -blur 0x8 -level 0,50% +channel \) -flatten -quality 80% -interlace line -strip "${x/%.*/}_small.jpg"
    convert "$x" \( \( -resize 640 -filter Lanczos \) -matte -virtual-pixel transparent -channel A -blur 0x8 -level 0,50% +channel \) -flatten -quality 90% -interlace line -strip "${x/%.*/}_full.jpg"
    convert "$x" \( \( -resize 640 -filter Lanczos \) -matte -virtual-pixel transparent -channel A -blur 0x8 -level 0,50% +channel \) -gravity center -extent 640x480 -flatten -quality 90% -interlace line -strip "${x/%.*/}_full_filled.jpg"
done
