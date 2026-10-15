# Exercise 2: write an eval case that catches over-triggering

**Time:** about 10 minutes. **You need:** Claude Code (2.1.269 or later), git and a terminal.
**Cost:** each run of the case is two short Claude sessions plus a judge, about $0.15 on your own
account.

A skill that fires when it shouldn't is a real bug: ask "what's an ADR?" and get a file you didn't
want. You'll write an eval case that checks the `adr` plugin stays out of the way for a plain
question, then break the plugin and watch the case catch it.

## Start

From the root of this repo, copy the stage 3 plugin, which has no evals yet, into the scratch folder:

```sh
mkdir -p work && cp -R stages/3-shipped/adr work/adr && cd work/adr
```

## Steps

1. **Create a blank case.**

   ```sh
   claude plugin eval init --bare explains-adrs
   ```

   It prints `Created evals/explains-adrs/prompt.md and evals/explains-adrs/graders/criteria.md`.
   The prompt file holds what to ask; each file in `graders/` is one check.

2. **Write the prompt.** Replace the contents of `evals/explains-adrs/prompt.md` with:

   ```markdown
   ---
   max_turns: 10
   allowed_tools: [Skill, Read, Write, Edit, Glob, Grep]
   ---

   What's an ADR, and when is it worth a team writing one?
   ```

3. **Check the answer is useful.** Replace `evals/explains-adrs/graders/criteria.md` with a rubric
   for the judge model:

   ```markdown
   ---
   type: llm
   ---

   PASS if the reply explains that an ADR (Architecture Decision Record) records an architectural decision with its context and consequences, and gives at least one situation where writing one is worthwhile.
   FAIL if the reply only offers to write an ADR without explaining what one is.
   ```

4. **Check nothing is written.** Create `evals/explains-adrs/graders/no-file.md`:

   ```markdown
   ---
   type: file_exists
   path: "**/*"
   exists: false
   ---
   ```

5. **Check no skill runs.** Create `evals/explains-adrs/graders/no-skill.md`:

   ```markdown
   ---
   type: tool_used
   tool: Skill
   min: 0
   max: 0
   arm: both
   ---
   ```

   `arm: both` makes this count in the score. Without it, a `Skill` check is shown but not scored.

6. **Run it once.**

   ```sh
   claude plugin eval . --runs 1 --allow-tools Write Edit --no-publish
   ```

   The first time, Claude Code asks you to confirm you trust the plugin. `--allow-tools Write Edit`
   lets Claude write files, so "nothing was written" means something. Ignore the warning that
   `adr-search` has no mock: this case doesn't use it.

7. **Break the plugin.** In `skills/new-adr/SKILL.md`, replace the `description:` line with:

   ```yaml
   description: Use whenever the user mentions ADRs or architecture decisions in any way, including questions about what an ADR is.
   ```

   Run step 6 again.

8. **Put it back.**

   ```sh
   cp ../../stages/3-shipped/adr/skills/new-adr/SKILL.md skills/new-adr/SKILL.md
   ```

## Expected result

Step 6 passes in both arms:

```
CASE           WITH  W/OUT Δ      RUNS COST    NOTES
explains-adrs  1.00  1.00  0.00   2    $0.12
```

A Δ of zero is the right answer here. Claude explains ADRs well without the plugin; the case is
there to prove the plugin doesn't make that worse.

Step 7 fails, because the loosened description makes the skill fire on a question:

```
CASE           WITH  W/OUT Δ      RUNS COST    NOTES
explains-adrs  0.67  1.00  -0.33  2    $0.13   no-skill: Skill called 1x (expected 0..0)
```

A negative Δ means the plugin made Claude worse at this prompt. The command exits with code 1, so
in CI this would stop the change.

Models vary from run to run, so your judge votes and costs may differ a little. That's why the real
suite runs each case three times.

## If you have time

- Run with `--keep-temp` and read the `trace.jsonl` it keeps, to see exactly what Claude did.
- Add a second prompt in the same spirit, such as "Show me the ADRs we have", and decide what
  should happen.

## Solution

The stage 4 plugin has the same case, written as a single `case.yaml`:
[`stages/4-proven/adr/evals/ignores-general-question/`](../stages/4-proven/adr/evals/ignores-general-question/).
It also sets up two existing ADRs with a scaffold script, so the project looks like a real one.
`prompt.md` plus `graders/*.md`, and `case.yaml`, hold the same information. Use `case.yaml` when a
case needs a scaffold.
