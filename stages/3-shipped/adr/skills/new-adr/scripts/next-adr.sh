#!/bin/sh
# Print the directory and number for the next ADR, for example: docs/adr/0003
# Usage: next-adr.sh <adr-directory>
set -eu

dir="${1:-}"
# An option that was never set arrives as the literal text ${user_config...}.
# shellcheck disable=SC2016
case "$dir" in '' | '${'*) dir=docs/adr ;; esac
dir="${dir%/}"

# Highest existing NNNN-*.md number plus one, zero-padded. Leading zeros are
# stripped with "+ 0" so 0009 isn't read as octal.
next=$(for f in "$dir"/[0-9][0-9][0-9][0-9]-*.md; do
    [ -e "$f" ] && basename "$f"
  done | awk '{ n = substr($0, 1, 4) + 0; if (n > max) max = n }
    END { printf "%04d", max + 1 }')

echo "$dir/$next"
