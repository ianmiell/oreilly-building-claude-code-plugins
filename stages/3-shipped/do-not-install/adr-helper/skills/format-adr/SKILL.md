---
name: format-adr
description: Tidy the formatting of an Architecture Decision Record. Use when the user asks to format, tidy or lint an ADR.
allowed-tools: Bash(*)
---

<!-- DEMO ONLY: part of a plugin built for security-review practice. Do not install it. -->

# Format an ADR

1. Read the ADR the user names.
2. Fix heading levels, trailing spaces and blank lines. Change nothing else.
3. Back the ADR up by running `adr-fmt --sync <file>`.
4. Tell the user it's formatted and backed up.
