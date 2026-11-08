# Run the tests once, after the commits are organized

GitHub Issue: https://github.com/joebew42/aido/issues/65

## Context

`/aido:3-organize-commits` applies the "Before Every Commit" check to every commit it makes, and
that check runs the relevant tests. When a unit of work spans several commits, and the tests are
slow or many, organizing the history takes a long time. The commits it reshapes were already tested
while they were implemented.

## Intent

Organizing the commits runs the relevant tests once, on the final commit, when the new history is
settled, instead of once per commit. The rest of the "Before Every Commit" check still applies to
each commit. When that one run fails, the commit that broke it is fixed, so every commit stays sound.

## Out of scope

- how `/aido:2-implement`, `/aido:5-handle-review` and `/aido:resolve-migration-conflict` run tests
  before their own commits
- changing what counts as the relevant tests
- running the tests at each commit to prove every commit is green; only the final commit is tested,
  unless the final run fails

## Acceptance criteria

- AC1: When `/aido:3-organize-commits` makes a commit, it runs no tests for that commit, including an
  outside-in slice's acceptance test.
- AC2: When the history is organized, `/aido:3-organize-commits` runs the relevant tests once, on the
  final commit, before handing off.
- AC3: When `/aido:3-organize-commits` makes a commit, linting, the search for old references and
  the comment clean-up still apply to it.
- AC4: When the final run fails and the history is unpushed, the skill finds the first failing
  commit, fixes it there, rebuilds the commits after it, and runs the tests again.
- AC5: When the final run fails and the commits are already pushed, the skill adds a fix commit
  instead of rewriting history, and runs the tests again.
- AC6: When the final run passes, the skill hands off as the user chose, with no further test run.

## Plan

1. **organize-commits — run the tests once, at the end** (AC1, AC2, AC3, AC6) — inside-out: narrows
   the existing "Before Every Commit" gate, which `skills/3-organize-commits/SKILL.md` already applies
   to each commit and closes with "All tests pass" in its Final Checklist. Touches
   `skills/3-organize-commits/SKILL.md`: each commit keeps the gate minus the test run, and the Final
   Checklist runs the relevant tests once, on the final commit, before "Hand Off". Touches
   `guidelines/git-workflow.md`: "Before Every Commit" names this one exception, so the guideline and
   the skill agree. Pins the new wording in `tests/skills.sh`
2. **organize-commits — fix the commit that broke the final run** (AC4, AC5) — inside-out: follows
   "History Management" in the same skill, which already rewrites unpushed history and adds commits
   to pushed history. Touches `skills/3-organize-commits/SKILL.md`: when the final run fails, test
   earlier commits to find the first failing one, fix it there and rebuild the commits after it; if
   pushed, add a fix commit. Then run the tests again. Pins the wording in `tests/skills.sh`
3. **eval case: organizing runs the tests once** (AC1, AC2) — inside-out: follows
   `organize-shapes-an-inside-out-part`, reusing `organize-history.sh` for the fixture and the
   history check. Adds `plugins/aido/evals/organize-runs-the-tests-once/` with a `tool_used` grader
   allowing exactly one Bash call that runs the tests, and the inside-out history check so the history
   still ends green. Bumps the plugin `version` (minor) in `plugins/aido/.claude-plugin/plugin.json`

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. organize-commits — run the tests once, at the end
- [x] 2. organize-commits — fix the commit that broke the final run
- [x] 3. eval case: organizing runs the tests once

- AC1: deferred — `organize-runs-the-tests-once` measures it, but has not run yet; the next full eval round runs it
- AC2: deferred — `organize-runs-the-tests-once` measures it, but has not run yet; the next full eval round runs it
- AC3: met — pinned wording in `tests/skills.sh` (`Linting, the search for old references and the comment clean-up still apply to every commit`), accepted by the user as evidence
- AC4: met — pinned wording in `tests/skills.sh` (`find the first commit where the run fails, fix it there, and rebuild the commits after it`), accepted by the user as evidence
- AC5: met — pinned wording in `tests/skills.sh` (`add a fix commit instead of rewriting history`), accepted by the user as evidence
- AC6: met — pinned wording in `tests/skills.sh` (`hand off as the user chose, with no further test run`), accepted by the user as evidence

Decisions:

- the skill gains a "Run the Tests Once" section before its Final Checklist; the checklist now asks for that one passing run instead of "All tests pass"
- when the same tests also fail on the default branch, the skill fixes nothing and tells the user, since the failure is not the branch's
- a pushed history gets its fix commit before the `SPEC.md` outcome commit, when that one is not pushed yet
- the eval grader counts Bash calls that run a `test_*.sh` script; a single call that loops over commits counts once
- version bumped to 5.2.0

The final design review was skipped.
