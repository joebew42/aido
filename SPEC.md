# Give acceptance results their own section in a spec's Progress

GitHub Issue: https://github.com/joebew42/aido/#71

## Context

In a spec's `## Progress`, the acceptance results come straight after the last item's sub-bullets,
with no break or label, so they read as part of that item. "Acceptance in Progress" in
`specification.md` says what each line contains, but not where the lines go.

## Intent

The acceptance results get their own `### Acceptance` heading inside `## Progress`, after the items
and the other notes. Anything that looks for the results under `## Progress` still finds them.

## Out of scope

- rewriting the specs of features already finished
- changing what an acceptance line says (`met`, `changed`, `deferred`, `unchecked`)
- the other lines in `## Progress`: items, modes and slices, deferred refactorings, the final design
  review's note

## Acceptance criteria

- AC1: When `/aido:2-implement` records acceptance results, they sit under `### Acceptance`, the last
  heading in `## Progress`.
- AC2: When the loop ends before the plan does, the `unchecked` criteria also sit under
  `### Acceptance`.
- AC3: "Acceptance in Progress" in `specification.md` says where the results go, with an example.
- AC4: Every eval fixture whose spec records acceptance results puts them under `### Acceptance`.
- AC5: The eval check for the loop fails when the results are not under `### Acceptance`.

## Plan

This repository has no code layers. Each item names the files it touches instead: guidelines,
skills, evals or tests. Every rewrite conforms to the text it extends, so feature items are
`inside-out`. The free checks (`tests/hooks.sh`, `tests/skills.sh`, `tests/test_skills.py`,
`tests/test_evals.py`) are the tests: each item ends with them passing.

1. **say where the acceptance results go** (AC3) — inside-out: follows "Items in Progress" in
   `specification.md`, which already says where its lines go. Touches guidelines. "Acceptance in
   Progress" says the lines go under `### Acceptance`, which comes last in `## Progress`, and shows
   a short example after an item with sub-bullets. A spec with no results has no such heading.
2. **record the results under the heading** (AC1, AC2) — inside-out: follows "What Progress
   Records" in `2-implement`. Touches skills. Its acceptance bullet, and "Finish `## Progress`",
   name the `### Acceptance` heading and that it comes last. "To record the items left" points to the
   same place for `unchecked`. `3-organize-commits`, `4-open-pr` and `verify` read the lines through
   "Acceptance in Progress" and need no change: check them, and pin a phrase in `tests/skills.sh` if
   the new wording should stay.
3. **move the fixtures' results under the heading** (AC4) — inside-out: follows the format from
   item 1. Touches evals. The seven fixtures: `organize-offers-the-pr`,
   `implement-review-records-refactorings`, `implement-loop-runs-a-refactoring`,
   `implement-offers-to-organize`, `implement-offers-a-fresh-context`, `verify-accepts-a-real-test`,
   `verify-catches-a-test-that-cannot-fail`. In `implement-loop-runs-a-refactoring`, the design
   review note moves above the heading.
4. **check the heading in the loop's eval** (AC5) — inside-out: follows the `grep` checks in
   `implement-loops-over-the-plan/checks/each-item-is-recorded.sh`. Touches evals. The check also
   requires `### Acceptance` under `## Progress`, with `AC1: met` and `AC2: met` after it. Try it on
   a spec with and without the heading.
5. **bump the version and run every check** (AC1–AC5) — inside-out: follows the release convention
   in `AGENTS.md`. Touches the plugin manifest. Bump `version` to 5.6.0, run the free checks and both
   `claude plugin validate` commands.

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. say where the acceptance results go
  - "Acceptance in Progress" in `specification.md` puts the lines under `### Acceptance`, last in
    `## Progress`, with an example; `tests/skills.sh` pins the wording
- [x] 2. record the results under the heading
  - `2-implement` names `### Acceptance`, last in `## Progress`, in "What Progress Records",
    "Finish `## Progress`" and "To record the items left"; `tests/skills.sh` pins the wording
  - `3-organize-commits`, `4-open-pr` and `verify` read under `## Progress`, which still holds the
    heading, so they are unchanged
- [x] 3. move the fixtures' results under the heading
  - the seven fixtures put their acceptance lines under `### Acceptance`; in
    `implement-loop-runs-a-refactoring` the design review note stays above it
  - `tests/skills.sh` now fails when a fixture records acceptance results outside the heading, or
    puts anything after them; `tests/test_skills.py` covers both cases
- [x] 4. check the heading in the loop's eval
  - `each-item-is-recorded.sh` looks for `AC1: met` and `AC2: met` only after `### Acceptance`
    under `## Progress`; `tests/test_evals.py` runs it on a finished spec with and without the heading
- [x] 5. bump the version and run every check
  - `version` is 5.6.0; the free checks and both `claude plugin validate` commands pass
- the final design review was skipped

### Acceptance

- AC1: met — `tests/skills.sh` pins "under `### Acceptance`, the last heading in `## Progress`" in
  `2-implement`; the agent's behaviour is measured by the loop eval at the next full round
- AC2: met — `tests/skills.sh` pins "with the criteria only they serve as `unchecked` under
  `### Acceptance`" in `2-implement`
- AC3: met — `tests/skills.sh` pins the placement and the no-results rule in `specification.md`,
  next to the example
- AC4: met — `tests/skills.sh` checks every fixture; `tests/test_skills.py` covers the failing cases
- AC5: met — `LoopRecordsEachItem` in `tests/test_evals.py` runs the check with and without the heading
