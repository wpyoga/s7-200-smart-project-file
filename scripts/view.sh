#!/bin/sh

SKIP=0
case "$1" in [0-9]*) SKIP="$1";; esac

COLS=0
case "$2" in [0-9]*) COLS="$2";; esac

tail -c +$(("$SKIP"+1)) | xxd -c "$COLS" -R always | less -RS

