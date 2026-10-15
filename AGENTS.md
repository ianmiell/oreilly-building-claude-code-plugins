# AGENTS.md

Guidance for AI coding agents maintaining this repository. `CLAUDE.md` imports this file.

If you're helping someone work through the course in `sample-project/` or `work/`, these
instructions aren't for you: ignore this file and help them with their task.

## What this repo is

Public, learner-facing materials for the O'Reilly live training **Building Claude Code Plugins**.
Learners clone it, follow the stage READMEs and do the exercises. Everything here should be
finished, tested and safe to run on a learner's machine.

The course builds one plugin, `adr`, which writes and maintains Architecture Decision Records.
It grows through numbered stages:

```
stages/0-loose-skill/   # the starting point: a loose skill, not a plugin
stages/1-plugin/adr/    # the plugin root for stage 1; later stages follow the same pattern
exercises/              # one file per exercise, each pointing at a stage as its solution
sample-project/         # a pretend service learners run Claude Code in
work/                   # learners' scratch folder (git-ignored)
.claude-plugin/         # the course marketplace; lists only the stage 3 adr plugin
```

`stages/3-shipped/do-not-install/` holds a plugin built for security-review practice. Never list it
in the marketplace, and keep every part of it inert: stand-ins print or do nothing, real patterns
appear only in comments, and any URL uses the `.invalid` domain.

## Rules for changes

### Stages are snapshots

- Each stage is a complete, standalone copy of the plugin at that point in the course. Don't
  make one stage depend on files in another.
- Change only what the stage is meant to teach. If stage N+1 changes a file, the diff between
  stages should show just that lesson.
- A fix to an earlier stage usually needs carrying forward into every later stage.
- Keep the README table of stages, and each stage's README, in step with what's on disk.

### Exercises

Each exercise has a starting state reachable in one command, numbered steps, an expected result,
and a solution kept separate from the starting state (normally a stage folder). Exercises should
take about 10 minutes and need only Claude Code, git and a terminal.

### Technical accuracy

Learners copy what they see, and Claude Code's plugin system changes quickly.

- Check plugin facts (manifest fields, layout, CLI commands and flags, hook events, marketplace
  and settings formats) against https://code.claude.com/docs or by running the command. Don't
  rely on memory, and never invent flags, keys or file names.
- Expected output quoted in a README or exercise must be real output from running it.
- Record the Claude Code version a stage or exercise was tested with.

### Testing a change

```sh
claude plugin validate --strict stages/<stage>/adr
```

Then run the stage's "Try it" steps end to end. To test headless without changing your own skills
or settings, copy `sample-project` to a temporary folder outside the repo and run there:

```sh
claude -p "/adr:new-adr We've agreed to use Redis for session caching ..." \
  --plugin-dir <path-to>/stages/<stage>/adr \
  --permission-mode acceptEdits --allowedTools "Read Write Edit Glob Grep Skill Agent" < /dev/null
```

From stage 2, `Skill` lets one skill call another, `Edit` lets `supersede-adr` change a status, and
`Agent` lets Claude use the reviewer subagent. Plugin hooks run in headless sessions too.
The skills' own scripts run through their `allowed-tools`, so don't add `Bash` here: that would hide
a broken `allowed-tools` rule. Pass `--settings stages/2-reliable/settings-example.json` to test
configuration.

Keep the prompt straight after `-p`: `--allowedTools` takes several values and swallows a prompt
that follows it. Check that `docs/adr/0003-*.md` appears with the expected content.

From stage 3:

- Test marketplace, install and update behaviour with `CLAUDE_CONFIG_DIR` set to an empty temporary
  folder, so nothing touches your own plugins. `claude plugin` commands work there without a login;
  `claude -p` doesn't.
- Allow the MCP tool by its full name: `mcp__plugin_adr_adr-search__search_adrs`.
- Monitors never run with `-p`. Test them in an interactive session, for example one started in
  `tmux`, and check for a `Monitor event:` line.

From stage 4, run the eval suite from the plugin folder. It costs real money (about $3 for the full
suite), so pilot a changed case on its own first:

```sh
cd stages/4-proven/adr
claude plugin eval . --case '<case-name>' --runs 1 --scaffold --allow-tools Bash Write Edit --no-publish --trust-plugin
```

- Each case's `scaffold.sh` must sit inside its case folder; `..` paths are refused.
- A `{source: file, path}` grader target needs an exact path. For a file whose name the model
  chooses, grade the `trace` or use `file_exists` with a glob.
- If you change a case, update the recorded results table in the stage README from a full run.
- Results go to `evals/results/`, which git ignores. `--keep-temp` leaves read-only sandboxes in the
  system temp folder; `chmod -R u+rwx` them before deleting.

## Style

- British English spelling ("behaviour", "organisation").
- Plain, direct prose in short sentences. Explain why, not just how.
- Markdown, with fenced code blocks that carry a language tag.

## Safety

- No secrets, tokens, email addresses, internal URLs or customer names. Plugin manifests list the
  author by name only.
- Scripts, hooks and MCP servers must be safe on a learner's machine: nothing destructive, and no
  network calls to services learners haven't been told about.
- Risky patterns shown for the security review must be clearly labelled as examples of what not
  to admit, and must not run by default. See `stages/3-shipped/do-not-install/`.
- Don't put instructor-only material here: speaker notes, timings or answers to questions
  the instructor will ask live.
