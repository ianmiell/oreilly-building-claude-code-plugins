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
```

## Stages

| Stage | What it is | Status |
|---|---|---|
| [0: a loose skill](stages/0-loose-skill/) | The `new-adr` skill on its own | Ready |
| 1: a plugin | The skill packaged as a plugin and loaded locally | Coming |
| 2: reliable | Scripts, configuration and skills that call skills | Coming |
| 3: shipped | A team marketplace, versioning and managed settings | Coming |
| 4: proven | Validation and an eval suite | Coming |

Start with [stage 0](stages/0-loose-skill/).
