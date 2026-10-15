# Stage 0: a loose skill

This is where most people start: a single skill, `new-adr`, that turns a decision you describe into
an Architecture Decision Record (ADR) in `docs/adr/`.

```
new-adr/
  SKILL.md    # instructions and a template for writing one ADR
```

## Try it

From the root of this repo:

```sh
cp -R stages/0-loose-skill/new-adr ~/.claude/skills/
cd sample-project
claude
```

Then, in Claude Code, record a decision:

```
/new-adr We've agreed to use Redis for session caching instead of in-process memory, because we're moving to several app instances behind a load balancer. We looked at sticky sessions but they make deploys painful.
```

You can also just say it in plain language, without the slash command, for example "We've decided
to use Redis for session caching, can you write that down?". The skill's description tells Claude
when to use it.

**Expected result:** a new file `docs/adr/0003-<short-title>.md`, numbered after the two ADRs already
there, with today's date, status `Accepted`, and sticky sessions listed under "Alternatives
considered".

When you're done, put the sample project back and remove the skill:

```sh
cd ..
git restore sample-project && git clean -fdq sample-project
rm -rf ~/.claude/skills/new-adr
```

## Why this isn't enough

The skill works, for you, on your machine. Now try to give it to your team:

- **No version.** There's no way to say "this is version 0.2, with the new template".
- **No way to install or update it.** Teammates copy a folder by hand, and their copies drift.
- **Only one kind of component.** A skill on its own can't bring hooks, subagents or MCP servers
  with it.
- **Tools don't recognise it.** `claude plugin validate stages/0-loose-skill` fails with
  "No manifest found".

Segment 1 turns this into a plugin, which fixes all four.

One more thing to notice: the skill asks the model to work out the next ADR number itself. That
works most of the time, which is not the same as every time. Segment 2 deals with that.
