# Orders service (sample project)

A pretend service that takes and tracks customer orders. There is no code here: the course only
needs somewhere realistic to keep Architecture Decision Records.

Run Claude Code from this folder during the exercises. ADRs live in `docs/adr/`.

To put this folder back how it started after an exercise, run this from the repo root:

```sh
git restore sample-project && git clean -fdq sample-project
```

`.claude/settings.json` stops Claude Code loading the course repo's own `CLAUDE.md` and `AGENTS.md`
(instructions for people maintaining the course) into your sessions here. Claude Code normally
loads those files from every directory above the one you start it in. The setting matches the
repo's default folder name, `oreilly-building-claude-code-plugins`. If you cloned it under another
name, the course still works; Claude just sees some notes that aren't meant for you.
