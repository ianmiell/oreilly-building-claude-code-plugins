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

## What's here

```
sample-project/     # a pretend service with a couple of ADRs; run Claude Code here
stages/             # the adr plugin at each stage of the course
exercises/          # the hands-on exercises; each one's solution is a stage
```

## Stages

| Stage | What it is | Status |
|---|---|---|
| [0: a loose skill](stages/0-loose-skill/) | The `new-adr` skill on its own | Ready |
| [1: a plugin](stages/1-plugin/) | The skill packaged as a plugin and loaded locally | Ready |
| [2: reliable](stages/2-reliable/) | Scripts, configuration and skills that call skills | Ready |
| 3: shipped | A team marketplace, versioning and managed settings | Coming |
| 4: proven | Validation and an eval suite | Coming |

Start with [stage 0](stages/0-loose-skill/).

## Exercises

| Exercise | Segment | Solution |
|---|---|---|
| [1: turn a loose skill into a plugin](exercises/01-skill-to-plugin.md) | 1 | [stage 1](stages/1-plugin/adr/) |
