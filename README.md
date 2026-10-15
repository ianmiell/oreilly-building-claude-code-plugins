# Building Claude Code Plugins

Course materials for the O'Reilly live training **Building Claude Code Plugins**.

Across the course you build one plugin, `adr`, which helps a team write and maintain Architecture
Decision Records (ADRs). It starts as a single loose skill and grows, stage by stage, into a tested
plugin shipped to a whole team.

## The course

| Segment | Topic | Stage |
|---|---|---|
| 1 | From skill to plugin | 0 → 1 |
| 2 | Making behaviour reliable | 1 → 2 |
| 3 | Shipping it to a team | 2 → 3 |
| 4 | Proving it works | 3 → 4 |

## Prerequisites

- [Claude Code](https://code.claude.com/docs), signed in. Tested with Claude Code 2.1.300.
- git
- A terminal
- Python 3, from stage 3 on (for the MCP server; standard library only, nothing to install)

## What's here

```
.claude-plugin/     # this repo is also a marketplace: it lists the stage 3 adr plugin
sample-project/     # a pretend service with a couple of ADRs; run Claude Code here
stages/             # the adr plugin at each stage of the course
exercises/          # the hands-on exercises; each one's solution is a stage
```

To install the finished plugin from this repo's marketplace:

```sh
claude plugin install adr --marketplace ianmiell/oreilly-building-claude-code-plugins
```

## Stages

| Stage | What it is | Status |
|---|---|---|
| [0: a loose skill](stages/0-loose-skill/) | The `new-adr` skill on its own | Ready |
| [1: a plugin](stages/1-plugin/) | The skill packaged as a plugin and loaded locally | Ready |
| [2: reliable](stages/2-reliable/) | Scripts, configuration, skills that call skills, hooks and a reviewer subagent | Ready |
| [3: shipped](stages/3-shipped/) | A marketplace, versioning, rolling out to a team and a security review, plus an MCP server and a monitor | Ready |
| [4: proven](stages/4-proven/) | Validation, an eval suite, and portability to other agents | Ready |

Start with [stage 0](stages/0-loose-skill/).

## Exercises

| Exercise | Segment | Solution |
|---|---|---|
| [1: turn a loose skill into a plugin](exercises/01-skill-to-plugin.md) | 1 | [stage 1](stages/1-plugin/adr/) |
| [2: write an eval case that catches over-triggering](exercises/02-eval-case.md) | 4 | [stage 4](stages/4-proven/adr/evals/ignores-general-question/) |
