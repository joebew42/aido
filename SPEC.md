# Let uncertainty choose test-first inside-out or strict TDD outside-in, part by part

GitHub Issue: https://github.com/joebew42/aido/#31

## Context

The workflow applies one approach to all planned work: `/aido:1-plan` orders the plan inside-out, by
layer, and `/aido:2-implement` grows units with strict TDD while the acceptance tests stay red and
uncommitted until the end. `/aido:3-organize-commits` then shapes the history inside-out.

That fits work whose shape is already known, which upfront specification and planning make common.
It fits poorly where the plan rests on something nobody has run: mocks written from the plan agree
with it even when it is wrong, so a bad assumption surfaces only at the end, after the other layers
have been built on it. Strict TDD on parts that are already obvious is ceremony in the other
direction.

The recorded baseline shows the gap: on `implement-connects-the-slice-early`, agents connected the
entry point before the edge cases in 0 of 3 runs, with or without aido.

## Intent

Let uncertainty decide both step size and direction, part by part, at planning time, where the user
can review the decision. Implementation and commit organization then honour that decision.

Every feature item in a plan has one of three modes:

| What's unknown | Mode | Approach | The item states |
| --- | --- | --- | --- |
| Nothing: the part conforms to existing code or a known contract | `inside-out` | Test-first, layer by layer: one failing test at a time, going straight to the real implementation | The code or contract it conforms to |
| How the parts fit, or what an interface should be | `outside-in` | Strict TDD, in tracer bullet slices | The unknown, and its slices in order |
| Logic within one unit | `in-unit` | Strict TDD in that unit, with no direction to choose | The unknown |

For example:

```markdown
1. **refactor: extract the task store** (enabling)
2. **complete a task** (AC1) — inside-out: follows `add_task` in `lib/tasks.sh`
3. **sync tasks to the calendar** (AC2, AC3) — outside-in: the provider's error responses are unconfirmed
   - slice 1: a completed task reaches the provider, through the authorization check
   - slice 2: a rejected sync is reported to the user
4. **repeat a task monthly** (AC4) — in-unit: the month-end rule is unsettled
```

Inside-out stays the default, but it has to be earned: a part is inside-out only if the plan can cite
what it conforms to, because agents tend to over-label work as obvious. Otherwise the plan names the
unknown.

Outside-in history is slice-shaped rather than literally outside-in, because an outer commit calling
code from a later commit would fail the per-commit gate. The plan is a decision that can prove wrong,
so implementation may change a part's mode, and commit organization follows what was actually built.

## Out of scope

- Slices as the default for all work
- Changing the commit message format, the `SPEC.md` first and last commits, or the per-commit gate
- Modes on the phases of a multi-phase main plan: each phase's items get them when `/aido:1-plan`
  plans that phase
- Tooling that enforces the merge rule in AC16: it is guidance, and no skill or hook blocks a merge
- `/aido:verify` judging whether the right mode was chosen or followed
- Changes to `/aido:5-handle-review`

## Acceptance criteria

- AC1: every feature item (any item not marked `(enabling)`) in a plan produced by `/aido:1-plan`
  names its mode, `inside-out`, `outside-in` or `in-unit`, and the reason for it, including on the
  Small-Change Route
- AC2: an inside-out item cites existing code or a known contract it conforms to, and an outside-in
  or in-unit item names its unknown
- AC3: `/aido:2-implement` connects the entry point of an outside-in item before its edge cases, and
  grows an inside-out item layer by layer
- AC4: when `/aido:2-implement` changes a part's mode, it tells the user and records the change, with
  its reason, in `## Progress`
- AC5: `/aido:3-organize-commits` produces slice-shaped history for outside-in parts and inside-out
  history for inside-out parts, taking each part's mode from `## Progress`, then from the plan, then
  defaulting to inside-out
- AC6: with no plan, spec or mode, `/aido:3-organize-commits` organizes commits inside-out
- AC7 (manual): `tdd.md`, `git-workflow.md`, `specification.md` and `/aido:stabilize` describe the
  same three modes, and no longer present strict TDD as the mandatory mode for all work
- AC8: an outside-in item in a plan lists its slices in order, with any guard such as authorization
  in the first slice
- AC9: `/aido:1-plan` orders a plan with enabling refactorings first, then by dependency, with an
  outside-in item before any inside-out item relying on the contract it discovers, and each item
  names the layers it touches
- AC10: in an inside-out item, `/aido:2-implement` writes one failing test at a time and goes
  straight to the real implementation; in an in-unit item, and in the units of an outside-in slice,
  it uses strict TDD
- AC11: an outside-in slice is finished only when its acceptance test is green against real code and
  every unit it added has its own tests
- AC12: `/aido:2-implement` commits a slice's acceptance test with that slice once it is green, and
  an inside-out item's acceptance test last, as it does today
- AC13: `/aido:2-implement` treats a plan item with no mode as inside-out, without asking
- AC14: `/aido:2-implement` records the slices it actually built for each outside-in item in
  `## Progress`
- AC15: `/aido:3-organize-commits` gives each slice one group of commits, inside-out within it and
  closed by the slice's acceptance test, and squashes a part's unpushed schema changes into one
  migration commit in the first slice that needs it
- AC16 (manual): the guidelines say that a phase merges only as a complete set of slices
- AC17: `/aido:verify` does not report a mode change recorded in `## Progress` as a deviation from
  the plan
- AC18: the items of a `/aido:stabilize` plan name their mode and reason as `/aido:1-plan` does, for
  both strategies, with a carry-over item normally inside-out and citing the original work
- AC19 (manual): the README and `docs/evals.md` describe the modes and the eval cases as they now are
- AC20: the evals have a tagged outside-in `implement-connects-the-slice-early`, a matching
  inside-out `implement` case, a check that a slice's inner units have their own tests, at least one
  `/aido:3-organize-commits` case, and a `/aido:1-plan` case that checks an item's mode and reason
- AC21: with aido, `connects-before-the-edge-cases` passes in at least 2 of 3 runs, against 0 of 3 in
  the baseline
- AC22: once the new results are recorded, `docs/evals/tracer-bullet-baseline.md` and the "Reference
  baseline" section of `docs/evals.md` are gone, with one line there keeping the 0 of 3 figure

## Plan

Layers, in this repository's terms: guidelines hold the rules (domain), skills apply them
(application), and evals, the runner and docs are the outer edge (infrastructure). This plan follows
the modes it introduces.

1. **refactor: move the plan-item format to one place** (enabling) — guideline, skill: layers, order
   and `(enabling)` move to "Plan Items" in `specification.md`; `/aido:1-plan` Step 6 and
   `/aido:stabilize` Step 5 refer to it
2. **refactor: give each test-mode rule one owner** (enabling) — guideline, skill: `2-implement`'s
   opening refers to `tdd.md`, `tdd.md` leaves commit timing to `git-workflow.md`, and "test-first"
   gets one meaning in `tdd.md`
3. **refactor: let an eval case name its shell check** (enabling) — infrastructure: `run_case` in
   `tests/evals.py`, tested in `tests/test_evals.py`, keeping `behaves-as-specified` for the existing
   case
4. **implement an outside-in item** (AC3, AC10, AC11, AC12, AC14) — outside-in: whether skill wording
   moves agents off the 0 of 3 baseline is unconfirmed, and the other items rely on the answer. Touches
   guidelines, skills and evals
   - slice 1: the three modes in `tdd.md`, `/aido:2-implement` following an outside-in item's slices,
     and the `implement-connects-the-slice-early` fixture's plan marked outside-in; check with a quick
     one-run eval, after asking
   - slice 2: a goal post per slice, committed with it (`git-workflow.md`, `/aido:2-implement`), with a
     new check that a slice's inner units have their own tests
   - slice 3: the slices built are recorded in `## Progress`, in lines `specification.md` defines
5. **implement an inside-out and an in-unit item** (AC3, AC10, AC12, AC13, AC20) — inside-out: follows
   the outside-in path from item 4 and today's goal posts in `/aido:2-implement`. Touches the skill and a
   new inside-out twin of the fixture from `implement-connects-the-slice-early`
6. **change a part's mode during implementation** (AC4, AC17) — inside-out: follows the `deferred` and
   `changed` lines in "Acceptance in Progress" (`specification.md`) and "How to read the specification"
   in `/aido:verify`. Touches guideline, skills
7. **plan items name their mode** (AC1, AC2, AC8, AC9, AC20) — inside-out: extends "Plan Items" from
   item 1. Touches `specification.md`, scoped so a main plan's phases are not covered; `/aido:1-plan`
   Step 6 and the Small-Change Route, which start loading `tdd.md`; and a new plan case grading the
   written `SPEC.md`
8. **stabilize plans name their mode** (AC7, AC18) — inside-out: follows `/aido:1-plan` from item 7.
   Touches `/aido:stabilize`, which starts loading `tdd.md`
9. **organize commits by mode** (AC5, AC6, AC7, AC15, AC16, AC20) — inside-out: follows "Commit
   Organization Strategy" in `git-workflow.md`, which stays the owner of commit shape. Touches
   `git-workflow.md`, `/aido:3-organize-commits`, and new cases checking final history with a named
   shell check, one per mode and one with no plan
10. **docs and version** (AC7, AC19) — inside-out: follows the existing README and `docs/evals.md`.
    Touches both, and bumps `plugin.json` to 4.2.0
11. **measure and retire the baseline** (AC21, AC22) — inside-out: follows "How to run them" in
    `docs/evals.md`. Asks before running the matching cases, commits the results they update, then
    removes the baseline

## Design notes

- **Where it belongs:** what each mode is and how to work in it: "Test-First vs. Strict TDD" in
  `tdd.md`. How a plan item states it, and the new `## Progress` lines: `specification.md`, "Plan
  Items" and "Acceptance in Progress". Commit shape per mode: "Commit Organization Strategy" in
  `git-workflow.md`. Skills keep only their steps
- **Existing behaviour and abstractions to reuse:**
  - `plugins/aido/guidelines/tdd.md` — "obvious implementation" is the inside-out step
  - `plugins/aido/guidelines/specification.md` — "Specifications Without Acceptance Criteria" is the
    precedent for defaulting without asking (AC13)
  - `plugins/aido/skills/verify/SKILL.md` — "How to read the specification" takes the AC17 line
  - `tests/evals.py` — `OrderWatch`, `passes_acceptance` (the workspace keeps `.git`, so history can be
    checked), `grader_target` (a grader can read `SPEC.md`)
  - `plugins/aido/evals/implement-connects-the-slice-early/fixture.sh` — the fixture pattern
  - the `implement-*` prompts — how a case runs unattended
- **Boundaries that must hold:**
  - `specification.md` is the only definition of the structure; skills refer to it
  - `/aido:3-organize-commits` does not load `tdd.md`, so `specification.md` and `git-workflow.md` must
    be enough for it; `/aido:1-plan` and `/aido:stabilize` load neither today and will load `tdd.md`
  - a `multi-phase-spec-pr` plan refers to "Plan Items" and must not gain modes
  - the commit message format, the first and last `SPEC.md` commits and the per-commit gate stay as
    they are
- **Other modules or consumers affected:** `/aido:4-create-pr` reads `## Progress` only for `deferred`
  criteria, so new lines must stay distinct; `README.md` lines 143 and 257; `docs/evals.md` case table
  and baseline section; `docs/evals/latest.json`, keyed by grader name
- **Enabling refactorings (planned):** items 1 to 3. Items 1 and 2 are wording only, so they need no
  evals. Items 1 and 2 span modules; approving this plan approves them
- **Deferred:** none
- **Open questions:** none that block implementation. Settled for the plan: the ordering rule goes in
  "Plan Items", because two skills write plans; `/aido:stabilize` and `/aido:1-plan` load `tdd.md`, so
  the modes have one definition; in AC20, an outside-in fixture means its plan item names the mode, not
  a `case.yaml` tag, which the runner does not read; a `/aido:3-organize-commits` case runs its rebase
  unapproved, as the `implement-*` cases skip their questions, because nobody is there to answer

## Progress

Done: items 1 to 10. Remaining: item 11, because the user chose not to run the billed evals in this
session. The final Systemic Design Checkpoint is not due until item 11 is done.

- Item 4 slices built: the modes in `tdd.md` and `/aido:2-implement` following an item's slices, with
  the fixture's plan marked outside-in; a goal post per slice with the inner-units check; slices
  recorded in `## Progress`

Acceptance criteria:

- AC7: met — confirmed by the user: the modes in `tdd.md`, `git-workflow.md`, `specification.md` and
  `/aido:stabilize`, and the renamed "MANDATORY: One Test at a Time"
- AC16: met — confirmed by the user: the line in "Shape by Mode" in `git-workflow.md`
- AC19: met — confirmed by the user: the README's new section and `docs/evals.md`'s case table
- AC20: met — the cases exist; the shell checks were run against hand-built histories, each passing
  only its own shape; `python3 tests/test_evals.py` passes
- AC1, AC2, AC3, AC5, AC6, AC8, AC9, AC10, AC11, AC15: unchecked — instructions and eval cases are in
  place, but the cases have not run with 3 runs per arm
- AC4, AC12, AC13, AC14, AC17, AC18: unchecked — instructions are in place, with no eval case that
  checks them, which the PR must say. AC15's squash of schema changes has no case either
- AC21, AC22: unchecked — their plan item is not done

Key decisions and evidence for item 11:

- the one-run check of `implement-connects-the-slice-early` passed `connects-before-the-edge-cases`
  1/1 in **both** arms, $2.81 in all, not recorded. The plain arm never loads the skill, so the
  fixture's listed slices may be what moved it, and AC21's comparison with the 0 of 3 baseline may not
  be like for like. Look at the with and without figures together before relying on AC21
- `in-unit` has no eval of its own
- the organize cases share `plugins/aido/evals/organize-history.sh` and
  `organize-history-checks.sh`, because they need the same history
