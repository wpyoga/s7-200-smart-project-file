#!/bin/sh

HEX=$(xxd -p -c0)

echo -n -e 'SH3\0'
echo -n 'R02.04.00.00'
head -c 92 /dev/zero
printf "%08x" $(echo -n $HEX | xxd -r -p | wc -c) | sed -e 's,\(..\),\1\n,g' | tac | xxd -r -p
echo -n $HEX | xxd -r -p | zlib-flate -compress

