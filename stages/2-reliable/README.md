# Stage 2: reliable

The `adr` plugin from [stage 1](../1-plugin/), made dependable. Three changes:

- **Scripts do the mechanical work.** The next ADR number and the choice of template come from
  shell scripts, not from the model.
- **Configuration and persistent data.** Teams choose where ADRs live and which template to use,
  and you can keep your own template somewhere that survives plugin updates.
- **A skill that calls another skill.** The new `supersede-adr` skill hands the writing of the new
  ADR to `new-adr` rather than doing it itself.

```
adr/
  .claude-plugin/plugin.json      # version 0.2.0, now with userConfig
  skills/
    new-adr/
      SKILL.md                    # runs the scripts instead of working things out
      scripts/next-adr.sh         # prints the directory and next number, e.g. docs/adr/0003
      scripts/template.sh         # prints the template to fill in
      templates/nygard.md
      templates/madr.md
    supersede-adr/
      SKILL.md                    # new: replaces an ADR, using new-adr to write it
settings-example.json             # configuration for trying it locally
```

## Scripts inside skills

In stage 1 the model worked out the next ADR number by reading the directory. It usually gets it
right. A script gets it right every time, costs no tokens, and you can test it on its own:

```sh
stages/2-reliable/adr/skills/new-adr/scripts/next-adr.sh sample-project/docs/adr
# sample-project/docs/adr/0003
```

`SKILL.md` tells Claude to run the script and use exactly what it prints. Two details make this
work wherever the plugin is installed:

- **`${CLAUDE_SKILL_DIR}`** is replaced with the skill's own directory when the skill loads, so the
  skill can find its scripts without knowing where the plugin lives.
- **`allowed-tools`** in the skill's front matter lets Claude run those two scripts, and nothing
  else, without asking permission each time:

  ```yaml
  allowed-tools:
    - Bash(${CLAUDE_SKILL_DIR}/scripts/next-adr.sh *)
    - Bash(${CLAUDE_SKILL_DIR}/scripts/template.sh *)
  ```

A good rule: if a step has one right answer, put it in a script. Leave the model the parts that
need judgement, such as summarising the context and naming the decision.

## Configuration

Different teams keep ADRs in different places and use different formats. `plugin.json` declares
two options under `userConfig`:

| Option | What it sets | Default |
|---|---|---|
| `adr_dir` | Where ADRs live, relative to the project root | `docs/adr` |
| `template` | `nygard` (Michael Nygard's original format) or `madr` ([MADR](https://adr.github.io/madr/)) | `nygard` |

The skill refers to them as `${user_config.adr_dir}` and `${user_config.template}`, and Claude
Code puts in the user's values when the skill loads.

When someone installs the plugin from a marketplace (stage 3), Claude Code asks them for these
values. A plugin loaded with `--plugin-dir` gets no such dialog, so for local testing pass them in
a settings file. Plugins loaded this way have the ID `adr@inline`:

```json
{
  "pluginConfigs": {
    "adr@inline": {
      "options": {
        "adr_dir": "docs/decisions",
        "template": "madr"
      }
    }
  }
}
```

That's [`settings-example.json`](settings-example.json). Claude Code reads `pluginConfigs` only from
your user settings, a `--settings` file or managed settings. It ignores it in a project's
`.claude/settings.json`, so a repository you clone can't set your plugin options for you.

## Persistent data

The plugin directory, `${CLAUDE_PLUGIN_ROOT}`, is replaced every time the plugin updates. Anything
written there is lost. For data that should last, Claude Code gives each plugin a directory that
survives updates: `${CLAUDE_PLUGIN_DATA}`, which is `~/.claude/plugins/data/<plugin-id>/`.

`template.sh` checks it for a `template.md` of your own. If there is one, it wins over the bundled
templates, and it's still there after the next update.

## Skills that call skills

`supersede-adr` handles "we've changed our minds about ADR 2". It needs a new ADR, so it invokes
`adr:new-adr` through the Skill tool rather than writing one itself. Numbering, file names and the
template stay in one place. Afterwards it changes the old ADR's status to `Superseded by ADR 0003`
and links the new one back.

## Try it

From the sample project, with the plugin loaded:

```sh
cd sample-project
claude --plugin-dir ../stages/2-reliable/adr
```

1. **Record a decision**, as before:

   ```
   /adr:new-adr We've agreed to use Redis for session caching instead of in-process memory, because we're moving to several app instances behind a load balancer. We looked at sticky sessions but they make deploys painful.
   ```

   Expected: `docs/adr/0003-use-redis-for-session-caching.md`, in the Nygard format. Claude runs
   `next-adr.sh` and `template.sh` without asking permission.

2. **Supersede a decision.** Reset the sample project first (see below), start Claude Code again,
   and say:

   ```
   ADR 2 no longer holds. We've agreed to move order data from PostgreSQL to CockroachDB because we're expanding to three regions and need local writes in each. We looked at PostgreSQL logical replication but conflict handling was too fragile. Please update the decision records.
   ```

   Expected: Claude uses `supersede-adr`, which calls `new-adr`. You get
   `docs/adr/0003-use-cockroachdb-for-order-data.md` with `Supersedes [ADR 0002](...)` under its
   status, and in `0002-use-postgresql-for-order-data.md` only the status has changed, to
   `Superseded by [ADR 0003](...)`.

3. **Change the configuration.** Reset again, then start Claude Code with the example settings and
   repeat step 1:

   ```sh
   claude --plugin-dir ../stages/2-reliable/adr --settings ../stages/2-reliable/settings-example.json
   ```

   Expected: `docs/decisions/0001-use-redis-for-session-caching.md`, in MADR format with `status`
   and `date` in front matter.

Reset the sample project between steps, from the repo root:

```sh
git restore sample-project && git clean -fdq sample-project
```

Claude Code creates the plugin's data directory, `~/.claude/plugins/data/adr-inline/`, the first
time the skill loads. Remove it when you've finished with the course.
