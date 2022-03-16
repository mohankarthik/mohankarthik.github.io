#!/usr/bin/env bash
cwebp -mt -q 100 -lossless $1 -o ${1%.*}.webp