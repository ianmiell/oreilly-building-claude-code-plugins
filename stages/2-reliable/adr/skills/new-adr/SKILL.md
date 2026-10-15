---
name: new-adr
description: Record an architecture decision as a new Architecture Decision Record (ADR). Use when the user has made, or wants to write down, a technical or architectural decision, for example "write an ADR", "record this decision", "document why we chose X", or "we've decided to use Y, write that down". Do not use when the user only asks what an ADR is.
allowed-tools:
  - Bash(${CLAUDE_SKILL_DIR}/scripts/next-adr.sh *)
  - Bash(${CLAUDE_SKILL_DIR}/scripts/template.sh *)
---

# New ADR

Write one new Architecture Decision Record for the decision the user describes.

## Steps

1. **Gather the facts.** You need: the decision, the context (the problem or force behind it),
   the alternatives that were considered, and the consequences. Take them from the conversation.
   If the decision or the reason for it is missing, ask for everything missing in one question.
   Do not invent alternatives or reasons the user did not give; leave a section short instead.
2. **Get the directory and number.** Run this from the project root:

   ```sh
   ${CLAUDE_SKILL_DIR}/scripts/next-adr.sh '${user_config.adr_dir}'
   ```

   It prints the directory and the new number, for example `docs/adr/0003`. Use exactly what it
   prints. Do not work the number out yourself.
3. **Name the file.** Add `-short-title-in-kebab-case.md` to what the script printed, for example
   `docs/adr/0003-use-redis-for-session-caching.md`.
4. **Get the template.** Run:

   ```sh
   ${CLAUDE_SKILL_DIR}/scripts/template.sh '${CLAUDE_PLUGIN_DATA}' '${user_config.template}'
   ```

5. **Write the file** by filling in that template. Keep its headings and layout. Put the number
   where the template has `NNNN`, and use today's date. Set the status to accepted if the user says
   the decision is agreed, otherwise proposed, matching the template's capitalisation.
6. **Report back** with the file path and a one-line summary of the decision.

Never edit existing ADRs. An ADR is a record of what was decided at the time. The one exception is
marking an ADR as superseded, which the `supersede-adr` skill does.
