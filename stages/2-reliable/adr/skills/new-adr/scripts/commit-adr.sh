#!/bin/sh
# Commit ADR files on whatever branch their directory has checked out, which
# for a new ADR is the branch new-worktree.sh made. Prints the new commit.
# Usage: commit-adr.sh <message> <file>...
# Outside a git repository it commits nothing.
set -eu

if [ "$#" -lt 2 ]; then
  echo "Usage: commit-adr.sh <message> <file>..." >&2
  exit 1
fi
message=$1
shift
dir=$(dirname "$1")

if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not in a git repository. Nothing committed."
  exit 0
fi

git -C "$dir" add -- "$@"
git -C "$dir" commit -q -m "$message" -- "$@"
git -C "$dir" log --oneline -1
