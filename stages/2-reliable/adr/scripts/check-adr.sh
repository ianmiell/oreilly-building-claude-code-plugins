#!/bin/sh
# PostToolUse hook for Write and Edit: check an ADR that Claude just wrote.
# Exit 0 if the file isn't an ADR or the ADR is fine. Exit 2 with a message on
# stderr if something is wrong: Claude sees the message and can fix the file.
set -eu

dir="${CLAUDE_PLUGIN_OPTION_ADR_DIR:-docs/adr}"
adr_dir="${CLAUDE_PROJECT_DIR:-$PWD}/$dir"

# The hook's input is JSON on stdin. Take the first "file_path" value, which is
# the file the tool wrote. It's always an absolute path.
file=$(grep -o '"file_path" *: *"[^"]*"' | head -n 1 | sed 's/.*"\([^"]*\)"$/\1/') || true
name=$(basename "${file:-none}")

# Only look at NNNN-*.md files directly inside the ADR directory.
[ "$(dirname "${file:-none}")" = "$adr_dir" ] || exit 0
case "$name" in [0-9][0-9][0-9][0-9]-*.md) ;; *) exit 0 ;; esac
[ -f "$file" ] || exit 0

problems=""
number=$(echo "$name" | cut -c1-4)
for other in "$adr_dir/$number"-*.md; do
  [ "$other" = "$file" ] || [ ! -e "$other" ] ||
    problems="$problems
- ADR number $number is already used by $(basename "$other"). Rename this file to the next free number."
done
grep -q -E '^## Status|^status:' "$file" ||
  problems="$problems
- There is no status. Add a '## Status' section, or a 'status:' field in front matter."
grep -q -E '^Date: |^date: ' "$file" ||
  problems="$problems
- There is no date. Add a 'Date: YYYY-MM-DD' line, or a 'date:' field in front matter."

[ -z "$problems" ] && exit 0
echo "$name is not a valid ADR:$problems" >&2
exit 2
