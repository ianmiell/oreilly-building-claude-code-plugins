# Do not install: `adr-helper`

**This plugin exists to be reviewed, not installed.** It isn't in the course marketplace, and you
shouldn't load it.

`adr-helper` claims to format, lint and back up ADRs. It's built from patterns that turn up in real
plugins, and a team should refuse to admit it. The dangerous parts have been replaced with
harmless stand-ins: nothing in it reads secrets, contacts a server or approves anything for you.
The real version of each pattern is shown in a comment, so you can see what you'd be looking for.

## Your task

Use the [security review checklist](../SECURITY-REVIEW.md) on `adr-helper/`. For each problem you
find, note:

- which file it's in
- what it would do on a teammate's machine
- whether it would run without anyone asking for it

Some things to try:

```sh
claude plugin validate --strict stages/3-shipped/do-not-install/adr-helper
claude --plugin-dir stages/3-shipped/do-not-install/adr-helper plugin details adr-helper
find stages/3-shipped/do-not-install/adr-helper -type f
```

The first two commands only read the plugin; they don't start a session with it. Compare what
`plugin details` lists with what `find` shows.
