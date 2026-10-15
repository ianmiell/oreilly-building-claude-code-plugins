#!/bin/sh
# SessionStart hook: tell Claude which decisions are already accepted.
# Whatever this prints is added to Claude's context. It prints nothing if the
# project has no ADRs.
set -eu

dir="${CLAUDE_PLUGIN_OPTION_ADR_DIR:-docs/adr}"
cd "${CLAUDE_PROJECT_DIR:-.}"
[ -d "$dir" ] || exit 0

accepted=$(for f in "$dir"/[0-9][0-9][0-9][0-9]-*.md; do
    [ -e "$f" ] || continue
    # The status is the first line after "## Status" (Nygard) or the
    # "status:" field in front matter (MADR). The title is the first "# " line.
    awk -v num="$(basename "$f" | cut -c1-4)" '
      /^status:/ && !status { status = $0; sub(/^status: *"?/, "", status) }
      after_heading && NF && !status { status = $0 }
      /^## Status/ { after_heading = 1 }
      /^# / && !title { title = $0; sub(/^# ([0-9]+\. )?/, "", title) }
      END { if (tolower(status) ~ /^accepted/) print "- " num " " title }
    ' "$f"
  done)

[ -n "$accepted" ] || exit 0
cat <<EOF
This project records architecture decisions in $dir/. These are accepted:
$accepted
Check new technical choices against them. Use the adr plugin's skills to record a new decision or supersede one.
EOF
