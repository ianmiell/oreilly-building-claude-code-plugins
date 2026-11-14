---
name: new-adr
description: Record an architecture decision as a new Architecture Decision Record (ADR). Use when the user has made, or wants to write down, a technical or architectural decision, for example "write an ADR", "record this decision", "document why we chose X", or "we've decided to use Y, write that down". Do not use when the user only asks what an ADR is.
allowed-tools:
  - Bash(${CLAUDE_SKILL_DIR}/scripts/next-adr.sh *)
  - Bash(${CLAUDE_SKILL_DIR}/scripts/template.sh *)
  - Bash(${CLAUDE_SKILL_DIR}/scripts/new-worktree.sh *)
  - Bash(${CLAUDE_SKILL_DIR}/scripts/commit-adr.sh *)
---

# New ADR

Write one new Architecture Decision Record for the decision the user describes.

Run each script below as a command on its own, exactly as written. Don't combine it with other
commands: `allowed-tools` lets only the scripts themselves run without a permission prompt.

## Steps

1. **Gather the facts.** You need: the decision, the context (the problem or force behind it),
   the alternatives that were considered, and the consequences. Take them from the conversation.
   If the decision or the reason for it is missing, ask for everything missing in one question.
   Do not invent alternatives or reasons the user did not give; leave a section short instead.
2. **Choose a short title** in kebab case, for example `use-redis-for-session-caching`.
3. **Make a worktree and get the directory and number.** Run this from the project root, with
   your short title in place of `SHORT-TITLE`:

   ```sh
   ${CLAUDE_SKILL_DIR}/scripts/new-worktree.sh '${user_config.adr_dir}' 'SHORT-TITLE'
   ```

   It makes a new git worktree in `.claude/worktrees/` at the root of the checkout, on a new branch
   `adr/NNNN-SHORT-TITLE`, and prints the directory and the new number inside it, for example
   `/code/myrepo/.claude/worktrees/adr-0003/docs/adr/0003`. Use exactly what it prints. Do not
   work the number out yourself, and do not write the ADR in the checkout's own ADR directory.
   Outside a git repository it makes
   no worktree and prints a path in the current project instead, for example `docs/adr/0003`. If
   it fails because the branch or directory already exists, stop and tell the user.
4. **Name the file.** Add `-SHORT-TITLE.md` to what the script printed, for example
   `/code/myrepo/.claude/worktrees/adr-0003/docs/adr/0003-use-redis-for-session-caching.md`.
5. **Get the template.** Run:

   ```sh
   ${CLAUDE_SKILL_DIR}/scripts/template.sh '${CLAUDE_PLUGIN_DATA}' '${user_config.template}'
   ```

6. **Write the file** by filling in that template. Keep its headings and layout. Put the number
   where the template has `NNNN`, and use today's date. Set the status to accepted if the user says
   the decision is agreed, otherwise proposed, matching the template's capitalisation.
7. **Commit it on the branch.** Run, with the file's full path:

   ```sh
   ${CLAUDE_SKILL_DIR}/scripts/commit-adr.sh 'Add ADR NNNN: Title of the decision' '/full/path/to/the/file.md'
   ```

   Do not push, merge, or remove the worktree.
8. **Report back** with the file path, the worktree path, the branch name, and a one-line summary
   of the decision.

Never edit existing ADRs. An ADR is a record of what was decided at the time. The one exception is
marking an ADR as superseded, which the `supersede-adr` skill does.
