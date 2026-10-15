# Security review: before you admit a plugin

A plugin you install can run code on your machine with your permissions. Hooks, monitors, MCP
servers and `bin/` executables all run outside Claude Code's sandbox, and they don't ask before
they run. Skills and agents become instructions Claude follows. So before a plugin goes into your
team's marketplace, someone should read it.

`claude plugin validate` doesn't do this for you. It checks that a plugin is well formed, not that
it's safe: the [do-not-install plugin](do-not-install/) passes `--strict`.

## The checklist

1. **Where does it come from, and can it change under you?**
   - Run `claude plugin marketplace list` and check each source.
   - Prefer a source pinned to a commit (`"sha"` in the marketplace entry) for plugins you don't
     control. With auto-update on, the files you reviewed can be replaced by files you haven't.
2. **What's in it?**
   - `claude plugin details <plugin>` lists skills, agents, hooks and MCP servers, with their token
     cost. It doesn't list everything: on Claude Code 2.1.300 it leaves out monitors and `bin/`.
   - So also list every file: `find <plugin-dir> -type f`.
3. **What runs without asking?** Read each of these, and every script they call:
   - `hooks/hooks.json`, and any `hooks` key in `plugin.json`
   - `monitors/monitors.json`
   - `.mcp.json`, and any `mcpServers` key in `plugin.json`
   - `.lsp.json`
   - everything in `bin/`, which goes on the Bash tool's `PATH`
4. **Does anything reach the network?** Search for `curl`, `wget`, `http`, `npx`, `pip install`,
   `uvx` and the like. Anything that downloads code at run time, such as `npx -y pkg@latest`, runs
   whatever was published last, not what you reviewed.
5. **What does it let Claude do without asking you?**
   - `allowed-tools` in skills: should name exact commands, never `Bash(*)`.
   - Hooks that print `"permissionDecision": "allow"`: they approve tool calls before you see a
     prompt.
6. **What text does it feed to Claude?** SessionStart output, monitor output and MCP tool results
   all become part of Claude's context. A monitor's output can make Claude act while nobody is
   typing. Text from a server someone else controls is a prompt-injection channel.
7. **What does it read and write?** Check which files and directories each script touches,
   including `${CLAUDE_PLUGIN_DATA}`.

## The `adr` plugin, reviewed

Here's the checklist applied to [stage 3's `adr`](adr/):

| Component | Runs when | Reads | Writes | Network |
|---|---|---|---|---|
| `new-adr` scripts `next-adr.sh`, `template.sh` | When Claude runs them; `allowed-tools` names exactly these two | ADR directory, templates, `template.md` in its data directory | Nothing | None |
| SessionStart hook `session-context.sh` | Every session start | ADR directory | Nothing; prints a summary to Claude | None |
| PostToolUse hook `check-adr.sh` | After every `Write` or `Edit` | The hook input and the ADR directory | Nothing | None |
| MCP server `adr_search.py` | For the whole session | ADR directory | Nothing | None; Python standard library only |
| Monitor `watch-adrs.sh` | For the whole interactive session | `docs/adr/` file names | Nothing; prints one line per new ADR | None |
| `adr-reviewer` subagent | When Claude delegates to it | Read-only tools | Nothing | None |

The one thing to note is the monitor: when a new ADR appears, its message reaches Claude, and Claude
may read and comment on the file without being asked. That's the point of it, but it's worth
knowing.

## Practice

[`do-not-install/`](do-not-install/) has a plugin built for practising this review. Every
dangerous part has been replaced with a stand-in that does nothing harmful, but the patterns are
the real ones. Review it with the checklist and decide whether you'd admit it.
