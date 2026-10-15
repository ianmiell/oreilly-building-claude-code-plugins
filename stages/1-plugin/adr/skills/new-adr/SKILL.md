---
name: new-adr
description: Record an architecture decision as a new Architecture Decision Record (ADR) in docs/adr/. Use when the user has made, or wants to write down, a technical or architectural decision, for example "write an ADR", "record this decision", "document why we chose X", or "we've decided to use Y, write that down". Do not use when the user only asks what an ADR is.
---

# New ADR

Write one new Architecture Decision Record for the decision the user describes.

## Steps

1. **Gather the facts.** You need: the decision, the context (the problem or force behind it),
   the alternatives that were considered, and the consequences. Take them from the conversation.
   If the decision or the reason for it is missing, ask for everything missing in one question.
   Do not invent alternatives or reasons the user did not give; leave a section short instead.
2. **Find the ADR directory.** Use `docs/adr/` at the root of the current project. Create it if
   it does not exist.
3. **Pick the number.** Look at the existing files named `NNNN-*.md` in that directory. The new
   number is the highest existing number plus one, zero-padded to four digits. If there are none,
   use `0001`.
4. **Name the file.** `NNNN-short-title-in-kebab-case.md`, for example
   `0003-use-redis-for-session-caching.md`.
5. **Write the file** using the template below. Set the status to `Accepted` if the user says the
   decision is agreed, otherwise `Proposed`. Use today's date.
6. **Report back** with the file path and a one-line summary of the decision.

Never edit existing ADRs. An ADR is a record of what was decided at the time.

## Template

```markdown
# NNNN. Title of the decision

Date: YYYY-MM-DD

## Status

Proposed

## Context

What problem or force led to this decision? Two to five sentences.

## Decision

We will ...

## Alternatives considered

- **Alternative** - why it was not chosen.

## Consequences

What becomes easier, what becomes harder, and what we now have to do.
```
