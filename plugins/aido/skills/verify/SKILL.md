---
description: Verifies that an implementation faithfully satisfies what was agreed — the approved specification, or a PR's linked issue and description — reporting what is verified, lacks evidence, is unmet or deviates, from a fresh context. Works on the current branch or any PR, and changes nothing. Invoked when the user wants to verify the implementation, check a branch or PR against its specification or acceptance criteria, or runs /aido:verify.
disable-model-invocation: false
---

# Verify

**In Copilot CLI only:** before anything else, read `guidelines/copilot-cli.md` in the plugin root, two folders above this skill's base directory, and follow it. Read every guideline this skill names whole, with `view`, one file per call.

Answer one question: **did we build what we agreed to build?** The target is the current branch or a
PR. No PR needs to exist.

This skill changes nothing. It edits no files, makes no commits, pushes nothing and posts nothing. The
one exception is checking out a PR's branch. Its only edits happen in a throwaway worktree that it
removes. It reports, and the engineer decides.

It is not a code review. `/code-review` looks for defects. This skill ignores bugs, style and design
unless they leave a requirement unmet.

Resolve `SPEC.md` first, as "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Step 0: Load Context

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` and
`${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`. Gather the host repository's conventions as
the latter describes, and find out how to run a single test. Run `git fetch origin`.

## Step 1: Identify the Target

- **a PR number or link was given** → read it:

  ```
  gh pr view <number> --json number,url,title,body,baseRefName,headRefName
  ```

  If `git status --porcelain` shows uncommitted changes, ask with `AskUserQuestion` before switching
  branches: "There are uncommitted changes in this directory. Check out the PR's branch anyway?" —
  options **Check out anyway** / **Cancel** (stop). Never stash or discard them. Then run
  `gh pr checkout <number>`. The base branch is the PR's `baseRefName`
- **nothing was given** → the target is the current branch, and the base branch is the default
  branch. On the default branch itself, say there is nothing to verify, and stop. Note any
  uncommitted changes from `git status --porcelain`. They are not verified, and the report names them

## Step 2: Find What Was Agreed

In this order, the first match wins:

1. **a specification** → read it as "Reading the Approved Specification" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. The requirements are its numbered
   acceptance criteria. Without numbered criteria, they are its plan items, as "Specifications Without
   Acceptance Criteria" describes
2. **a PR without a specification** → the requirements are what its description states, and the
   issues it links there (`Closes #N`, read with `gh issue view <N>`). The report says it used these,
   and that they are weaker than an approved specification
3. **nothing states an intent**: no specification on the current branch, or a PR whose description
   and linked issues state none → say there is nothing to verify against, write no report, and stop

## Step 3: Verify from a Fresh Context — `fable` subagent

The agent that built a change should not judge it. So this always runs in a fresh context, wherever
it was started from.

Launch one `Agent` with `model: "fable"`. Brief it with "The Shared Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`, and:

- the repository root and the diff range (`git diff origin/<base-branch>...HEAD`)
- what was agreed: the spec file's path, or the `git show` command that reads it from history, or the
  text of the PR description and its linked issues
- the host repository's agent instruction files to read, and how to run a single test
- "The Verification Brief" below, copied in full. The subagent hasn't loaded this skill
- nothing else from this session: no summary of the work, and no opinion of it

If `fable` is unavailable, act as "When the Model Is Unavailable" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md` describes. If no subagent can run at all, follow the
brief in this session. The report's `Independence` line then says it was not independent.

### The Verification Brief

Judge the change against what was agreed. Read the code and run tests. Never edit files, except in
the throwaway worktree under "Check that each test can fail".

**Evaluate:**

- **specification compliance** — does the change do what each requirement says?
- **completeness** — is every requirement built, with its relevant edge cases?
- **test evidence** — does a meaningful test support each requirement?
- **agreed constraints** — does the change respect the specification's `## Design notes`, its
  `## Design decision` and the host repository's agent instruction files?
- **deviations** — what does the change do that was not agreed, or differently from what was agreed?

Don't look for general defects, and don't give opinions on style or design. A defect matters here
only when it leaves a requirement unmet.

**Sort every requirement as exactly one of:**

- **verified** — for an automatable requirement: a named test that covers all of it, that you ran and
  saw pass in this verification, and that passed "Check that each test can fail". For one marked
  `(manual)`: the user's confirmation recorded in `## Progress`, which you cite
- **insufficient evidence** — it may be met, but you can't show it. No test covers it, a test covers
  only part of it, a test could not run, a test still passes with the behaviour removed, or a
  `(manual)` requirement has no recorded confirmation. Any doubt you can't resolve goes here
- **unmet** — the code shows the behaviour missing or different, or its test fails

**Check that each test can fail.** The agent that wrote the code probably wrote the tests too. A
passing test proves little until it has been seen to fail. For each test you would cite as evidence,
once per requirement:

1. create a throwaway worktree outside the repository, so the user's checkout stays untouched:
   `git worktree add --detach <temp-dir> HEAD`
2. in it, remove the behaviour the requirement describes. Restore the implementation files it depends
   on (`git checkout origin/<base-branch> -- <files>`). If the code then no longer loads, make the
   smallest edit that takes the behaviour out instead. Leave the test itself alone
3. run the test there. It must fail on its assertion about the missing behaviour. A failure because
   the code doesn't load shows nothing: make a smaller edit and run it again
4. remove the worktree, whatever the result: `git worktree remove --force <temp-dir>`

- **it fails** → the test counts as evidence
- **it still passes** → the requirement is **insufficient evidence**. Name the test, and say it passes
  without the behaviour
- **the check can't run**, such as when the worktree lacks dependencies or a service → the test can
  still support **verified**, but say `not shown to fail`, and why

**How to read the specification:**

- claims in `## Progress` are not evidence, apart from a user's confirmation of a `(manual)`
  requirement. Judge from the code and the tests you ran
- a criterion recorded as `deferred` is not sorted above. List it under deviations as already
  decided, with its reason
- a criterion recorded as `changed` is checked against its current wording
- a conflict under `## Alignment decisions` was decided by the engineer, and is not a deviation
- a change that a refactoring in `## Refactorings` explains is planned, and is not a deviation. It is
  never evidence that something is met
- a mode change recorded in `## Progress` was decided while building, and is not a deviation from
  the plan. Don't judge whether a mode was the right choice

**List under deviations**, separately: changes in the diff that no requirement or plan item explains,
and departures from the agreed scope, `## Out of scope`, the plan, the `## Design decision` or the
`## Design notes`.

**Every finding names its evidence:** the test and the command that ran it, or the `path` and symbol.
Never state that something is met only because it looks right.

**Return only this report**. Write `none` under an empty section:

```markdown
# Verification of <branch or PR>

Verified against: <the specification and where it was found | the linked issue and PR description, which is weaker than an approved specification>
Independence: <fresh-context subagent | not independent: it ran in the implementing session>
Not verified: <uncommitted changes, by file> (omit if there are none)

## Verified

- AC1: <the test and the command that ran it, and what removing the behaviour did to it (or `not shown to fail`, and why); or the recorded confirmation>

## Insufficient evidence

- AC2: <what is missing and where you looked>

## Unmet

- AC3: <what is missing or different, with `path` — symbol>

## Deviations

- <the change or departure, with `path` — symbol>
- AC4: already decided, deferred — <its reason>
```

## Step 4: Present the Report

Show the report as it came back. Don't soften or reorder it. Then:

- add that it doesn't cover general code defects, and that `/code-review` does
- on a PR, say which branch is now checked out

Fix nothing. The engineer decides what to do with the findings.

## STOP — Skill Complete

If another skill started this one, go back to the step that called it, and add no block. Otherwise
end as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes.
