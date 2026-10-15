#!/bin/sh
# Print the ADR template to use.
# Usage: template.sh <plugin-data-directory> <template-name>
# A template.md you keep in the plugin's data directory wins, because that
# directory survives plugin updates. Otherwise use the bundled template.
set -eu

data_dir="${1:-}"
name="${2:-}"
templates="$(dirname "$0")/../templates"

if [ -n "$data_dir" ] && [ -f "$data_dir/template.md" ]; then
  cat "$data_dir/template.md"
elif [ "$name" = madr ]; then
  cat "$templates/madr.md"
else
  cat "$templates/nygard.md"
fi
