#!/bin/sh
# Monitor: report ADRs that appear in docs/adr/ during a session, for example
# when a git pull brings in a teammate's decision. Each line printed reaches
# Claude as a notification. Monitors can't read plugin options, so this
# watches the default directory.
dir=docs/adr

list() { for f in "$dir"/[0-9][0-9][0-9][0-9]-*.md; do [ -e "$f" ] && echo "$f"; done; }

seen=$(list)
while sleep 10; do
  now=$(list)
  echo "$now" | while IFS= read -r f; do
    [ -n "$f" ] || continue
    printf '%s\n' "$seen" | grep -qxF "$f" || echo "New ADR: $f"
  done
  seen=$now
done
