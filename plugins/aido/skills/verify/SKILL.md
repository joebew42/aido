---
description: Verifies that an implementation faithfully satisfies what was agreed — the approved specification, or a PR's linked issue and description — reporting what is verified, lacks evidence, is unmet or deviates, from a fresh context. Works on the current branch or any PR, and changes nothing. Invoked when the user wants to verify the implementation, check a branch or PR against its specification or acceptance criteria, or runs /aido:verify.
disable-model-invocation: false
---

# Verify

Answer one question: **did we build what we agreed to build?** The target is the current branch or a
PR; no PR needs to exist.

This skill changes nothing: it edits no files, makes no commits, pushes nothing and posts nothing.
Checking out a PR's branch is the one exception, and its only edits happen in a throwaway worktree
that it removes. It reports, and the engineer decides.

It is not a code review. General defect discovery belongs to `/code-review`, so this skill does not
look for bugs, style or design problems unless they make a requirement unmet.

`SPEC.md` stands for the spec file: resolve it per "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Step 0: Load Context

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` and
`${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`, gather the host repository's conventions
as the latter describes, and find out how to run a single test. Run `git fetch origin`.

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
  branch. On the default branch itself, say there is nothing to verify and stop. Note any
  uncommitted changes from `git status --porcelain`: they are not verified, and the report names them

## Step 2: Find What Was Agreed

In this order, the first match wins:

1. **a specification** → read it as "Reading the Approved Specification" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. The requirements are its numbered
   acceptance criteria. Without numbered criteria, they are its plan items, as "Specifications Without
   Acceptance Criteria" describes
2. **a PR without a specification** → the requirements are what its description and the issues it
   links there (`Closes #N`, read with `gh issue view <N>`) state. The report says this is what it
   used, and that it is weaker than an approved specification
3. **nothing states an intent** — no specification on the current branch, or a PR whose description
   and linked issues state none → say there is nothing to verify against, produce no report, and stop

## Step 3: Verify from a Fresh Context — `fable` subagent

The agent that built a change should not be the one to judge it, so this always runs in a fresh
context, wherever it was started from.

Launch one `Agent` with `model: "fable"`. Brief it with:

- the repository root and the diff range (`git diff origin/<base-branch>...HEAD`)
- what was agreed: the spec file's path, or the `git show` command that reads it from history, or the
  text of the PR description and its linked issues
- the host repository's agent instruction files to read, and how to run a single test
- "The Verification Brief" below, copied in full — the subagent has not loaded this skill
- nothing else from this session: no summary of the work and no opinion of it

If `fable` is unavailable or the call is denied, run the same brief in a subagent with the session's
model and say so. If no subagent can run at all, follow the brief in this session, and the report's
`Independence` line says it was not independent.

### The Verification Brief

Evaluate the change against what was agreed, reading the code and running tests. Never edit files,
except in the throwaway worktree under "Check that each test can fail".

**Evaluate:**

- **specification compliance** — does the change do what each requirement says?
- **completeness** — is every requirement implemented, including its relevant edge cases?
- **test evidence** — does a meaningful test support each requirement?
- **agreed constraints** — does the change respect the specification's `## Design notes` and the
  host repository's agent instruction files?
- **deviations** — what does the change do that was not agreed, or differently from what was agreed?

Do not look for general defects, or report style or design opinions. A defect matters here only when
it makes a requirement unmet.

**Sort every requirement as exactly one of:**

- **verified** — for an automatable requirement, a named test that covers all of it, that you ran and
  saw pass during this verification, and that passed "Check that each test can fail". For one marked
  `(manual)`, a confirmation by the user recorded in `## Progress`, which you cite
- **insufficient evidence** — it may be met, but you cannot show it: no test covers it, a test covers
  only part of it, a test could not be run, a test still passes with the behaviour removed, or a
  `(manual)` requirement has no recorded confirmation. Any uncertainty you cannot resolve goes here
- **unmet** — the code shows the behaviour missing or different, or its test fails

**Check that each test can fail.** The tests were probably written by the agent that wrote the code,
so a passing test proves little until it has been seen to fail. For each test you would cite as
evidence, once per requirement:

1. create a throwaway worktree outside the repository, so the user's checkout stays untouched:
   `git worktree add --detach <temp-dir> HEAD`
2. in it, remove the behaviour the requirement describes: restore the implementation files it depends
   on (`git checkout origin/<base-branch> -- <files>`), or, when that stops the code loading, make the
   smallest edit that takes the behaviour out. Leave the test itself alone
3. run the test there. It must fail on its assertion about the missing behaviour. A failure because
   the code does not load shows nothing, so make a smaller edit and run it again
4. remove the worktree, whatever the result: `git worktree remove --force <temp-dir>`

- **it fails** → the test counts as evidence
- **it still passes** → the requirement is **insufficient evidence**: name the test and say it passes
  without the behaviour
- **the check cannot run**, for example because the worktree lacks dependencies or a service → the test
  can still support **verified**, but say `not shown to fail` and why

**How to read the specification:**

- claims in `## Progress` are not evidence, apart from a user's confirmation of a `(manual)`
  requirement. Judge from the code and the tests you ran
- a criterion recorded as `deferred` is not sorted above: list it under deviations as already decided,
  with its reason
- a criterion recorded as `changed` is checked against its current wording
- a conflict under `## Alignment decisions` was decided by the engineer, and is not a deviation
- a mode change recorded in `## Progress` was decided during implementation, and is not a deviation
  from the plan. Do not judge whether a mode was the right choice

**List under deviations**, separately: changes in the diff that no requirement or plan item explains,
and departures from the agreed scope, the `## Out of scope` section, the plan or the `## Design notes`.

**Every finding names its evidence:** the test and the command that ran it, or the `path` and symbol.
Never state that something is met only because it looks right.

**Return only this report**, writing `none` under an empty section:

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

Show the report as it came back, without softening or reordering it, then:

- add that it does not cover general code defects, and that `/code-review` does
- on a PR, say which branch is now checked out

Do not fix anything. What to do with the findings is the engineer's decision.

## STOP — Skill Complete

If another skill started this one, go back to the step that called it. Otherwise stop here.
