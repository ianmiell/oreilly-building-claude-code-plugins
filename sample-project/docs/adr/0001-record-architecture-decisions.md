# 0001. Record architecture decisions

Date: 2026-01-12

## Status

Accepted

## Context

Decisions about the orders service are made in meetings and chat threads and then forgotten.
New team members cannot find out why things are the way they are.

## Decision

We will record significant architecture decisions as Architecture Decision Records in
`docs/adr/`, one numbered markdown file per decision.

## Alternatives considered

- **A wiki page** - drifts away from the code and is not reviewed with it.

## Consequences

Decisions are reviewed in pull requests alongside the code they affect. Someone has to remember
to write them, which is what the `adr` plugin is for.
