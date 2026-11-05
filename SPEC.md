# Reduce the cost of running the evals

GitHub Issue: https://github.com/joebew42/aido/#34

## Context

Evals cost enough that people skip them: one case at 3 runs per arm costs about $6, and a recent change
to the implement guidance went without them for this reason. Most of the cost comes from long runs, since
each turn re-reads the whole context. In one saved `implement-connects-the-slice-early` run with aido
($2.51), the order check was settled about 40% of the way through the cost, but the run carried on to the
end. No baseline for `implement-*` is recorded yet, so the saving can't be measured today.

## Intent

Make each eval run cheaper, while still catching large regressions. Runs stop once their result is known,
the work that needs a finished run moves to one small case, and free checks catch accidental deletions.
Free checks run on every change. One paid run is for a risky change, when asked for. The full recorded
round runs from time to time, such as before a release.

"Good enough" means catching big regressions. Three runs is already a small sample: a check that passes
half the time still scores 3/3 one time in eight. So the aim is cheaper runs, not fewer.

## Out of scope

- Reusing or skipping the "without aido" results: it saves only about 10%.
- Switching the default to a cheaper model: it would measure a different agent, and its results couldn't
  be compared with existing baselines.
- Shortening the `plan-*`, `organize-*`, `verify-*`, `implement-offers-to-organize` and
  `implement-partial-session-offers-nothing` cases, which already cost about $0.60 or less per run.
- Changing what any skill or guideline tells the agent to do, even where that would make runs cheaper.

## Acceptance criteria

Baseline

- AC1: Before any other change, the three full implement cases are recorded on the current code at 3 runs
  per arm: `implement-connects-the-slice-early`, `implement-grows-an-inside-out-item-by-layer` and
  `implement-writes-the-test-first`.

Stopping early

- AC2: When a case's order check is settled, because the thing that must come second has appeared, the
  runner ends that run without waiting for the agent to finish.
- AC3: When a case has any check that needs a finished run, the runner lets that run finish.
- AC4: When a run is stopped early, it counts as valid, and its order check gives the verdict it gives today
  for the same sequence of file changes.
- AC5: When a run is stopped early, its cost is reported and counts towards `--max-cost-usd`.

Cases

- AC6: One small new case checks that the agent finishes a feature: the suite ends green, the feature
  behaves as specified, and inner units have their own tests.
- AC7: The three full implement cases keep only their order checks, and each one stops early.
- AC8: When a run hits its turn limit, the runner's output says it was cut off.

Running in stages

- AC9: When the runner is asked to stop at the first failure and a check fails in the "with aido" arm, it
  starts no new runs, exits with a non-zero status, and records nothing for that case.

Free static checks

- AC10: When a skill or guideline names a section of another bundled file that doesn't exist, `tests/skills.sh`
  fails.
- AC11: When a skill loses one of the approval questions or evidence rules that the check lists,
  `tests/skills.sh` fails.

Measured result

- AC12: The mean cost per "with aido" run of each of the three shortened cases is at most 75% of its AC1
  baseline.
- AC13: One round of the three shortened cases, at 3 runs per arm, costs at most 60% of the AC1 baseline
  for those cases.
- AC14: Each shortened case's order check, in the "with aido" arm at 3 runs, scores within one run of its
  AC1 baseline.
- AC15: When a changed case runs once against a copy of the plugin whose rule says the opposite, the check
  that case exists for fails.

Documentation

- AC16 (manual): `docs/evals.md` explains how to run in stages, which check moved where, and what each stage
  costs, and it shows the cost before and after this change, so a reader knows what to run and what it
  will cost.

## Plan

Paid runs happen in items 1, 2 and 9, inside a sandbox, as `docs/evals.md` describes. They total about
$50 at today's prices.

1. **record the baseline** (AC1) — inside-out: follows the documented run command, with no code change.
   Run `python3 tests/evals.py --case 'implement-[cgw]*' --max-cost-usd 40` before anything else changes,
   and commit the results. Touches no layer
2. **stop a run once its order check is settled** (AC2, AC3, AC4, AC5) — outside-in: nobody has run this,
   so it is unconfirmed what a stopped `claude -p` leaves behind. The final cost report may be missing, and
   the trace may be incomplete. Touches domain (`OrderWatch` in `tests/evals.py`), application (`run_case`,
   `problems`), infrastructure (`isolated_claude`). Free tests use a stand-in `claude` on `PATH`
   - slice 1: a case with only an order check is stopped when the second thing appears, stays valid and
     keeps its verdict (AC2, AC4), confirmed once with one real run of about $1
   - slice 2: a case with any other check runs to the end (AC3)
   - slice 3: a stopped run's cost comes from the token counts in its trace, and counts towards
     `--max-cost-usd` (AC5)
3. **say when a run was cut off** (AC8) — inside-out: follows how `run_case` reads the final `result` event
   and how `attempt` prints each run's state. Any result other than `success` is shown as cut off, and the
   run stays valid. Touches application
4. **stop at the first failure** (AC9) — inside-out: follows the `--max-cost-usd` check in `attempt` and
   `recordable`, which already refuses a partial run. Only a failed check in the "with aido" arm counts,
   not an invalid run. Touches application
5. **choose which plugin a run uses** (AC15) — inside-out: follows the `--report-dir` option and the
   `PLUGIN` constant in `tests/evals.py`. A run using this option records nothing, so a broken copy can never
   replace real results. Touches application
6. **add the small finished-run case** (AC6) — inside-out: follows the layout and fixture of
   `implement-connects-the-slice-early`, cut to one acceptance criterion and one slice. It takes
   `suite-ends-green`, `acceptance.sh` and `inner-units-have-tests`, with a lower `max_turns`. The case goes
   into the table in `docs/evals.md`, which `tests/test_evals.py` requires. Touches no runner code
7. **shorten the three full implement cases** (AC7) — inside-out: follows `order.json` as it is. Remove
   their other checks and `acceptance.sh`, lower `max_turns`, and update the tests in `tests/test_evals.py`
   that read those graders. Touches no runner code
8. **add the free static checks** (AC10, AC11) — in-unit: how to recognise a section reference, because
   they are written several ways (`"The Modes" in `tdd.md``, `**Staleness** in that same section`). Grow it
   in `tests/skills.sh`, next to the existing language rule check. A test runs it on a copy of the plugin
   with a section, a question and a rule removed, and expects a failure each time. Touches infrastructure
9. **measure the result** (AC12, AC13, AC14, AC15) — inside-out: follows the same run command as item 1,
   with the new case added. Then run each changed case once against a copy of the plugin whose rule says
   the opposite, using item 5. If a target is missed, raise it with the user before changing it. Touches no
   layer
10. **document the new way to run them** (AC16) — inside-out: follows the structure of `docs/evals.md`. Add
    the stages, the moved checks, and a hand-written before-and-after cost table outside the generated
    section, because recording overwrites the baseline. Revisit the `--max-cost-usd` default and the "about
    $6" advice. Bump `version` to 4.4.1 and run `claude plugin validate` on both paths. Touches no layer

The enabling refactoring analysis was skipped.

## Progress

- [x] Item 1: baseline recorded, $15.96
- [x] Items 2 to 5: runner changes, all in one commit because they share `tests/evals.py` and waited for the
      baseline to finish
- [x] Items 6 and 7: `implement-finishes-the-feature` added, three cases shortened
- [x] Item 8: free static checks
- [x] Item 9: measured, $14.69, plus one run per case against a reversed rule
- [x] Item 10: docs, `CLAUDE.md`, version 4.4.1

Item 2 slices built: a case with only an order check stops, stays valid and keeps its verdict; a case with
any other check runs to the end; a stopped run reports its cost from the final result.

Decisions:

- Item 2 slice 3 changed: `SIGINT` makes `claude -p` still write its final result with the true cost, so no
  estimate from token counts is needed. Per-message output counts in the trace are far too low to use.
- Evals now run from time to time, by the user's decision: free checks on every change, one run on a risky
  change when asked for, and the full round such as before a release. Intent and `CLAUDE.md` changed to match.
- AC12 and AC13 changed by the user's decision after the first targets were missed. See below.
- The final design review was skipped.

Acceptance:

- AC1: met — commit `docs: record the implement eval baseline`, at 3 runs per arm
- AC2: met — `test_a_run_with_only_an_order_check_stops_once_it_is_settled`
- AC3: met — `test_a_case_with_a_shell_check_runs_to_the_end`, and the grader and acceptance script tests
- AC4: met — `test_the_wrong_order_stops_too_and_fails_the_check`
- AC5: met — `test_a_stopped_run_reports_what_it_cost_so_far`, `test_a_stopped_runs_cost_counts_towards_the_limit`
- AC6: met — `test_one_small_case_checks_the_finished_feature`
- AC7: met — `test_the_order_cases_have_only_their_order_check_so_they_stop_early`, and 18 real runs stopped early
- AC8: met — `test_a_run_that_hits_its_turn_limit_is_marked_as_cut_off`, `test_a_run_ending_at_its_turn_limit_is_shown_as_cut_off`
- AC9: met — `test_a_failed_check_starts_no_new_runs_and_records_nothing`, `test_a_case_that_failed_is_left_out_even_when_all_its_runs_happened`
- AC10: met — `test_a_reference_to_a_missing_section_fails`, `test_a_reference_to_a_missing_file_fails`
- AC11: met — `test_a_removed_approval_question_fails`, `test_a_removed_evidence_rule_fails`
- AC12: changed — was at most half, now at most 75%. Measured 42%, 53% and 72%
- AC13: changed — was the four cases at 75%, now the three shortened cases at 60%. Measured 54%. With the new
  case, the round is 92%
- AC14: met — all three order checks 3/3, as in the baseline
- AC15: met — all four checks failed against a reversed rule, one run each, in `docs/evals.md`
- AC16: met — confirmed by the user: `docs/evals.md` "When to run them" and "What the shorter runs saved"
