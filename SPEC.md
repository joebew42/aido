# Show that planning rewords contradictory criteria once the user decides

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

GitHub Issue: https://github.com/joebew42/aido/issues/106

## Context

When two acceptance criteria contradict, planning asks the user which result holds, then rewords the
affected criteria to agree, keeping their IDs. The free checks pin that rule's wording. No eval shows
the rewording: `plan-raises-contradictory-criteria` stops before the user answers. Deferred in #105.

## Intent

An eval case shows that, once the user has chosen which result holds, planning rewords the clashing
criteria to agree with that choice, keeps their IDs, and still waits for the user to approve the
specification.

## Out of scope

- changing the rule in the skills or guidelines
- changing `plan-raises-contradictory-criteria`
- the same rewording in `/aido:2-implement`

## Acceptance criteria

The new case gives the same draft as `plan-raises-contradictory-criteria`, with the user's answer
already given: a completed task shows in grey, even when overdue.

- AC1: A run passes only when the draft's AC1 no longer shows a completed task in red.
- AC2: A run passes only when the draft still holds AC1, AC2 and AC3, with their IDs unchanged.
- AC3: A run passes only when planning creates no `SPEC.md` and does not treat the specification as
  approved.
- AC4: A run passes only when planning leaves `todo.sh` unchanged.
- AC5 (manual): `docs/evals.md` lists the new case and what it checks.

## Plan

1. **eval case `plan-rewords-contradictory-criteria`** (AC1, AC2, AC3, AC4) — inside-out: follows
   `plan-raises-contradictory-criteria`, whose fixture it reuses, and the file-focused grader in
   `plan-names-each-items-mode`. Touches the evals only
   - the prompt gives the earlier answers, plus: a completed task shows in grey, even when overdue
   - an LLM grader reads `SPEC.draft.md`: AC1 no longer shows a completed task in red (AC1), and
     AC1, AC2 and AC3 keep their IDs (AC2)
   - `SPEC.md` must not exist, and an LLM grader on the last message fails a run that treats the
     specification as approved (AC3)
   - no `Edit` touches `todo.sh` (AC4)
   - once the free checks pass, propose one billed run of the case, and ask first
2. **list the case in `docs/evals.md`, and bump the version to 6.3.1** (AC5) — inside-out: follows the
   row for `plan-raises-contradictory-criteria`. Touches the docs and the plugin manifest

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. eval case `plan-rewords-contradictory-criteria`
  - the case reuses the fixture of `plan-raises-contradictory-criteria`, and has five checks:
    `rewords-ac1-to-agree` and `keeps-the-criteria-ids` read `SPEC.draft.md`,
    `approves-no-spec-by-itself`, `waits-for-approval` and `leaves-the-code-alone`
  - `ClashReworded` in `tests/test_evals.py` checks the shared draft, the five checks, and that the
    two rewording checks read the draft
  - one billed run: with aido 5/5, without aido 4/5. Without aido, it wrote the plan without
    approval, and `waits-for-approval` failed it
- [x] 2. list the case in `docs/evals.md`, and bump the version to 6.3.1
- Key decision: the `docs/evals.md` row landed with item 1, because the free check that every case
  is listed would fail without it. Item 2 then bumped the version only
- The final design review was skipped

### Acceptance

- AC1: met — grader `rewords-ac1-to-agree` on `SPEC.draft.md`, its focus checked by `test_judges_the_rewording_on_the_draft`. Passed the run where AC1 was reworded to open tasks
- AC2: met — grader `keeps-the-criteria-ids` on `SPEC.draft.md`, checked by `test_checks_the_reworded_draft_the_approval_and_the_code`
- AC3: met — graders `approves-no-spec-by-itself` and `waits-for-approval`. The second failed the run without aido, which treated the spec as approved
- AC4: met — grader `leaves-the-code-alone`, no `Edit` on `todo.sh`
- AC5: met — confirmed by the user: the new row in the `docs/evals.md` table
