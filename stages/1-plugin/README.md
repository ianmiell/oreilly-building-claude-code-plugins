# Stage 1: a plugin

The same `new-adr` skill as [stage 0](../0-loose-skill/), packaged as a plugin called `adr`. The
skill itself hasn't changed by a single character. What's new is the packaging around it.

```
adr/                         # the plugin root
  .claude-plugin/
    plugin.json              # the manifest: name, version, description, author
  skills/
    new-adr/
      SKILL.md               # unchanged from stage 0
```

## What changed

- **A folder layout Claude Code knows.** Skills live in `skills/<name>/SKILL.md` under the plugin
  root. Claude Code finds them there without being told.
- **A manifest.** `.claude-plugin/plugin.json` gives the plugin a name and a version, plus a
  description and an author for anyone deciding whether to install it. Only `name` is required.
  Without the other three the plugin still loads, but `claude plugin validate --strict` fails.
- **A namespace.** Every component is named after the plugin, so the skill is now `/adr:new-adr`.
  Two plugins can each have a `new-adr` skill without colliding.

Check it:

```sh
claude plugin validate --strict stages/1-plugin/adr
```

## Try it

If you installed the stage 0 skill, remove it first so you know which copy is answering:

```sh
rm -rf ~/.claude/skills/new-adr
```

Then load the plugin for one session, from the sample project:

```sh
cd sample-project
claude --plugin-dir ../stages/1-plugin/adr
```

In Claude Code:

```
/adr:new-adr We've agreed to use Redis for session caching instead of in-process memory, because we're moving to several app instances behind a load balancer. We looked at sticky sessions but they make deploys painful.
```

A plain-language request ("We've decided to use Redis for session caching, can you write that
down?") works too: the skill's description still tells Claude when to use it.

**Expected result:** the same as stage 0, a new `docs/adr/0003-<short-title>.md`.

`--plugin-dir` loads the plugin for this session only. Nothing is installed, so there's nothing to
remove afterwards. Put the sample project back with:

```sh
cd ..
git restore sample-project && git clean -fdq sample-project
```

## What else can go in a plugin

A plugin can carry more than skills. Each kind of component has a default place under the plugin
root (full list in the
[plugin manifest reference](https://code.claude.com/docs/en/plugins-reference#standard-layout)):

| Component | Where it goes | What it does |
|---|---|---|
| Skills | `skills/<name>/SKILL.md` | Instructions Claude loads when a task matches |
| Scripts | any folder, such as `scripts/` | Code that skills and hooks run, so the model doesn't have to |
| Subagents | `agents/<name>.md` | A specialist with its own prompt and tools |
| Hooks | `hooks/hooks.json` | Commands that run on events, such as session start or after a file is written |
| MCP servers | `.mcp.json` | Tools and data from an external process |

Inside a hook or an MCP server config, `${CLAUDE_PLUGIN_ROOT}` is the plugin's installed path. Use it
so the plugin works wherever it ends up. Stage 2 adds the first script.

## Still missing

The plugin is only on your machine, loaded by hand for one session. Stage 3 puts it in a
marketplace so a team can install and update it. Before that, stage 2 makes its behaviour
reliable, starting with the ADR number.
