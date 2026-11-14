#!/bin/sh
# Make a git worktree and branch for a new ADR, and print the directory and
# number to write it under, for example: /code/myrepo-adr-0003/docs/adr/0003
# Usage: new-worktree.sh <adr-directory> <short-title-in-kebab-case>
# Outside a git repository it makes no worktree and prints what next-adr.sh
# prints, so the ADR is written in place.
set -eu

here=$(dirname "$0")
dir="${1:-}"
title="${2:-}"
case "$title" in
  '' | *[!a-z0-9-]*)
    echo "Usage: new-worktree.sh <adr-directory> <short-title-in-kebab-case>" >&2
    exit 1 ;;
esac

next=$("$here/next-adr.sh" "$dir")   # for example docs/adr/0003

root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "$next"; exit 0; }
prefix=$(git rev-parse --show-prefix)  # the project's path inside the repository
number=$(basename "$next")
branch="adr/$number-$title"
tree="$(dirname "$root")/$(basename "$root")-adr-$number"

if git show-ref --verify --quiet "refs/heads/$branch"; then
  echo "Branch $branch already exists. Not reusing it." >&2
  exit 1
fi
if [ -e "$tree" ]; then
  echo "$tree already exists. Not reusing it." >&2
  exit 1
fi

git worktree add -q -b "$branch" "$tree" HEAD >&2
mkdir -p "$tree/$prefix$(dirname "$next")"
echo "$tree/$prefix$next"
