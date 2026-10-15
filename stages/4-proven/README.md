# Stage 4: proven

The `adr` plugin with the evidence that it works. Nothing about what the plugin does changes in this
stage. What's new is a way to check it: static validation that catches broken files before anyone
loads them, and an eval suite that measures whether the plugin makes Claude do better than it would
on its own.

```
adr/                                  # version 0.4.0: stage 3 plus...
  evals/                              # new: the eval suite
    records-agreed-decision/
      case.yaml                       # the prompt, limits and graders for one case
      scaffold.sh                     # sets up the project the case runs in
    asks-for-missing-reason/
    supersedes-old-decision/
    ignores-general-question/         # a case where the plugin should NOT fire
```

Tested with Claude Code 2.1.300. `claude plugin eval` needs 2.1.269 or later.

## Validation

`claude plugin validate` reads every file in the plugin and checks it against the formats Claude Code
loads. It is quick and costs nothing, because it never starts a model.

```sh
claude plugin validate --strict stages/4-proven/adr
```

```
Validating plugin manifest: .../stages/4-proven/adr/.claude-plugin/plugin.json

✔ Validation passed
```

Why it matters: Claude Code is forgiving when it loads a plugin. A broken file is skipped, not reported.
Here is what `validate` said about a copy of the plugin with five mistakes in it:

```
  ❯ homepage_url: Unknown field 'homepage_url'. Claude Code ignores it at load time.
  ❯ frontmatter: YAML frontmatter failed to parse: YAML Parse error: Unexpected token. At runtime
    this skill loads with empty metadata (all frontmatter fields silently dropped).
  ❯ hooks: hooks.PostToolUsed: unknown hook event; entry ignored at runtime
  ❯ mcpServers.adr-search.command: Invalid input: expected string, received undefined. The plugin
    loader silently drops this server at load.
```

The broken skill and the broken MCP server are errors, so validation fails. Fix those two and run it
again: the misspelt hook event and the unknown field are only warnings, so the result is
`✔ Validation passed with warnings` with exit code 0, and your `PostToolUse` check never runs again.
With `--strict`, warnings fail the run:

```
✘ Validation failed (--strict treats warnings as errors)
```

Use `--strict` in CI. `--json` gives the same result as one JSON object for scripts.

Validation doesn't check everything. It said nothing about a version of `0.4`, which isn't semver, and
it doesn't read the eval suite. A broken eval case is reported when the suite loads.

To see what the plugin will cost every session, load it and ask for its details:

```sh
claude --plugin-dir stages/4-proven/adr plugin details adr
```

```
Projected token cost
  Always-on:   ~344 tok   added to every session

Per-component (rounded)
  component      always-on  on-invoke
  new-adr             ~130       ~640
  supersede-adr       ~140       ~520
  adr-reviewer         ~80       ~400
```

These are estimates, and the figure varies with how the plugin is loaded. The same plugin installed
from the marketplace showed ~242 always-on tokens.

## The eval suite

Validation tells you the files are well formed. It can't tell you whether Claude does the right thing
with them. That is what `claude plugin eval` is for: it runs real prompts against the plugin, grades
the results, and runs each prompt again **without** the plugin, so you can see what the plugin adds.

A case is a folder under `evals/` with a `case.yaml` (or a `prompt.md`; see below). This is
`evals/records-agreed-decision/case.yaml`, with the judges' criteria shortened:

```yaml
schema_version: "1.1"
name: records-agreed-decision
description: An agreed decision becomes ADR 0003, in the template, with nothing invented.
tags: [fires]
context:
  scaffold_script: scaffold.sh
execution:
  prompt: >-
    We've agreed to use Redis for session caching instead of sticky sessions on the load
    balancer, because sticky sessions drop users' baskets whenever we deploy. Please write that down.
  max_turns: 15
  allowed_tools: [Skill, Read, Write, Edit, Glob, Grep, Bash]
graders:
  - type: file_exists
    name: numbered-0003
    path: docs/adr/0003-*.md
  - type: regex
    name: kebab-case-file-name
    weight: 0.5
    target: files
    pattern: "docs/adr/0003-[a-z0-9]+(-[a-z0-9]+)*\\.md"
  - type: llm
    name: follows-template
    focus: trace
    criteria: |
      Look only at the new file Claude wrote under docs/adr/ whose name starts with 0003.
      PASS if all of these are true of that file: ...
  - type: llm
    name: nothing-invented
    focus: trace
    criteria: |
      ... PASS if ... sticky sessions are the only alternative it says was considered.
  - type: tool_used
    name: plugin-fired
    tool: Skill
    input_match: '"skill"\s*:\s*"(adr:)?new-adr"'
```

### What each part does

- **`scaffold_script`** builds the starting state. Every run starts in an empty folder, so
  `scaffold.sh` writes ADRs 0001 and 0002 into `docs/adr/`, and the right next number is 0003. The
  script must sit inside the case folder: a path with `..` is refused. It only runs when you pass
  `--scaffold`, because it is a shell script running as you.
- **`allowed_tools`** is what the case needs. `Write`, `Edit` and `Bash` are also gated by you on the
  command line with `--allow-tools`, so a suite you downloaded can't grant itself a shell.
- **Graders** score each run. A run's score is the weighted share of graders that pass. The types are:

  | Type | Passes when |
  |---|---|
  | `file_exists` | A file created during the run matches the glob (or none does, with `exists: false`) |
  | `regex` | A pattern is found in the `target`: the last message (default), the `trace`, the list of created `files`, or one file's contents |
  | `llm` | A judge model votes PASS on your `criteria` in at least 2 of 3 votes |
  | `tool_used` | A tool was called between `min` and `max` times |
  | `tool_order` | One tool call came before another |
  | `baseline` | A judge finds the run at least as good as a reference transcript |

Prefer graders that can't be argued with: a file exists, a pattern matches. Use an `llm` grader only
for what a regex can't check, and write its criteria as specific claims a reader could verify. The
judge is Haiku unless you pass `--judge-model`; a larger judge catches more nuance and costs more.

One catch: a `{source: file, path: ...}` target needs an exact path, not a glob. It suits the
supersede case, which checks the existing `0002-use-postgresql-for-order-data.md`. The new ADR's name
depends on its title, so the template checks read the `trace` instead, where the file's content
appears in the `Write` call.

### The four cases

| Case | Prompt | What it checks |
|---|---|---|
| `records-agreed-decision` | An agreed decision, with its reason and one alternative | ADR 0003 exists, has a kebab-case name, follows the template, invents nothing |
| `asks-for-missing-reason` | A decision with no reason | No ADR is written yet, and the reply asks why |
| `supersedes-old-decision` | A reversed decision | ADR 0003 exists, 0002 is marked superseded with a link, and 0003 links back |
| `ignores-general-question` | "What's an ADR?" | No file is written, no skill runs, and the question is answered |

The last case matters as much as the others. A plugin that writes an ADR whenever someone mentions
one is worse than no plugin. Every suite needs at least one case where the plugin should stay out of
the way.

### Run it

From the plugin folder:

```sh
cd stages/4-proven/adr
claude plugin eval . --scaffold --allow-tools Bash Write Edit --no-publish
```

The first run in a folder asks you to confirm that you trust the plugin, because its hooks and
scripts run on your machine as you. `--no-publish` keeps the HTML report on your machine. Without it,
the report is published privately to your claude.ai account, if your account supports that.

The full suite is 4 cases × 3 runs × 2 arms, so 24 Claude sessions. With `-j 4` (four sessions at
once) it took about two minutes and cost $3.09, judges included. The cost lands on your own Claude
account. For a quicker, cheaper check, run each case once with `--runs 1`, or pick cases with
`--case 'records-*'` or `--tag fires`.

You'll see a warning for every case:

```
mocks: "plugin:adr:adr-search" has no mock and is NOT started — its tools are unavailable this run
```

That is expected. By default an eval never starts a plugin's real MCP servers. You'd add stand-ins
under `evals/mocks/adr-search/` to test a flow that uses the search tool. None of these cases do.

### Read the result

```
CASE                      WITH  W/OUT Δ      RUNS COST    NOTES
asks-for-missing-reason   1.00  1.00  0.00   6    $0.62
ignores-general-question  1.00  1.00  0.00   6    $0.67
records-agreed-decision   1.00  0.71  +0.29  6    $0.81
supersedes-old-decision   1.00  0.33  +0.67  6    $0.98

4 case(s) · mean Δ +0.24 · 125s · $3.09
```

- **WITH** is the score with the plugin loaded; **W/OUT** is the same prompts with no plugin.
- **Δ** is the difference. It is the number that tells you whether the plugin is worth having.
  Here the plugin earns its keep on supersession: without it, Claude writes ADR 0003 but never marks
  0002 as superseded or links the two. On a plain new ADR the gain is smaller, the template's
  "Alternatives considered" section.
- A Δ near zero means Claude already does this well on its own. That's fine for
  `ignores-general-question`, where the goal is not to make things worse. For a case where the plugin
  should help, it means the case isn't testing anything the plugin adds, or the plugin isn't adding it.
- `plugin-fired` shows as `[with-only, not scored]`. Whether a skill ran is useful to see, but it isn't
  an outcome, so it doesn't count towards the score.

Results go in `evals/results/<timestamp>/`: `aggregate-result.json` for scripts and `report.html` to
read. They're ignored by git. Pass `--keep-temp` to keep each run's folder and `trace.jsonl` when you
need to see what Claude actually did.

Before you trust an `llm` grader, read a few of the files it passed and failed. In this suite's first
run, the run without the plugin wrote a neat ADR that copied the format of the existing ones, which
have no "Alternatives considered" section. The judge failed it on `follows-template`, and it was right.

### In CI

`claude plugin eval` exits 1 if any case scores below `--threshold` (default 1.0). Δ never changes the
exit code. A CI job might run:

```sh
claude plugin validate --strict .
claude plugin eval . --trust-plugin --scaffold --allow-tools Bash Write Edit \
  --threshold 0.8 --no-publish --max-cost-usd 10 --json results.json
```

`--trust-plugin` answers the trust prompt, so only use it on a plugin you'd run yourself.
`--max-cost-usd` stops the run (exit 2) before it spends more than you meant to. The job needs a
Claude Code login or an API key. These commands were run locally for this course, not in a CI
service; the [docs](https://code.claude.com/docs/en/plugin-evals) cover running evals in CI.

### Writing your own cases

`claude plugin eval init` interviews you about the plugin and writes a suite. For a blank case:

```sh
claude plugin eval init --bare my-case
```

That writes `evals/my-case/prompt.md` (the prompt, with limits in its front matter) and
`evals/my-case/graders/criteria.md` (one grader per file). It's the same information as a `case.yaml`
split across files. Use `case.yaml` when you need a scaffold, as every case here does.

The [Claude Code docs](https://code.claude.com/docs/en/plugin-evals) have the full reference.

## Portability to other agents

Your team may not all use Claude Code. How much of `adr` works elsewhere depends on the component.

### What we tried

Tested with Codex CLI 0.162.1 and Claude Code 2.1.300.

**The skill on its own.** Skills follow the [Agent Skills](https://agentskills.io/specification) open
standard, so a `SKILL.md` with `name` and `description` is read by many agents. We copied the stage 2
`new-adr` skill to `.agents/skills/new-adr/` in a copy of the sample project and gave Codex the Redis
prompt. It found the skill and wrote a correct `docs/adr/0003-use-redis-for-session-caching.md`, in
the template.

It got there by improvising. `${CLAUDE_SKILL_DIR}` means nothing to Codex, so it ran
`${CLAUDE_SKILL_DIR:-.agents/skills/new-adr}/scripts/next-adr.sh`, and `${user_config.adr_dir}` arrived
as literal text. The script copes with that because it was written to (stage 2's fallback to
`docs/adr`). That's the lesson: Claude-only variables don't expand elsewhere, so make scripts work
without them.

**Where skills live.** No folder works for every agent. Codex and Gemini CLI look in `.agents/skills/`.
Claude Code doesn't: with the skill only in `.agents/skills/`, Claude Code 2.1.300 had no `new-adr`
skill. A symlink between `.claude/skills/` and `.agents/skills/` covers both.

**The whole plugin.** Codex read this repository's `.claude-plugin/marketplace.json` as it is:

```sh
codex plugin marketplace add <path-to-this-repo>
codex plugin add adr@building-plugins-course
```

It installed `adr` 0.3.0 and offered its skills as `adr:new-adr` and `adr:supersede-adr`, which wrote
the ADR. It reported no MCP tools from the plugin, and nothing showed that the hooks ran.

### The matrix

From our tests and the agents' own documentation as of October 2026:

| Component | Portable? | Notes |
|---|---|---|
| Skills (`SKILL.md`, scripts, templates) | Yes | The Agent Skills standard. Mind the folder, and Claude-only variables such as `${CLAUDE_SKILL_DIR}` and `${user_config.*}` |
| `allowed-tools` in a skill | Barely | In the standard but marked experimental; don't rely on another agent enforcing it |
| `AGENTS.md` | Yes | Read by Codex, Cursor, Copilot, Gemini CLI and others. Claude Code 2.1.300 reads it when there's no `CLAUDE.md` |
| MCP server | The protocol, yes | Every major agent speaks MCP, but each has its own config file. Codex didn't start this one from the plugin's `.mcp.json` |
| Hooks | Partly | Similar ideas, different files and event names (Gemini CLI calls `PostToolUse` `AfterTool`). Rewrite per agent |
| Subagent | No | Other agents use other formats, and `model: haiku` names a Claude model |
| Monitor, `userConfig` | No | Claude Code only |
| Plugin and marketplace manifests | Partly | Codex, Copilot CLI and VS Code read `.claude-plugin/` files; Cursor and Gemini CLI use their own |

There is also a cross-agent plugin format, [Agent Plugins 1.0](https://agent-plugins.org/) (August
2026), backed by OpenAI, Microsoft, Cursor, Amazon and Vercel. It covers skills and MCP servers only,
and Claude Code isn't listed as supporting it.

The practical advice: put what must work everywhere into skills and an MCP server, keep scripts free
of Claude-only assumptions, and treat hooks, subagents and monitors as Claude Code extras.
