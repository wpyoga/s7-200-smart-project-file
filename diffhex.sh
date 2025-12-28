#!/bin/sh

SKIP1=0
case "$3" in [0-9]*) SKIP1="$3";; esac

SKIP2=0
case "$4" in [0-9]*) SKIP2="$4";; esac

cmp -l <(tail -c +$(($SKIP1+1)) s$1) <(tail -c +$(($SKIP2+1)) s$2) \
  | while read a b c; do
      printf "%08x: %02x %02x\n" $(($a-1)) $((8#$b)) $((8#$c))
    done \
  | less

