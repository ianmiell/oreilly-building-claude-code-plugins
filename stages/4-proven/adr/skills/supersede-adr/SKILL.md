---
name: supersede-adr
description: Replace an existing Architecture Decision Record (ADR) with a new decision and mark the old one as superseded. Use when the user says an earlier decision has changed or been reversed, for example "supersede ADR 2", "we're replacing PostgreSQL with X, update the ADRs", or "ADR 0004 no longer holds". For a new decision that replaces nothing, use new-adr instead.
---

# Supersede an ADR

Record a new decision that replaces an earlier one, and link the two records.

## Steps

1. **Find the old ADR.** Work out which ADR the user means, by number or title, and read it. ADRs
   are in the project's ADR directory, `docs/adr/` unless the project keeps them elsewhere. If more
   than one ADR could match, ask which. If it is already superseded, say so and stop.
2. **Gather the facts for the new decision**: the decision, why it changed, the alternatives and
   the consequences. If the new decision or the reason for the change is missing, ask for
   everything missing in one question.
3. **Write the new ADR with the `adr:new-adr` skill.** Invoke it with the Skill tool and pass it
   the new decision, its context, alternatives and consequences, and the fact that it supersedes
   the old ADR. Do not write the new ADR yourself: `new-adr` owns the numbering, file naming and
   template, so every ADR comes out the same way.
4. **Link the two records** once `new-adr` has written the file:
   - In the old ADR, change only the status, to `Superseded by [ADR MMMM](<new file name>)`.
     In an ADR with a `status:` field in its front matter, set it to `superseded by ADR-MMMM`
     instead. Change nothing else in the old ADR.
   - In the new ADR, add `Supersedes [ADR NNNN](<old file name>)` on its own line just after the
     status.
5. **Report back** with both file paths and a one-line summary of what changed.
