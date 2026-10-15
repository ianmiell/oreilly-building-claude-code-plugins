# 0003. Use Redis for session caching

Date: 2026-10-15

## Status

Accepted

## Context

Sessions are currently cached in process memory. We are moving to several app instances behind
a load balancer, so a request may reach an instance that does not hold that user's session.

## Decision

We will cache sessions in Redis instead of in process memory.

## Alternatives considered

- **In-process memory (current approach)** - each instance would only see its own sessions once
  there is more than one instance.
- **Sticky sessions** - they make deploys painful.

## Consequences

Any instance can serve any request, so the load balancer does not need sticky sessions and
deploys stay simple. We now have to run Redis as a new dependency of the app.
