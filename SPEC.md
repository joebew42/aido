# `/aido:2-implement` updates Progress after every item

GitHub Issue: https://github.com/joebew42/aido/#63

## Context

In `loop` mode, the orchestrator ticks each item in `## Progress` as soon as it is done. A single
session writes `## Progress` only once, when it ends. If a single session is cut off partway, the
specification does not show which items are already done.

## Intent

A single session updates `## Progress` each time it finishes an item, so the specification always
shows what is done, whatever mode the implementation runs in. Acceptance criteria are still checked
when the session ends.

## Out of scope

- checking acceptance criteria after each item: that stays at the end of the session
- changing how `loop` mode records progress, or letting a child edit `SPEC.md`

## Acceptance criteria

- AC1: When a single session finishes a plan item, it ticks that item in `## Progress` and commits
  the change before starting the next item.
- AC2: When a single session finishes a refactoring from `## Refactorings`, it ticks it in the same
  way.
- AC3: Each update after an item also records that item's units, and any mode change, slices built or
  key decision.
- AC4: When the session ends, `## Progress` still gets the criteria results, the units remaining, the
  deferred refactorings and the final design review note.
- AC5: In `loop` mode, a child still never edits `SPEC.md`, and the orchestrator still records each
  item.

## Plan

1. **implement — update Progress when an item is done** (AC1, AC2, AC3, AC5) — inside-out: follows
   step 3 of "Loop Mode" in `skills/2-implement/SKILL.md`, which already ticks each item and commits
   it per the `SPEC.md` rule in `git-workflow.md`. Touches `skills/2-implement/SKILL.md`: adds an
   "Item done" rule after "Unit done". Once every unit of an item is committed, a single session
   ticks it and records its units, mode changes, slices and decisions, as "What Progress Records"
   lists, then commits that. A child keeps putting it in its results instead. Pins the new wording
   in `tests/skills.sh`
2. **implement — finish Progress when the session ends** (AC4) — inside-out: narrows step 1 of
   "STOP — Skill Complete" in the same skill. That step now adds what is left: the criteria results,
   the units remaining, the deferred refactorings and the final design review note. It no longer
   writes the items that are already recorded
3. **eval case: a single session records each item** (AC1) — inside-out: follows
   `implement-partial-session-offers-nothing`, reusing its fixture's two-item plan. Adds
   `plugins/aido/evals/implement-records-each-item/`, where one session builds both items without
   asking. Its order check: `SPEC.md` ticks item 1 before item 2's code changes. Lists the case in
   `docs/evals.md`. Bumps the plugin `version` (minor) in `plugins/aido/.claude-plugin/plugin.json`

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. implement — update Progress when an item is done
  - [x] "Item done" rule after "Unit done" in `skills/2-implement/SKILL.md`, pinned in
    `tests/skills.sh`
- [x] 2. implement — finish Progress when the session ends
  - [x] step 1 of "STOP — Skill Complete" adds only what is left, pinned in `tests/skills.sh`
- [x] 3. eval case: a single session records each item
  - [x] `plugins/aido/evals/implement-records-each-item/`, which sources the fixture of
    `implement-partial-session-offers-nothing`. Its order check is `ticks-item-1-before-item-2`,
    tested in `tests/test_evals.py`
  - [x] the case and its step check listed in `docs/evals.md`
  - [x] plugin `version` bumped to 5.3.0

Acceptance criteria:

- AC1: met — `tests/skills.sh` pins the "Item done" rule and "commit that before starting the next
  item". The eval case `implement-records-each-item` was not run: the user skipped the paid run
- AC2: met — `tests/skills.sh` pins "once every unit of a plan item or a refactoring is committed"
- AC3: met — `tests/skills.sh` pins "its units, any mode change, the slices built and the key
  decisions"
- AC4: met — `tests/skills.sh` pins the narrowed step 1 of "STOP — Skill Complete"
- AC5: met — `tests/skills.sh` pins "A child puts all this in its results instead, and the
  orchestrator records it" and "Only the orchestrator writes `SPEC.md`"

Key decisions:

- the bold title of the "Finish `## Progress`" step is not followed by "in `SPEC.md`", because
  `tests/skills.sh` would read that as a link to a guideline section

The final design review was skipped.
