---
description: Implements the feature using TDD. Invoked when the user wants to implement the feature, start TDD, begin red-green-refactor, or runs /aido:2-implement.
disable-model-invocation: false
---

# Implement the Feature

Incrementally implement the feature based on specifications using **test-driven development, one
test at a time**, in the mode each plan item names.

`SPEC.md` and `SPEC.md.draft` stand for the spec file and its draft: resolve them first, per "The
Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`.

Match step size to how much design you must *discover* vs. *conform to*, as "Step Size" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md` describes.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

**How it was invoked** decides the session's role:

- **nothing, or anything but the two below** → a single session, as this skill describes
- **`loop`, or `loop <first>-<last>`, such as `loop 7-9`** → this session is the **orchestrator**:
  it runs each plan item in a child, as "Loop Mode" describes
- **`item <N>`** → this session is a **child** the orchestrator started for plan item `<N>`, as
  "Child Mode" describes

## Step 0: Load Context

Before any implementation work:

- check for the presence of the `SPEC.md` file — if not present, stop; if only `SPEC.md.draft`
  exists, tell the user the specification isn't approved yet and to run `/aido:1-plan`
- if `SPEC.md.draft` exists next to `SPEC.md`, delete it and tell the user
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

- do NOT re-read guideline files during implementation while they are still loaded. After the
  conversation is compacted they may not be: read them again, and when this skill is invoked again
  with work in progress, skip Steps 0.5 and 1 and continue from the next unit, using `git log` and
  `SPEC.md` to see where the work stands

## Step 0.5: Check the Alignment with the Repository

The default branch may have moved since the specification was approved. Check this at the start of
every session, before anything else is decided:

1. run `git fetch origin`, then list what the default branch has and this branch does not:
   `git log --name-only --format='%h %s' HEAD..origin/<default-branch>`. If the fetch fails, say
   the check could not run and continue at Step 1
2. those commits are **relevant** when they touch a file the specification names, in any section,
   or an agent instruction file (`CLAUDE.md`, `AGENTS.md`)
3. **nothing relevant** → report it in one line and continue at Step 1. Launch no subagent and read
   no further code
4. **something relevant** → read those changes against the specification and its plan, following
   `${CLAUDE_PLUGIN_ROOT}/guidelines/repository-alignment.md`:
   - a significant misalignment, including a constraint planning missed, pauses implementation until
     the user chooses. **Revise** and **Proceed anyway** change `SPEC.md`: commit it per the `SPEC.md`
     rule in `git-workflow.md` Special Cases. **Reject** stops the skill
   - a lesser mismatch does not stop the session: mention it, and handle it when its plan item comes
     up

## Step 1: Confirm Implementation Scope

An orchestrator or a child skips this step: the argument already chose the items.

After loading context, use `AskUserQuestion` to present the list of plan items from `SPEC.md`,
each with the acceptance criteria it serves, and ask:

> "Which items should I do in this session? (all / specific items / the next logical one)"

Wait for the user's response before starting implementation.

## Loop Mode

The orchestrator builds nothing itself. Each plan item runs in a fresh child, so it is built with the
full specification and guidelines in view. Only the orchestrator writes `SPEC.md`.

**Before the first child:** run Step 0 and Step 0.5 once, then choose the items to run, in plan
order:

- **`loop`** → every plan item not ticked in `## Progress`
- **a range** → the items in it. Skip those already ticked in `## Progress`, and name them
- **a range that names an item the plan doesn't have** → don't start the loop, and say why

Show the items it will run, each with the criteria it serves, and ask nothing.

**For each item, in order:**

1. launch one `Agent`, with no model override. Brief it with:
   - the repository root, the `SPEC.md` path and the item's number
   - to invoke `/aido:2-implement item <N>` with the `Skill` tool, and follow it
   - to return only what "Child Results" lists
2. when it returns, check three things:
   - its results give each criterion the item serves as `met`, `changed` or `deferred`
   - the working tree is clean
   - lint and the whole test suite pass
3. **all three pass** → record the item in `## Progress` as "What Progress Records" lists, from the
   child's results, with the item ticked. For a `changed` criterion, also update its wording in
   `## Acceptance criteria`, keeping its ID. Commit it per the `SPEC.md` rule in `git-workflow.md`
   Special Cases, then start the next item's child
4. **one fails** → stop the loop. Report what failed, and the items not yet run. Record nothing for
   the failed item

**When a child returns a question** instead of its results, it has paused. Ask the user with
`AskUserQuestion`, keeping the child's question and options. Then send the answer to that same child
with `SendMessage`, and wait for it to return again. When nobody answers, or the question can't be
asked, stop the loop: name the paused item, its question, and the items not yet run. Record nothing
for the paused item, and offer nothing else.

## Child Mode

A child implements plan item `<N>` and nothing else:

- run Step 0, then go straight to the item, skipping Step 0.5 and Step 1
- build it as the sections below describe, from "Work in the Item's Mode" to "Commits". Its
  Acceptance Criteria Check covers the criteria item `<N>` serves
- **never edit `SPEC.md`**. Wherever this skill says to record something in it, put it in the results
  instead
- skip the final Systemic Design Checkpoint and "STOP — Skill Complete". End by returning what "Child
  Results" lists
- **a child can't ask the user.** Wherever this skill says to ask with `AskUserQuestion`, end your
  turn by returning the question instead: the item's number, the question, and each option with what
  it does. Return nothing else, and carry on from the answer the orchestrator sends back

### Child Results

- the item's number, and the commits it made
- each criterion the item serves, as a line from "Acceptance in Progress" in "The Specification
  Structure"
- the slices built and any mode change, as "Modes and Slices in Progress" in that same section
  describes
- any key decisions, and any deferred refactorings with every field under **What every finding
  states** in `systemic-refactoring.md`

## Work in the Item's Mode

Each feature item names its mode, as "The Modes" in `tdd.md` defines them. Work the item in that mode.
An item with no mode comes from a plan written before modes existed: treat it as inside-out, and do
not ask.

In an `outside-in` item, connect the first slice through the real entry point before writing any edge
case: the entry point calls the feature while the only behaviour it reaches is the first slice's.

**When the plan proves wrong**, change the part's mode rather than carrying on with one that has
stopped fitting: an inside-out part hides an unknown, or an outside-in part turns out to have nothing
left to discover. Tell the user in one line, without asking, and record it as "Modes and Slices in
Progress" in "The Specification Structure" describes.

## Acceptance Criteria as Goal Posts

The specification's acceptance criteria are the outer loop, as "The Modes" in `tdd.md` describes. An
outside-in item has one goal post per slice. Before growing the units of a plan item or slice:

- [ ] for each **automatable** criterion the item serves and that no test covers yet, write its
      outer acceptance test **test-first**, at the boundary where the behaviour is observable
- [ ] run it and confirm it fails for the **right reason** — the behaviour is missing, not the test
      broken
- [ ] keep it red as the goal post while the units behind it are grown in the item's mode; it does
      not count against "one failing test at a time" in the inner loop
- [ ] it stays **uncommitted** while red, and the per-commit gate does not cover it: the units
      committed meanwhile need their own tests and the existing suite green, not the goal post
- [ ] it is committed once green, where "Shape by Mode" in `git-workflow.md` says: with its slice for
      an outside-in item, last otherwise
- [ ] criteria marked `(manual)` get no test; they are confirmed in the Acceptance Criteria Check

When the item's criterion is already covered by a test that predates this feature, name it and move
on — do not write a duplicate.

## MANDATORY: One Test at a Time

Grow each unit through the cycle in `tdd.md`, one behavior per micro-cycle and at the step size its
mode calls for, until it is fully specified:

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
what to look for, the evidence rule, what every finding states, the four outcomes, the boundaries
and when to stop — are in
`${CLAUDE_PLUGIN_ROOT}/guidelines/systemic-refactoring.md`. Read it the first time a checkpoint runs. It runs in test-first and strict-TDD mode alike, and **never**
as a broad scan after every cycle.

### Starting context

- the spec's `## Design notes`, if `/aido:1-plan` wrote them
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
   finding with every field under **What every finding states** in `systemic-refactoring.md` —
   options **Refactor now** / **Defer** / **No action**
5. note deferred findings for the `## Progress` handoff, with those same fields, and park them as
   **Parking an opportunity** in `systemic-refactoring.md` describes, then return to RED

### Before completion — `fable` subagent

Run it after the Acceptance Criteria Check below, so it reviews the code that the check may have
added. Once every plan item is implemented — not at the end of a partial session — the checkpoint is due
over the whole feature. It can take long and is not always needed, so ask first —
`AskUserQuestion`: "Should I run a final design review over the whole feature?" —
options **Run the review** / **Skip it**:

- mark **Run the review** as recommended when the diff against the default branch touches more than one
  module or area, or introduces a new domain concept or abstraction; otherwise mark **Skip it** as
  recommended. Diff size alone does not count
- in the question, say briefly why the recommended option is recommended
- on **Skip it**, launch nothing: note the skip for the `## Progress` handoff and go on to
  completion

In the same `AskUserQuestion` call, offer the next step, following "each approval also settles the
choice that follows it" in `/aido:1-plan`. "STOP — Skill Complete" acts on the answer: "Once
implementation is complete, should I organize the commits?" — options **Organize the commits**
(recommended) / **Stop here**. The question names each criterion recorded as `deferred`, so the user
doesn't continue without noticing it.

On **Run the review**, launch one `Agent` with `model: "fable"`. Brief it with:

- the repository root and the diff range (`git diff origin/<default-branch>...HEAD`)
- the `SPEC.md` path; when it has `## Design notes`, ask the subagent to check them against what
  was actually built and to call out where they no longer hold
- if there is an index, its directory and the **Reading the Index** steps from
  `${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md`, copied in full
- `systemic-refactoring.md` and the rules it points to in `code-standards.md`, copied
  — the subagent has not loaded the guidelines
- `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md`, copied in full, so what it returns follows it. The
  sections and labels it is asked for stay as they are
- never to edit files
- to return only findings, each with its **Classification** and every field under **What every
  finding states** in `systemic-refactoring.md` — or one line saying none were found

If `fable` is unavailable or the call is denied, run the same brief with the session's model and
say so.

Then, in this session:

1. confirm each finding before acting on it, as **Evidence before action** in
   `systemic-refactoring.md` describes
2. present the findings; ask with `AskUserQuestion` before any that touch another module
3. apply the accepted ones on green, in small steps, re-running the relevant tests after each
4. record the deferred ones for the `## Progress` handoff, and park them as **Parking an
   opportunity** in `systemic-refactoring.md` describes

### Committing systemic refactorings

Follow the stand-alone refactoring rule in `git-workflow.md`, loaded in Step 0.

When a plan item names a parked refactoring opportunity, remove its file once the refactoring is
committed, and tell the user.

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
per-class/module commit** with its tests. An outside-in slice grows from the entry point inward, so
commit it when it is finished: its units inside-out, then its acceptance test. **Final history
shaping** is not done here — `/aido:3-organize-commits` owns it.

## What Progress Records

The `## Progress` section of `SPEC.md` is a handoff note for the next session. Keep it brief:

- list each implemented unit of work (checked off)
- record the slices built for each outside-in item and every mode change, as "Modes and Slices in
  Progress" in "The Specification Structure" describes
- note any units remaining (if session ended early)
- record each result of the Acceptance Criteria Check, as "Acceptance in Progress" in "The
  Specification Structure" describes
- record any key decisions made during implementation (e.g., design choices, deviations from spec)
- list **Deferred refactorings**, each with every field under **What every finding states** in
  `systemic-refactoring.md`, its evidence as `path` — `Symbol`, and why it was deferred
- if the user skipped the final Systemic Design Checkpoint, say so in plain words: "the final design review was skipped"

## Red Flags to Watch For

If you catch yourself doing any of these, STOP immediately:
- ❌ Breaking the cycle in `tdd.md`: code before its failing test, more than one failing test, or
  logic no test demands
- ❌ Taking a step that doesn't match your uncertainty: jumping ahead when you don't yet see the
  design, or faking and triangulating when you already know what to type
- ❌ Committing without the per-commit gate, or against the commit message rules
- ❌ Merging two pieces of code because they look alike, without confirming they share a business meaning
- ❌ Cleaning up unrelated modules during a systemic checkpoint
- ❌ Running a broad codebase scan after every cycle
- ❌ Declaring the feature done without running the final Systemic Design Checkpoint or asking
  whether to skip it
- ❌ Growing a plan item's units before its automatable criteria have a red goal post
- ❌ Writing an edge case of an outside-in item before its first slice is connected through the entry
  point
- ❌ Calling a slice finished with a hardcoded value behind its acceptance test, or with a unit that has
  no tests of its own
- ❌ Ending the session without the Acceptance Criteria Check, or recording a criterion as met
  without its evidence
- ❌ Changing an acceptance criterion without the user's agreement
- ❌ Implementing past a significant misalignment the user has not decided on

## STOP — Skill Complete

When all units of work are implemented and committed, the Acceptance Criteria Check is done — and,
if this session finished the last plan items, the final Systemic Design Checkpoint has run or the
user chose to skip it:

1. **Update `SPEC.md`** with a `## Progress` section at the bottom, holding what "What Progress
   Records" lists

2. **Commit the progress update** (per the `SPEC.md` rule in `git-workflow.md` Special Cases):
   - squash or amend into the existing `docs: feature specification` commit if history is not yet pushed
   - if already pushed, add a new `docs: update feature specification` commit

3. **Hand off**, without asking again:
   - **plan items remain** → name them, and say that running `/aido:2-implement` again continues them.
     Do not call the implementation complete, and do not offer or mention organizing the commits
   - **Organize the commits** → once the progress update is committed, invoke
     `/aido:3-organize-commits`. This answer approves only starting that skill: all of its own questions
     still happen. If the work can't finish cleanly, do not start it, and tell the user why
   - **Stop here** → tell the user that implementation is complete, that they can run
     `/aido:3-organize-commits` later, and that running it in a new session gives it a fresh context
   - **nobody answered the question, or it couldn't be asked** → start nothing
