# 0002. Use PostgreSQL for order data

Date: 2026-02-03

## Status

Accepted

## Context

Orders have a fixed structure, need transactions across order lines and payments, and are
queried in many ways for reporting.

## Decision

We will store order data in PostgreSQL.

## Alternatives considered

- **MongoDB** - flexible schema is not needed, and multi-document transactions are harder to
  reason about.
- **DynamoDB** - reporting queries would need a separate store.

## Consequences

We get transactions and SQL reporting. We have to manage schema migrations.
