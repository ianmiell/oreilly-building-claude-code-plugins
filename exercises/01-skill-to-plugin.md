# Exercise 1: turn a loose skill into a plugin

**Time:** about 10 minutes. **You need:** Claude Code, git and a terminal.

You'll take the stage 0 `new-adr` skill, package it as a plugin called `adr`, check it with the
validator, and load it into Claude Code for one session.

## Start

From the root of this repo, copy the loose skill into a scratch folder (`work/` is ignored by git):

```sh
mkdir -p work/adr && cp -R stages/0-loose-skill/new-adr work/adr/
```

You now have `work/adr/new-adr/SKILL.md`. If you installed the stage 0 skill earlier, remove it so
it doesn't answer in place of your plugin:

```sh
rm -rf ~/.claude/skills/new-adr
```

## Steps

1. **See what the validator makes of it.**

   ```sh
   claude plugin validate work/adr
   ```

   It fails: `No manifest found in directory`. Claude Code doesn't recognise this folder as a plugin.

2. **Put the skill where a plugin keeps skills.** Skills go in `skills/<name>/SKILL.md` under the
   plugin root.

   ```sh
   mkdir work/adr/skills && mv work/adr/new-adr work/adr/skills/
   claude plugin validate work/adr
   ```

   This time it passes, with no manifest at all. The layout alone is enough for Claude Code to find
   the skill. What's missing is anything that says what this plugin is.

3. **Add a manifest with just a name.** Create `work/adr/.claude-plugin/plugin.json`:

   ```json
   {
     "name": "adr"
   }
   ```

   Then validate again. It passes with three warnings: no version, no description, no author.

4. **Make it pass strict validation.** Run:

   ```sh
   claude plugin validate --strict work/adr
   ```

   `--strict` treats warnings as errors, the way you'd run it in CI. Add a `version` (start at
   `0.1.0`), a `description`, and an `author` object with your `name`, until it passes. Keep email
   addresses out if you plan to publish the plugin anywhere public.

5. **Load it and use it.**

   ```sh
   cd sample-project
   claude --plugin-dir ../work/adr
   ```

   In Claude Code, record a decision with the plugin's skill. Note the new name, `adr:new-adr`:

   ```
   /adr:new-adr We've agreed to use Redis for session caching instead of in-process memory, because we're moving to several app instances behind a load balancer. We looked at sticky sessions but they make deploys painful.
   ```

6. **Clean up.** Leave Claude Code, then put the sample project back:

   ```sh
   cd ..
   git restore sample-project && git clean -fdq sample-project
   ```

## Expected result

- `claude plugin validate --strict work/adr` prints `✔ Validation passed`.
- In step 5, `sample-project/docs/adr/0003-<short-title>.md` appears, numbered after the two ADRs
  already there, with status `Accepted` and sticky sessions under "Alternatives considered".

## If you have time

- Ask in plain language instead: "We've decided to use Redis for session caching, can you write
  that down?" Does Claude still pick the skill?
- Change `name` in `plugin.json` to something else, restart Claude Code with `--plugin-dir`, and
  look at what the skill is called now.

## Solution

The finished plugin is in [`stages/1-plugin/adr/`](../stages/1-plugin/adr/). Compare yours with it:

```sh
diff -r work/adr stages/1-plugin/adr
```

The only differences should be in `plugin.json`, where your description and author will differ.
The skill files should match exactly. The solution's manifest:

```json
{
  "name": "adr",
  "version": "0.1.0",
  "description": "Write and manage Architecture Decision Records",
  "author": {
    "name": "Ian Miell"
  },
  "repository": "https://github.com/ianmiell/oreilly-building-claude-code-plugins"
}
```

`repository` is optional. It tells people where the source lives.
