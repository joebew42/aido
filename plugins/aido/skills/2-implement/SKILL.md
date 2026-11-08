---
description: Implements the feature using TDD. Invoked when the user wants to implement the feature, start TDD, begin red-green-refactor, or runs /aido:2-implement.
disable-model-invocation: false
---

# Implement the Feature

Build the feature from its specification, one small step at a time, with **test-driven
development**, in the mode each plan item names.

Resolve `SPEC.md` and `SPEC.md.draft` first, as "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

**The argument** decides what this session does:

- **nothing, or anything but the two below** → a single session, as this skill describes
- **`loop`, or `loop <first>-<last>`, such as `loop 7-9`** → this session is the **orchestrator**.
  It runs each plan item in a child, as "Loop Mode" describes. `loop r<N>`, or `loop r<first>-r<last>`,
  such as `loop r1-r3`, runs refactorings from `## Refactorings` the same way
- **`item <N>`** → this session is a **child** the orchestrator started for plan item `<N>`, or for
  refactoring `r<N>`, as "Child Mode" describes

## Step 0: Load Context

Before any implementation work:

- no `SPEC.md` → stop. If only `SPEC.md.draft` exists, tell the user the specification isn't
  approved yet, and to run `/aido:1-plan`
- `SPEC.md.draft` next to `SPEC.md` → act as "The Specification File" in
  `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` says
- read `SPEC.md` for the full scope
- check whether it has numbered acceptance criteria (`AC1`, `AC2`, …), as "The Specification
  Structure" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. With none, skip
  everything below about acceptance criteria: goal posts, the Acceptance Criteria Check and their
  Progress lines. Don't ask about them

### Global guidelines (always load)

Load these once. They apply to every stack:

- `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/testing-principles.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`

### Project conventions

Gather the host repository's conventions as `project-conventions.md` describes.

Before the first test, know how to run a single test, the relevant suite and the linter in this
project. If you can't find one of them, ask the user.

Don't read the guidelines again while they are still loaded. After the conversation is compacted they
may not be: read them again. When a single session runs this skill again with work in progress, skip
Steps 0.5 and 1, and continue from the next unit. `git log` and `SPEC.md` show where the work stands.

## Step 0.5: Check the Alignment with the Repository

The default branch may have moved since the specification was approved. Check this at the start of
every session, before anything else is decided:

1. run `git fetch origin`, then list what the default branch has and this branch doesn't:
   `git log --name-only --format='%h %s' HEAD..origin/<default-branch>`. If the fetch fails, say the
   check could not run, and continue at Step 1
2. those commits are **relevant** when they touch a file the specification names, in any section,
   or an agent instruction file (`CLAUDE.md`, `AGENTS.md`)
3. **nothing relevant** → say so in one line, and continue at Step 1. Launch no subagent and read no
   more code
4. **something relevant** → read those changes against the specification and its plan, as
   `${CLAUDE_PLUGIN_ROOT}/guidelines/repository-alignment.md` describes:
   - a conflict with the repository, including a constraint planning missed, pauses the work until
     the user chooses, as "When It Is Significant" in
     `${CLAUDE_PLUGIN_ROOT}/guidelines/repository-alignment.md` describes. Commit a change to `SPEC.md`
     by the `SPEC.md` rule in "Special Cases" in `git-workflow.md`. **Reject it** stops the skill
   - a lesser mismatch doesn't stop the session. Mention it, and handle it when its plan item comes up

## Step 1: Confirm Implementation Scope

An orchestrator or a child skips this step: the argument already chose the items.

Use `AskUserQuestion` to show every unfinished plan item, then every unfinished refactoring in
`## Refactorings`, each plan item with the acceptance criteria it serves. The first of them is the next
logical one. Ask:

> "Which items should I do in this session? (all / specific items / the next logical one)"

Wait for the answer before you start.

## Loop Mode

The orchestrator builds nothing itself. Each plan item runs in a fresh child, which sees the full
specification and guidelines. Only the orchestrator writes `SPEC.md`.

**Before the first child**, run Step 0 and Step 0.5 once. Then choose the items to run, in plan order:

- **`loop`** → every plan item not done, then every refactoring not done, as "Items in Progress" in
  `specification.md` describes
- **a range** → the items in it. Skip those already ticked in `## Progress`, and name them
- **`r<N>`, or a range of refactorings** → those refactorings, in the same way
- **a range that names an item the plan doesn't have** → don't start the loop, and say why
- **a refactoring code `## Refactorings` doesn't have** → don't start the loop, and say why

Show the items it will run, each with the criteria it serves, and ask nothing.

**For each item, in order:**

1. launch one `Agent`, with no model override. Brief it with:
   - the repository root, the `SPEC.md` path, and the item's number or the refactoring's code
   - to invoke `/aido:2-implement item <N>` with the `Skill` tool, and follow it. For a refactoring,
     `<N>` is its code, such as `item r1`
   - to return only what "Child Results" lists
2. when it returns, check three things:
   - its results give each criterion the item serves as `met`, `changed` or `deferred`. A refactoring
     serves none
   - the working tree is clean
   - lint and the whole test suite pass
3. **all three pass** → record the item in `## Progress` from the child's results, as "What Progress
   Records" lists, and tick it as "Items in Progress" in `specification.md` describes. For a `changed`
   criterion, also update its wording in `## Acceptance criteria`, keeping its ID. Add each
   refactoring the child planned for later to `## Refactorings`, with the next free code. Commit it by
   the `SPEC.md` rule in "Special Cases" in `git-workflow.md`, then start the next item's child
4. **one fails** → stop the loop. Report what failed, and the items not yet run. Tick nothing for
   the failed item, and record the items left

**After the last item it runs:**

- **every plan item and refactoring is done** → ask about the final design review and organizing the
  commits in one question, as "The final design review" describes. Once the review has run, ask only
  about organizing. Run the review here, if chosen, then finish as "STOP — Skill Complete" describes.
  Each item's Progress is already committed
- **the range ends before the plan does** → record the items left, name them, and say that running
  `/aido:2-implement loop` again continues them. Ask about neither. Refactorings not done count as
  items left

**To record the items left**, whenever the loop ends before the plan does, add them to `## Progress`
as units remaining, with the criteria only they serve as `unchecked` under `### Acceptance`, as
"What Progress Records" lists. Commit it by the `SPEC.md` rule in "Special Cases" in `git-workflow.md`.

**When a child returns a question** instead of its results, it has paused. Ask the user with
`AskUserQuestion`, with the child's question and options. Send the answer to that same child with
`SendMessage`, and wait for it to return again. When nobody answers, or the question can't be asked,
stop the loop: name the paused item, its question and the items not yet run. Tick nothing for the
paused item, record the items left, and offer nothing else.

**Whenever the loop ends before "STOP — Skill Complete"**, after a failed check, at the end of a range
or on a paused question, end as item 4 of "STOP — Skill Complete" describes.

## Child Mode

A child builds plan item `<N>`, or refactoring `r<N>`, and nothing else:

- run Step 0, then go straight to the item. Skip Step 0.5 and Step 1
- build it as the sections from "Work in the Item's Mode" to "Commits" describe. Its Acceptance
  Criteria Check covers the criteria item `<N>` serves
- **never edit `SPEC.md`**. Wherever this skill says to record something in it, put it in the results
  instead
- skip the final design review and "STOP — Skill Complete". End by returning what "Child Results"
  lists, with no ending block
- **a child can't ask the user.** Wherever this skill says to ask with `AskUserQuestion`, end your
  turn by returning the question instead: the item's number, the question, and each option with what
  it does. Return nothing else, and carry on from the answer the orchestrator sends back
- wherever this skill says to tell the user something, put it in the results instead

### Child Results

- the item's number, and the commits it made
- what "What Progress Records" lists, for this item only, except the final design review's note
- for a `changed` criterion, the wording the user agreed
- each refactoring planned for later, with every field under **What every finding states** in
  `systemic-refactoring.md`
- anything this skill told the child to tell the user

## Work in the Item's Mode

Each feature item names its mode, as "The Modes" in `tdd.md` defines them. Work the item in that mode.
An item with no mode comes from a plan older than modes: treat it as inside-out, and don't ask.

In an `outside-in` item, connect the first slice through the real entry point before any edge case.
The entry point calls the feature, and reaches only the first slice's behaviour.

A refactoring from `## Refactorings` has no mode, and no goal post. Build it within **Boundaries** in
`systemic-refactoring.md`. Before changing code no test covers, add the test first. Then change it in
small steps, with the tests green after each. Commit it as "Committing systemic refactorings"
describes.

**When the plan proves wrong**, change the part's mode rather than keep one that no longer fits: an
inside-out part hides an unknown, or an outside-in part has nothing left to discover. Tell the user in
one line, without asking, and record it as "Modes and Slices in Progress" in "The Specification
Structure" describes.

## Acceptance Criteria as Goal Posts

The acceptance criteria are the outer loop, as "The Modes" in `tdd.md` describes. An outside-in item
has one goal post per slice. Before growing the units of a plan item or slice:

- [ ] for each **automatable** criterion the item serves that no test covers yet, write its
      acceptance test first, at the boundary where the behaviour shows
- [ ] run it, and confirm it fails for the **right reason**: the behaviour is missing, not the test
      broken
- [ ] keep it red while the units behind it grow. It doesn't count as one of the inner loop's
      failing tests
- [ ] don't commit it while it is red. The per-commit gate skips it: the units committed meanwhile
      need their own tests and the existing suite green
- [ ] commit it once green, where "Shape by Mode" in `git-workflow.md` says: with its slice for an
      outside-in item, last otherwise
- [ ] criteria marked `(manual)` get no test. The Acceptance Criteria Check confirms them

When a test older than this feature already covers the criterion, name it and move on. Don't write
a duplicate.

## MANDATORY: Tests Before Code

Grow each unit through the cycle in `${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md`, at the step size
"Step Size" in `${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md` gives it, until it is fully specified.

Work through each unit without stopping to present each test cycle, in every mode. Once a unit is
committed, tell the user in a few lines what it does and which tests cover it.

In REFACTOR, once per unit, also check:

- the Dependency Rule: no outward dependency added (application or domain code naming anything in
  infrastructure), and no decisions left in infrastructure
- that the code follows the guidelines loaded in Step 0. Don't read them again

When a test cycle or the refactoring shows a concept that may be shared, a duplicated business rule
or a crossed boundary, run a **design check** (below) on green, before going on.

**Unit done:** every behaviour the plan gives the unit has a test, all are green, they failed with
its production changes set aside, and it is refactored. Commit the unit, then move to the next one.

**Item done:** once every unit of a plan item or a refactoring is committed, a single session ticks
it in `## Progress`, as "Items in Progress" in `specification.md` describes. With it, it records
its units, any mode change, the slices built and the key decisions, as "What Progress Records"
lists. The acceptance criteria wait for the end of the session. Then commit that before starting the
next item, by the `SPEC.md` rule in "Special Cases" in `git-workflow.md`. A child puts all this in its
results instead, and the orchestrator records it.

## Design Checks

The REFACTOR step looks at the code just written. The **design check** during a cycle and the **final
design review** before completion look beyond it. Their rules are in
`${CLAUDE_PLUGIN_ROOT}/guidelines/systemic-refactoring.md`. Read it the first time either runs. Both run in every mode, and **never** as a broad scan after every cycle.

### Starting context

- the spec's `## Design notes`, if `/aido:1-plan` wrote them
- the architecture index, if there is one, read as **Reading the Index** in
  `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md` describes. Search it, don't load it. Never
  offer to build or update it here: that belongs to planning
- the diff, and a few searches for the domain's own words and symbols

### The design check, during TDD — session model

Run it inline, on green, limited to what the cycle showed:

1. read the code it points to, and confirm the design problem is real
2. classify it: **fix now**, **refactor now**, **defer** or **no action**
3. make fix-now and refactor-now changes in small steps, running the relevant tests after each
4. before a refactoring that touches another module, ask with `AskUserQuestion`, showing the
   finding as **Showing a finding** in `systemic-refactoring.md` describes —
   options **Refactor now** / **Plan it for later** / **Defer** / **No action**. On **Plan it for
   later**, add it to `## Refactorings` with the next free code, as "Refactorings" in
   `specification.md` describes. Commit it by the `SPEC.md` rule in "Special Cases" in
   `git-workflow.md`, and carry on with the unit
5. note deferred findings for `## Progress`, with every field under **What every finding states** in
   `systemic-refactoring.md`. Park them as **Parking an opportunity** in `systemic-refactoring.md`
   describes, then carry on with the unit

### The final design review — `fable` subagent

Run it after the Acceptance Criteria Check below, so it reviews any code the check added. Once every
plan item and refactoring is done, it is due over the whole feature. A partial session doesn't run
it. It runs once: when `## Progress` says it ran or was skipped, it is not offered again, and the
question below offers only the next step. It can take long and isn't always needed, so ask first.
`AskUserQuestion`: "Should I run a final design review over the whole feature?" — options
**Run the review** / **Skip it**:

- mark **Run the review** as recommended when the diff against the default branch touches more than one
  module or area, or adds a new domain concept or abstraction. Otherwise mark **Skip it** as
  recommended. Diff size alone doesn't count
- say briefly in the question why the recommended option is recommended
- on **Skip it**, launch nothing. Note the skip for `## Progress`, and go on to completion

In the same `AskUserQuestion` call, offer the next step, as "Asking Questions" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes. "STOP — Skill Complete" acts on the answer: "Once
implementation is complete, should I organize the commits?" — options **Organize in a fresh context**
(recommended) / **Organize the commits** / **Stop here**. The question names each criterion recorded
as `deferred`, so the user notices it before going on.

On **Run the review**, launch one `Agent` with `model: "fable"`. Brief it with
"The Shared Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`, and:

- the repository root and the diff range (`git diff origin/<default-branch>...HEAD`)
- the `SPEC.md` path. When it has `## Design notes`, ask the subagent to check them against what was
  built, and to say where they no longer hold
- if there is an index, its directory and the **Reading the Index** steps from
  `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md`, copied in full
- "The Design-Check Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`
- to return only findings, each with its **Classification** and every field under **What every
  finding states** in `systemic-refactoring.md`, or one line saying it found none

If `fable` is unavailable, act as "When the Model Is Unavailable" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`.

Then, in this session:

1. confirm each finding before acting on it, as **Evidence before action** in
   `systemic-refactoring.md` describes
2. show the findings as **Showing a finding** in `systemic-refactoring.md` describes, and ask with
   `AskUserQuestion` what to do with each — options **Plan it for later** / **Defer** / **No action**
3. add each one planned for later to `## Refactorings` with the next free code, as "Refactorings" in
   `specification.md` describes. Change no code: each one is built later, like a plan item
4. note the deferred ones for `## Progress`, and park them as **Parking an opportunity** in
   `systemic-refactoring.md` describes
5. when any are planned, note it for `## Progress`, then finish as "STOP — Skill Complete"
   describes. Refactorings now remain, so the answer about organizing the commits is not acted on:
   the session that finishes them asks again

### Committing systemic refactorings

Follow the stand-alone refactoring rule in `git-workflow.md`, loaded in Step 0.

When a plan item names a parked refactoring opportunity, remove its file once the refactoring is
committed, and tell the user.

## Acceptance Criteria Check

Check the acceptance criteria before the session ends, and before the final design review when the
last plan items are done. This checks the specification's intent, not only the plan.

**Which criteria:**

- every plan item is built → every criterion in `SPEC.md`
- a partial session → only the criteria whose plan items are all done. The rest are recorded as
  `unchecked`
- a criterion already recorded as `met`, `changed` or `deferred` keeps that result. A session that
  builds only refactorings runs the tests that cover the criteria again, and asks nothing again

**For each criterion:**

- **automatable** → name the green test that covers it, and run it if it hasn't run since the last
  change. A test that covers only part of the criterion doesn't meet it
- **manual** → show the user the evidence from the change, such as the file, the output or what a
  person would see, and ask with `AskUserQuestion` — options **Confirmed** / **Not met**

**For each criterion that is not met**, ask with `AskUserQuestion`, showing what is missing —
options:

- **Implement it now** — add what is missing with a new goal post and test cycles, then check it
  again
- **Change the criterion** — agree the new wording with the user, update it in `SPEC.md`'s
  `## Acceptance criteria` (keeping its ID), and check it again against the new wording
- **Defer it** — leave it unmet, with the reason

Note each result for `## Progress`. Never record a criterion as met without its
evidence.

## Quality Checks

Apply "Before Every Commit" in `git-workflow.md` before every commit. Don't commit otherwise.

## Commits

Commit each unit as it is done, as "Commit Organization Strategy" in `git-workflow.md` describes:
with its tests, in the shape "Shape by Mode" gives the item. `/aido:3-organize-commits` shapes the
final history, not this skill.

## What Progress Records

The `## Progress` section of `SPEC.md` is a short note for the next session:

- each unit built, checked off
- tick each item that is done, plan item or refactoring, as "Items in Progress" in
  `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes
- the slices built for each outside-in item, and every mode change, as "Modes and Slices in Progress"
  in "The Specification Structure" describes
- the units remaining, if the session ended early
- each result of the Acceptance Criteria Check, under `### Acceptance`, the last heading in
  `## Progress`, as "Acceptance in Progress" in "The Specification Structure" describes
- the key decisions made while building, such as design choices or departures from the specification
- **Deferred refactorings**, each with every field under **What every finding states** in
  `systemic-refactoring.md`, its evidence as `path` — `Symbol`, and why it was deferred
- if the user skipped the final design review, say so in plain words: "the final design review was skipped"
- if the final design review planned refactorings, say so with their codes: "the final design review
  ran and recorded r1, r2"

## Red Flags to Watch For

If you catch yourself doing any of these, STOP:

- ❌ Breaking the cycle in `tdd.md`: code before its tests, a hardcoded value to pass a test, or
  logic no test demands
- ❌ A step that doesn't match your uncertainty: writing a unit's tests together when it isn't a
  contract, a mapping or a DTO, or when it relies on existing code
- ❌ Committing a unit whose new tests were never seen failing with its production changes set aside
- ❌ Committing without the per-commit gate, or against the commit message rules
- ❌ Merging two pieces of code because they look alike, without confirming they mean the same thing
  to the business
- ❌ Cleaning up unrelated modules during a design check
- ❌ Running a broad scan of the code after every cycle
- ❌ Calling the feature done without running the final design review or asking whether to skip it
- ❌ Growing a plan item's units before its automatable criteria have a red goal post
- ❌ Writing an edge case of an outside-in item before its first slice runs through the entry point
- ❌ Calling a slice finished with a hardcoded value behind its acceptance test, or with a unit that has
  no tests of its own
- ❌ Ending the session without the Acceptance Criteria Check, or recording a criterion as met
  without its evidence
- ❌ Changing an acceptance criterion without the user's agreement
- ❌ Building past a conflict with the repository the user hasn't decided on
- ❌ Applying a refactoring the final design review found, instead of adding it to `## Refactorings`

## STOP — Skill Complete

The skill is complete when every unit is built and committed, the Acceptance Criteria Check is done,
and, if this session finished the last plan items or refactorings, the final design review has run,
now or earlier, or the user chose to skip it:

1. **Finish `## Progress`**. Each item done is already recorded there, as "Item done" describes, so
   don't write it again. Add the rest of what "What Progress Records" lists: the results of the
   Acceptance Criteria Check, the units remaining, the deferred refactorings and the final design
   review's note. The acceptance results go under `### Acceptance`, after everything else. When
   `SPEC.md` has no `## Progress` section yet, add it at the bottom

2. **Commit the progress update**, by the `SPEC.md` rule in "Special Cases" in `git-workflow.md`

3. **Hand off**, without asking again:
   - **plan items or refactorings remain** → name them, and say that running `/aido:2-implement` or
     `/aido:2-implement loop` continues them. Don't call the implementation complete, and don't offer
     or mention organizing the commits
   - **Organize the commits** → once the progress update is committed, start
     `/aido:3-organize-commits`, as **Hand-off Outcomes** in `git-workflow.md` describes
   - **Organize in a fresh context** → once the progress update is committed, act as
     **Hand-off Outcomes** in `git-workflow.md` describes
   - **Stop here**, or no answer → tell the user the implementation is complete, then act as
     **Hand-off Outcomes** in `git-workflow.md` describes

4. **End** as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, also when the
   session stops early. With plan items or refactorings left, `Needs you` names only running
   `/aido:2-implement` or `/aido:2-implement loop`
