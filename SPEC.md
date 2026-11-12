# Add an eval case for verify finding contradictory criteria

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

GitHub Issue: https://github.com/joebew42/aido/#107

## Context

When two criteria demand different results for the same input, `/aido:verify` verifies at most one of
them and names the contradiction. PR #105 added this rule to the verification brief, and the free
checks pin its wording. No eval case shows that verification follows it.

## Intent

Add an eval case where two criteria clash, each has a passing test, and `## Progress` records both as
met. The case passes only when the verification report verifies at most one of them and names the
clash.

## Out of scope

- Changing the verification rule or the verify skill.
- Recording results for the case. The next full round of evals does that.

## Acceptance criteria

- AC1: When the verify report sorts both clashing criteria as verified, the case fails it.
- AC2: When the verify report doesn't name the clash with an input where they clash, the case fails it.
- AC3: In the case's fixture, each clashing criterion has a passing test, and `## Progress` records both as `met`.
- AC4 (manual): `docs/evals.md` lists the case with the question it answers.

## Plan

1. **eval case `verify-names-contradictory-criteria`** (AC1, AC2, AC3) — inside-out: follows
   `plan-rewords-contradictory-criteria`, whose fixture sources another case's fixture, and the
   response graders in `verify-catches-a-test-that-cannot-fail`. Touches the evals only
   - the fixture sources `implement-leaves-contradictory-criteria-unresolved/fixture.sh`, for its
     specification: AC1 shows a completed task in the list as `<id> done`, and AC2 lists only open
     tasks
   - it then commits `todo.sh` with `complete` and a `list` that prints every task, and a
     `test_todo.sh` whose AC1 test completes a task and whose AC2 test lists only open tasks. Both
     pass. `## Progress` ticks both items and records AC1 and AC2 as `met`
   - the prompt is the one in `verify-catches-a-test-that-cannot-fail`
   - an LLM grader on the response fails a report that sorts both AC1 and AC2 as verified (AC1)
   - an LLM grader on the response fails a report that doesn't name the clash with a completed task
     in the list (AC2)
   - `tests/test_evals.py` checks that the fixture's tests pass, that `## Progress` records both as
     `met`, and that the criteria match those of the implement case (AC3)
   - list it in the cases table of `docs/evals.md`, after the other verify cases. The free check that
     every case is listed needs it in the same commit (AC4)
   - bump the plugin version to 6.3.2
   - once the free checks pass, propose one billed run of the case, and ask first

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. eval case `verify-names-contradictory-criteria`
  - the fixture sources the implement case's fixture, then commits a `list` that prints every task,
    tests that pass for both criteria, and `## Progress` recording both as `met`
  - two judges read the report: `verifies-at-most-one-criterion` and `names-the-clash`
  - `ClashVerified` in `tests/test_evals.py` checks the fixture and pins both judges
  - one billed run passed both judges with aido and without: each report verified AC1 only, called
    AC2 unmet, and named the clash with a completed task in the list

The final design review was skipped.

### Acceptance

- AC1: met — the `verifies-at-most-one-criterion` judge, pinned by `ClashVerified.test_judges_the_report_for_both_criteria_verified_and_for_the_clash`
- AC2: met — the `names-the-clash` judge, pinned by the same test
- AC3: met — `ClashVerified` tests on the fixture's passing tests, its `## Progress` and its criteria
- AC4: met — confirmed by the user: the row for the case in the cases table of `docs/evals.md`
