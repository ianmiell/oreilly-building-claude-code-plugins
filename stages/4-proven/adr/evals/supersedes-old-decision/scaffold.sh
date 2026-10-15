#!/bin/sh
# Give the run a project that already has two ADRs, so the next one is 0003.
# Runs in the run's empty working directory, and only when you pass --scaffold.
set -eu
mkdir -p docs/adr
cat > docs/adr/0001-record-architecture-decisions.md <<'ADR'
# 1. Record architecture decisions

Date: 2026-01-12

## Status

Accepted

## Context

We need a record of the architectural decisions made on the orders service.

## Decision

We will use Architecture Decision Records, as described by Michael Nygard.

## Consequences

Each decision is one short Markdown file in docs/adr/, numbered in order.
ADR
cat > docs/adr/0002-use-postgresql-for-order-data.md <<'ADR'
# 2. Use PostgreSQL for order data

Date: 2026-02-03

## Status

Accepted

## Context

Orders need transactions across order lines, payments and stock reservations.

## Decision

We will store order data in a single PostgreSQL instance.

## Consequences

We get transactions and mature tooling. We have to run and back up a database.
ADR
