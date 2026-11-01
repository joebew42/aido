---
description: Implements the feature using TDD. Invoked when the user wants to implement the feature, start TDD, begin red-green-refactor, or runs /aiae:2-implement.
disable-model-invocation: false
---

# Implement the Feature

Incrementally implement the feature based on specifications using **strict, incremental
test-driven development — one test at a time**.

`SPEC.md` and `SPEC.md.draft` stand for the spec file and its draft, resolved as "The
Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes —
resolve it before reading or writing either.

Match step size to how much design you must *discover* vs. *conform to*: outer acceptance/contract
tests are written test-first (and committed last), and the units they drive are grown with strict
TDD, inside-out. See "Test-First vs. Strict TDD" in `${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md`.

## Step 0: Load Context

Before any implementation work:

- check for the presence of the `SPEC.md` file — if not present, stop; if only `SPEC.md.draft`
  exists, tell the user the specification isn't approved yet and to run `/aiae:1-plan`
- if `SPEC.md.draft` exists next to `SPEC.md`, delete it and tell the user — the approved
  `SPEC.md` is the only specification
- read `SPEC.md` to understand the full scope
- note whether it has numbered acceptance criteria (`AC1`, `AC2`, …) as "The Specification
  Structure" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. If it has
  none, skip everything below about acceptance criteria — goal posts, the Acceptance Criteria Check
  and their Progress lines — and do not ask about them

### Global guidelines (always load)

Load these once — they apply regardless of stack:

- `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/testing-principles.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`

### Project conventions

Gather the host repository's conventions as `project-conventions.md` describes.

Before writing the first test, make sure you know how to run a single test, the relevant suite, and
the linter in this project. If you can't determine one of them, ask the user.

- do NOT re-read guideline files during implementation — they are already loaded

## Step 1: Confirm Implementation Scope

After loading context, use `AskUserQuestion` to present the list of plan items from `SPEC.md`,
each with the acceptance criteria it serves, and ask:

> "Here are the planned items. Which ones would you like to tackle in this session? (all / specific items / let me pick the next logical one)"

Wait for the user's response before starting implementation.

## Acceptance Criteria as Goal Posts

The specification's acceptance criteria are the outer loop of the double loop described in "Test-First
vs. Strict TDD" (`tdd.md`). Before growing the units of a plan item:

- [ ] for each **automatable** criterion the item serves and that no test covers yet, write its
      outer acceptance test **test-first**, at the boundary where the behaviour is observable
- [ ] run it and confirm it fails for the **right reason** — the behaviour is missing, not the test
      broken
- [ ] keep it red as the goal post while the units behind it are grown with strict TDD,
      inside-out; it does not count against "one failing test at a time" in the inner loop
- [ ] it stays **uncommitted** while red, and the per-commit gate does not cover it: the units
      committed meanwhile need their own tests and the existing suite green, not the goal post
- [ ] it is committed once green, last, as `git-workflow.md` says for acceptance tests
- [ ] criteria marked `(manual)` get no test; they are confirmed in the Acceptance Criteria Check

When the item's criterion is already covered by a test that predates this feature, name it and move
on — do not write a duplicate.

## MANDATORY: Strict, Incremental TDD — One Test at a Time

Grow each unit through the cycle in `tdd.md`, one behavior per micro-cycle, until it is fully
specified:

```
RED (one test) → GREEN (minimum code) → REFACTOR (on green) → next test
```

Present each micro-cycle as its own reviewable increment so the user can follow along and
supervise step by step. Do not race ahead to the finished implementation.

In REFACTOR, also check:

- the Dependency Rule — no outward dependency introduced (application or domain code naming
  anything in infrastructure), and no decision-making left in infrastructure
- conformance to the guidelines loaded in Step 0 (do not re-read them)
- whether this cycle revealed a possibly shared concept, a duplicated business rule or a boundary
  crossing. If so, run a **Systemic Design Checkpoint** (below) before the next RED

**Unit done:** when every behavior the plan gives that unit has a test and all are green. Commit
the unit, then move to the next unit.

## Systemic Design Checkpoint

The REFACTOR step looks at the code just written; this checkpoint looks beyond it. The rules —
what to look for, the evidence rule, the four outcomes, the boundaries and when to stop — are in
`${CLAUDE_PLUGIN_ROOT}/guidelines/systemic-refactoring.md`. Read it the first time a checkpoint runs; this is the one guideline
read allowed during implementation. It runs in test-first and strict-TDD mode alike, and **never**
as a broad scan after every cycle.

### Starting context

- the spec's `## Design notes`, if `/aiae:1-plan` wrote them
- the architecture index, if there is one, read as described in **Reading the Index** in
  `${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md` — search it, don't load it. Never offer to build or
  update it here; that belongs to planning
- the diff, and a few searches for the domain's own vocabulary and symbols

### On evidence, during TDD — session model

Run it inline, on green, scoped to the evidence the cycle surfaced:

1. inspect the code the evidence points to and verify the design issue is real
2. classify it: **fix now**, **refactor now**, **defer** or **no action**
3. apply fix-now and refactor-now changes in small steps, re-running the relevant tests after each
4. before a refactoring that touches another module, ask with `AskUserQuestion`, showing the
   finding and its evidence — options **Refactor now** / **Defer** / **No action**
5. note deferred findings for the `## Progress` handoff, then return to RED

### Before completion — `fable` subagent

Run it after the Acceptance Criteria Check below, so it reviews the code that the check may have
added. Once every plan item is implemented — not at the end of a partial session — the checkpoint is due
over the whole feature. It can take long and is not always needed, so ask first —
`AskUserQuestion`: "Should I run the final Systemic Design Checkpoint over the whole feature?" —
options **Run the checkpoint** / **Skip it**:

- mark **Run the checkpoint** as recommended when the diff against main touches more than one
  module or area, or introduces a new domain concept or abstraction; otherwise mark **Skip it** as
  recommended. Diff size alone does not count
- in the question, say briefly why the recommended option is recommended
- on **Skip it**, launch nothing: note the skip for the `## Progress` handoff and go on to
  completion

On **Run the checkpoint**, launch one `Agent` with `model: "fable"`. Brief it with:

- the repository root and the diff range (`git diff main...HEAD`)
- the `SPEC.md` path; when it has `## Design notes`, ask the subagent to check them against what
  was actually built and to call out where they no longer hold
- if there is an index, its directory and the **Reading the Index** steps from
  `${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md`, copied in full
- `systemic-refactoring.md` and the rules it points to in `code-standards.md`, copied
  — the subagent has not loaded the guidelines
- never to edit files
- to return only findings, each with **Observation**, **Evidence** (`path` — `Symbol`),
  **Classification**, **Recommendation** and **Risk** — or one line saying none were found

If `fable` is unavailable or the call is denied, run the same brief with the session's model and
say so.

Then, in this session:

1. open the cited files and confirm each finding before acting on it
2. present the findings; ask with `AskUserQuestion` before any that touch another module
3. apply the accepted ones on green, in small steps, re-running the relevant tests after each
4. record the deferred ones for the `## Progress` handoff

### Committing systemic refactorings

Follow the stand-alone refactoring rule in `git-workflow.md`, loaded in Step 0.

## Acceptance Criteria Check

Before ending the session — and before the final Systemic Design Checkpoint when the last plan
items are done — check the acceptance criteria. This is what verifies the specification's intent,
not only the plan.

**Which criteria:**

- every plan item is implemented → every criterion in `SPEC.md`
- a partial session → only the criteria whose plan items are all done; the rest are recorded as
  `unchecked`

**For each criterion:**

- **automatable** → name the green test that covers it, and run it if it has not run since the last
  change. A test that only covers part of the criterion does not meet it
- **manual** → show the user the evidence from the change (the file, the output, what a person
  would see) and ask with `AskUserQuestion` — options **Confirmed** / **Not met**

**For each criterion that is not met**, ask with `AskUserQuestion`, showing what is missing —
options:

- **Implement it now** — add what is missing with a new goal post and TDD cycles, then check it
  again
- **Change the criterion** — agree the new wording with the user, update it in `SPEC.md`'s
  `## Acceptance criteria` (keeping its ID), and check it again against the new wording
- **Defer it** — leave it unmet, with the reason

Note each result for the `## Progress` handoff. Never record a criterion as met without its
evidence.

## Quality Checks

Apply "Before Every Commit" in `git-workflow.md` before every commit. Do not commit otherwise.

## Commits

Follow `git-workflow.md`. Commit each completed unit as it lands, inside-out: an **atomic,
per-class/module commit** with its tests. **Final history shaping** is not done here —
`/aiae:3-organize-commits` owns it.

## Red Flags to Watch For

If you catch yourself doing any of these, STOP immediately:
- ❌ Breaking the cycle in `tdd.md`: code before its failing test, more than one failing test, logic
  no test demands, or skipping a fake-it / triangulate step that was available
- ❌ Committing without the per-commit gate, or against the commit message rules
- ❌ Merging two pieces of code because they look alike, without confirming they share a business meaning
- ❌ Cleaning up unrelated modules during a systemic checkpoint
- ❌ Running a broad codebase scan after every cycle
- ❌ Declaring the feature done without running the final Systemic Design Checkpoint or asking
  whether to skip it
- ❌ Growing a plan item's units before its automatable criteria have a red goal post
- ❌ Ending the session without the Acceptance Criteria Check, or recording a criterion as met
  without its evidence
- ❌ Changing an acceptance criterion without the user's agreement

## STOP — Skill Complete

When all units of work are implemented and committed, the Acceptance Criteria Check is done — and,
if this session finished the last plan items, the final Systemic Design Checkpoint has run or the
user chose to skip it:

1. **Update `SPEC.md`** with a `## Progress` section at the bottom:
   - list each implemented unit of work (checked off)
   - note any units remaining (if session ended early)
   - record each result of the Acceptance Criteria Check, as "Acceptance in Progress" in "The
     Specification Structure" describes
   - record any key decisions made during implementation (e.g., design choices, deviations from spec)
   - list **Deferred refactorings**, each with its evidence (`path` — `Symbol`) and why it was
     deferred
   - if the user skipped the final Systemic Design Checkpoint, say so
   - keep it brief — this is a handoff note for the next session

2. **Commit the progress update** (per the `SPEC.md` rule in `git-workflow.md` Special Cases):
   - squash or amend into the existing `docs: feature specification` commit if history is not yet pushed
   - if already pushed, add a new `docs: update feature specification` commit

3. Inform the user that implementation is complete and they can run `/aiae:3-organize-commits` when ready.
