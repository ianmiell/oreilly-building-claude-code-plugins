# Stage 3: shipped

The `adr` plugin, ready for a team. This stage is about getting it onto other people's machines,
keeping it up to date, and deciding whether to trust it. It also adds the two components that run
for the whole session: an MCP server and a monitor.

```
adr/                              # version 0.3.0: stage 2 plus...
  .mcp.json                       # new: the adr-search MCP server
  scripts/adr_search.py           # new: the server, Python 3 standard library only
  monitors/monitors.json          # new: the new-adrs monitor
  scripts/watch-adrs.sh           # new: what the monitor runs
rollout/
  project-settings.json           # share the plugin through a repository
  managed-settings.json           # roll it out to every machine in an organisation
SECURITY-REVIEW.md                # what to check before you admit a plugin
do-not-install/                   # a plugin to practise the review on
```

The marketplace itself is at the root of this repository, in
[`.claude-plugin/marketplace.json`](../../.claude-plugin/marketplace.json).

## A marketplace

A marketplace is a catalogue of plugins: a `.claude-plugin/marketplace.json` file in a git
repository (or a directory, or at a URL). This one lists a single plugin:

```json
{
  "name": "building-plugins-course",
  "owner": { "name": "Ian Miell" },
  "description": "The adr plugin from the O'Reilly course Building Claude Code Plugins",
  "plugins": [
    {
      "name": "adr",
      "source": "./stages/3-shipped/adr",
      "description": "Write and manage Architecture Decision Records"
    }
  ]
}
```

`source` here is a path inside the same repository. It could instead point at another GitHub repo,
any git URL, an npm package or an archive. Install it in one step:

```sh
claude plugin install adr --marketplace ianmiell/oreilly-building-claude-code-plugins
```

That adds the marketplace and installs `adr@building-plugins-course` for your user. Installed this
way, nobody is asked for the plugin's options, and Claude Code says so:

```
2 userConfig options not yet set — run /plugin configure adr@building-plugins-course in Claude Code, or pass --config KEY=VALUE.
```

Pass them at install time with `--config adr_dir=docs/adr --config template=nygard`, or run
`/plugin configure adr@building-plugins-course` in a session. Installing from `/plugin` inside a
session shows the dialog.

To take it all out again:

```sh
claude plugin uninstall adr@building-plugins-course
claude plugin marketplace remove building-plugins-course
```

## Versions and the update trap

Claude Code works out a version for every plugin it installs, and only replaces the cached copy
when that version changes. It takes the first of these that is set:

1. `version` in the plugin's `plugin.json`
2. `version` in the plugin's marketplace entry
3. For a plugin from git, the commit SHA

So once you set `"version": "0.3.0"`, every user stays on the copy they have until you change that
string, however many commits you push:

```
$ claude plugin update adr@building-plugins-course
✔ adr is already at the latest version (0.3.0).
```

Bump the version and push, and the next update picks it up:

```
✔ Plugin "adr" updated from 0.3.0 to 0.3.1 for scope user. Restart to apply changes.
```

Rules that follow from this:

- **Bump the version with every release.** Or leave `version` out of both places, so every commit
  counts as a new version.
- **Set it in one place only.** If `plugin.json` and the marketplace entry disagree,
  `plugin.json` wins without a warning at run time.
- **`claude plugin update <plugin>`** refreshes the marketplace and installs the new version.
  `claude plugin marketplace update` on its own refreshes the catalogue but leaves installed
  plugins alone.
- **Auto-update is off for marketplaces you add yourself.** Turn it on per marketplace under
  `/plugin` → Marketplaces, or with `"autoUpdate": true` in settings (see below).
- **Updates apply on restart** (or `/reload-plugins`, except for monitors, which need a restart).
  Claude Code keeps the old version on disk for 14 days.

One exception: a marketplace added from a local path loads its plugins in place, straight from
your directory. Your edits show up at the next session without a version bump. That's convenient
while you develop, and it's why you won't see the trap until you install from git.

## Rolling it out

Two ways to get the plugin to a team without asking everyone to run commands.

**Through a repository.** Put [`rollout/project-settings.json`](rollout/project-settings.json) into
the repo's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "building-plugins-course": {
      "source": { "source": "github", "repo": "ianmiell/oreilly-building-claude-code-plugins" }
    }
  },
  "enabledPlugins": { "adr@building-plugins-course": true }
}
```

When a teammate opens the repo and accepts the folder trust prompt, Claude Code adds the
marketplace and turns the plugin on. `claude plugin marketplace add ... --scope project` and
`claude plugin install ... --scope project` write these keys for you. Teammates can still turn the
plugin off for themselves in `.claude/settings.local.json`.

**Through managed settings.** An organisation's IT team can put
[`rollout/managed-settings.json`](rollout/managed-settings.json) on every machine, at
`/Library/Application Support/ClaudeCode/managed-settings.json` on macOS or
`/etc/claude-code/managed-settings.json` on Linux. Users can't override managed settings, so this
does more than the repo route:

- `extraKnownMarketplaces` and `enabledPlugins` install the plugin at the user's next session, and
  turning it off at their own level doesn't stop it loading.
- `"autoUpdate": true` keeps everyone on the latest release.
- `strictKnownMarketplaces` allows only the listed marketplaces, so nobody can add another one.
  As written it also blocks Anthropic's official marketplace; add it to the list if you want it.

## The MCP server

`adr-search` gives Claude a `search_adrs` tool: search the project's ADRs by words and by status,
and get back each match's number, title, status, file and matching lines.

```json
{
  "mcpServers": {
    "adr-search": {
      "command": "python3",
      "args": ["-I", "${CLAUDE_PLUGIN_ROOT}/scripts/adr_search.py"],
      "env": {
        "ADR_DIR": "${user_config.adr_dir}",
        "ADR_PROJECT_DIR": "${CLAUDE_PROJECT_DIR}"
      }
    }
  }
}
```

- The server is one Python file using only the standard library, so there's nothing to install.
  It speaks MCP's JSON-RPC over stdin and stdout.
- Claude Code starts it when the session starts, as `plugin:adr:adr-search` in `/mcp`. Its tool is
  named `mcp__plugin_adr_adr-search__search_adrs`; use that name in permission rules.
- The plugin's options and paths reach it through `env`.

Why a server, when Claude could just grep? A tool with a schema gives the same structured answer
every time, and any MCP client can use it, not only Claude Code.

## The monitor

`new-adrs` runs `watch-adrs.sh` in the background for the whole session. When a new ADR appears in
`docs/adr/`, for example after a `git pull` brings in a teammate's decision, it prints a line, and
that line reaches Claude as a notification:

```
⏺ Monitor event: New ADR: docs/adr/0003-use-kafka-for-order-events.md · New ADRs that appear in docs/adr during the session
```

Claude can then read the new ADR and check it against the others, without being asked.

- Monitors only run in interactive sessions, never with `claude -p`.
- They can't read the plugin's options, so this one watches the default `docs/adr/`.
- Monitors are under `experimental` in the manifest reference, so their format may change.

## Security review

Hooks, the monitor, the MCP server and the skill's scripts all run code on your machine. Before you
admit any plugin, `adr` included, go through [SECURITY-REVIEW.md](SECURITY-REVIEW.md). Then
practise on [`do-not-install/`](do-not-install/).

## Try it

From the root of this repo, load stage 3 directly (nothing is installed):

```sh
cd sample-project
claude --plugin-dir ../stages/3-shipped/adr
```

1. **Search:** "Use the search_adrs tool to find decisions about PostgreSQL." Expected: ADR 0002,
   with its status and the lines that matched.
2. **Watch:** leave Claude Code running, and in another terminal, from `sample-project`:

   ```sh
   cp docs/adr/0002-use-postgresql-for-order-data.md docs/adr/0003-copy-for-the-monitor.md
   ```

   Expected: within about 10 seconds, a `Monitor event: New ADR: docs/adr/0003-...` line, and
   Claude reacts to it.

Then reset the sample project, from the repo root:

```sh
git restore sample-project && git clean -fdq sample-project
```
