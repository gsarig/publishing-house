#!/bin/bash
# eink-sim.sh: simulate how a color book cover renders on a grayscale e-ink reader,
# so cover colors can be checked for readability before uploading to KDP.
#
# Usage: eink-sim <cover-image> [output.png]
# Output defaults to <input>-eink.png next to the input file.
#
# Pipeline (ffmpeg; no ImageMagick needed): scale to 400px tall (library-thumbnail
# scale), BT.601 grayscale, compress into e-ink's reflective dynamic range (~30-220),
# quantize to 16 gray levels. The result is not pixel-exact for any one device but
# fails in the same way real e-ink panels do.
#
# Reading the result: text whose gray value sits within ~2 quantize steps (~35/255)
# of its background will be unreadable on the device. Aim for a gap of 90+.
# Pure red is deceptively dark in grayscale (~76/255); lift it toward coral/orange
# (adding green raises luminance fastest) rather than picking a "brighter red".

set -euo pipefail

if [ $# -lt 1 ] || [ ! -f "${1:-}" ]; then
    echo "Usage: eink-sim <cover-image> [output.png]" >&2
    exit 1
fi

in=$1
out=${2:-"${in%.*}-eink.png"}

ffmpeg -v error -y -i "$in" \
    -vf "scale=-2:400,format=gray,lut=c0='floor((30+val*190/255)/17)*17'" \
    -frames:v 1 "$out"

echo "$out"
