# Contradictory acceptance criteria are caught, not both marked met

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

GitHub Issue: https://github.com/joebew42/aido/#95

## Context

In a live run, two acceptance criteria contradicted each other, and both were marked `met`. AC1 asked
for normal colour whenever the count was at or below the warning threshold. AC4 asked for the alert
colour to win when the warning threshold was above the alert threshold. With warning 300k, alert 200k
and a count of 250k, they demand different results. Planning left both in place. Implementation then
marked both met, with tests for different cases. The user agreed that alert wins, but AC1 was never
reworded. The behaviour is not specific to Copilot CLI.

## Intent

Planning notices when two acceptance criteria can demand different results for the same input, and
gets one consistent decision from the user before the specification is approved. Implementation,
given an approved specification that still holds such a contradiction, never marks both met: it asks
for agreed wording, or leaves the conflict unresolved. Criterion IDs are kept, and nothing is
reworded without the user's agreement. `/aido:verify` reports such a contradiction instead of
verifying both criteria. Eval cases, using the TODO app, show the planning and implementing
behaviour.

## Out of scope

- a general constraint solver, or rules tied to thresholds or any one domain
- running the paid evals without asking first
- an eval case for `/aido:verify`: the PR says its change isn't covered by one

## Acceptance criteria

- AC1: When a draft holds two criteria that demand different results for the same input,
  `/aido:1-plan` raises the overlap and asks the user to decide before approval.
- AC2: When the user decides, the affected criteria are reworded to agree, keeping their IDs.
- AC3: When an approved specification holds contradictory criteria, `/aido:2-implement` records at
  most one of them as `met`.
- AC4: When `/aido:2-implement` finds such a contradiction, it asks for agreed wording, or leaves the
  conflict unresolved with the reason.
- AC5: An eval case gives `/aido:1-plan` a TODO-app draft with contradictory criteria, and checks the
  overlap is raised before approval.
- AC6: An eval case gives `/aido:2-implement` an approved TODO-app specification with contradictory
  criteria, and checks they aren't both recorded as `met`.
- AC7: When `/aido:verify` finds two criteria that demand different results for the same input, it
  verifies at most one of them, and its report names the contradiction.

## Plan

1. **refactor: name the contradiction rule in "Acceptance Criteria"** (enabling) — guideline
   - add a bold-labelled rule to "Acceptance Criteria" in `plugins/aido/guidelines/specification.md`:
     two criteria contradict when they demand different results for the same input. An approved list
     holds none, and only the user settles one, keeping the IDs
   - add an "only specification.md says what makes criteria contradict" check to `tests/skills.sh`
2. **planning raises contradictory criteria** (AC1, AC2) — inside-out: follows how a repository
   conflict is named as an open decision in "Approve the draft and choose the route", and the
   **Ask, don't guess** rule in `refining-a-draft.md`. Touches guideline, skill
   - `refining-a-draft.md`: the **contradictions** bullet sends contradictory criteria to the user,
     never to "A lesser one is fixed here". **Ask, don't guess** names them
   - `1-plan/SKILL.md`: contradictory criteria are an open decision in the "small and clear" test.
     The full-route checklist's "Fix any that don't" does not cover a contradiction: settle it with
     the user
   - pin the new lines in `tests/skills.sh`
3. **eval case: planning raises the overlap** (AC5) — inside-out: follows
   `plan-stops-before-code` (inline TODO app, `file_exists` and `llm` graders). Touches evals, docs
   - new `plan-raises-contradictory-criteria`: the fixture stays on `trunk` and leaves an uncommitted
     `SPEC.draft.md` whose two criteria clash for a completed task that is overdue
   - the prompt answers the questions before refining: resume the draft, approve it, plan it fully
   - graders: the final message names both criteria and asks which wins; `SPEC.md` doesn't exist;
     `todo.sh` is untouched
   - list it in the cases table of `docs/evals.md`
4. **implementing never marks contradictory criteria both met** (AC3, AC4) — inside-out: follows
   the "not met" options of the Acceptance Criteria Check, **Change the criterion** and **Defer it**.
   Touches skill
   - "Acceptance Criteria as Goal Posts": before writing a criterion's acceptance test, compare it
     with every criterion in `SPEC.md`, not only the item's
   - "Acceptance Criteria Check": a contradiction is asked about as **Change the criterion** /
     **Defer it**. Unanswered, the later criterion is `deferred` with the reason. A criterion already
     `met` whose wording changes by agreement becomes `changed`
   - "Child Mode" returns the contradiction as a question. A new line in "Red Flags to Watch For"
   - pin the new lines in `tests/skills.sh`
5. **eval case: implementing doesn't mark both met** (AC6) — inside-out: follows `spec_with` in
   `implement-todo.sh` and `implement-loops-over-the-plan/checks/each-item-is-recorded.sh`. Touches
   evals, docs
   - new `implement-leaves-contradictory-criteria-unresolved`: an approved spec with two clashing
     criteria and one plan item each; the prompt says nobody answers
   - checks: `### Acceptance` exists, the two criteria aren't both `met`, and their wording in
     `## Acceptance criteria` is unchanged
   - a grader: the final message names the contradiction
   - list it in the cases table of `docs/evals.md`
6. **verify reports contradictory criteria** (AC7) — inside-out: follows "Sort every requirement as
   exactly one of" in "The Verification Brief", which Step 3 copies to the subagent. Touches skill
   - the brief carries the rule from `specification.md`, copied, since the subagent loads no
     guideline
   - at most one of two contradictory criteria is **verified**. The other is **insufficient
     evidence** or **unmet**, and its line names the contradiction
   - pin the new line in `tests/skills.sh`

After the last item, bump `version` in `plugins/aido/.claude-plugin/plugin.json` from 6.2.0 to 6.3.0,
and run `tests/all.sh`.

## Design notes

- **Where it belongs:** the rule once, in "Acceptance Criteria" in
  `plugins/aido/guidelines/specification.md`. Each skill says only what it does about it: planning in
  `plugins/aido/guidelines/refining-a-draft.md` — "Analyse, refine and reword" and
  `plugins/aido/skills/1-plan/SKILL.md` — "Approve the draft and choose the route"; implementing in
  `plugins/aido/skills/2-implement/SKILL.md` — "Acceptance Criteria as Goal Posts", "Acceptance
  Criteria Check"; verifying in `plugins/aido/skills/verify/SKILL.md` — "The Verification Brief"
- **Existing behaviour and abstractions to reuse:** `2-implement/SKILL.md` — "Acceptance Criteria
  Check" (**Change the criterion**, **Defer it**, "A test that covers only part of the criterion
  doesn't meet it"); `specification.md` — "Acceptance in Progress" (`changed`, `deferred`);
  `verify/SKILL.md` — **insufficient evidence**, **unmet**; `plugins/aido/evals/implement-todo.sh` —
  `todo_app`, `spec_with`; `plugins/aido/evals/plan-stops-before-code/graders/`;
  `plugins/aido/evals/implement-loops-over-the-plan/checks/each-item-is-recorded.sh`
- **Boundaries that must hold:** no new `## Progress` label and no new verify report section, so
  `/aido:3-organize-commits`, `/aido:4-open-pr`, `language.md` and the label regex in
  `tests/skills.sh` stay as they are. The pinned lines "Never record a criterion as met without its
  evidence" and "keeps that result" stay. Every section a skill names exists (`tests/skills.sh` —
  `section_exists`). Each new case is listed in `docs/evals.md`
  (`tests/test_evals.py` — `CaseDocumentation`). The plan fixture stays on `trunk`, or Step 0 asks
  about the branch
- **Other modules or consumers affected:** `/aido:multi-phase-plan` and `/aido:stabilize` refine
  through `refining-a-draft.md`, so they raise contradictions too. `/aido:3-organize-commits` already
  names `deferred` criteria in its offer
- **Enabling refactorings (planned):** item 1, name the contradiction rule in "Acceptance Criteria"
- **Deferred:** none
- **Open questions:** none. A contradiction across phases shows only in `/aido:multi-phase-plan`, and
  stays out of scope. The PR says `/aido:verify`'s change has no eval case

## Refactorings

### r1. Give an unanswered contradiction one rule in /aido:2-implement

- **Change:** fold the two identical "no answer" sentences into one option line, "**Defer it**, or
  no answer — record the criterion with the higher ID as `deferred`, with the clash as the reason".
  Say in one place what a child in loop mode does when nobody answers: the loop's stop rule wins, or
  the deferral does. Update the pinned line in `tests/skills.sh`
- **Why:** the same sentence is written twice. In loop mode an unanswered child question stops the
  loop and ticks nothing, so the deferral never happens, and nothing says which rule holds
- **Where:** `plugins/aido/skills/2-implement/SKILL.md` — **Contradictory criteria**
  `plugins/aido/skills/2-implement/SKILL.md` — "Child Mode"
  `plugins/aido/skills/2-implement/SKILL.md` — **When a child returns a question**
  `tests/skills.sh` — pinned line "With no answer, record the criterion with the higher ID"
- **Confidence:** medium — both problems are in the text, but which rule should win in a child is a
  decision the code doesn't show
- **Risk:** changes how agents behave in `/aido:2-implement`. The matching cases are
  `implement-leaves-contradictory-criteria-unresolved` and
  `implement-loop-stops-on-an-unanswered-question`

### r2. Keep a deferred criterion out of verify's contradiction sorting

- **Change:** in the verification brief's contradiction bullet, say a criterion recorded as
  `deferred` keeps the `deferred` rule: listed under deviations as already decided, not sorted
- **Why:** `/aido:2-implement` now records one side of an unanswered clash as `deferred`. The brief
  then gives that criterion two rules, so it can land in two report sections, or a different one
  from run to run
- **Where:** `plugins/aido/skills/verify/SKILL.md` — "The Verification Brief", "How to read the
  specification"
- **Confidence:** medium — both rules are in the text, but a subagent may already read the
  `deferred` rule as winning, since it comes first. No eval case covers it
- **Risk:** changes the brief the verify subagent gets. The pinned line stays if the exception
  follows it

### r3. Share the fixture set-up in the eval runner's tests

- **Change:** extract one helper in `tests/test_evals.py` that makes a temporary workspace and runs
  a case's `fixture.sh` in it, and use it in the three classes
- **Why:** three classes repeat the same four lines, so a change to how a fixture is set up touches
  all three
- **Where:** `tests/test_evals.py` — `ClashLeftUnresolved.finished_with`
  `tests/test_evals.py` — `LoopRecordsEachItem.finished_with`
  `tests/test_evals.py` — `HiddenHelperTrap.solved_with`
- **Confidence:** medium — the copies are checked. The `### Acceptance` lookup the two check scripts
  share is left alone: check scripts run alone in the agent's workspace
- **Risk:** test code only. Two of the classes predate this feature

## Progress

- [x] 1. refactor: name the contradiction rule in "Acceptance Criteria"
  - the rule carries a TODO-app example: overdue shows in red, completed in grey
- [x] 2. planning raises contradictory criteria
  - refining sends them to the user, shows a clashing input, and rewords them with their IDs kept
  - they are an open decision in the "small and clear" test, so such a draft takes the full route
- [x] 3. eval case: planning raises the overlap
  - `plan-raises-contradictory-criteria`: AC1 (overdue → red) and AC3 (completed → grey) clash; AC2
    (due today → bold) is a distractor
- [x] 4. implementing never marks contradictory criteria both met
  - unanswered, and on **Defer it**, the criterion with the higher ID is `deferred`, with the clash
    as the reason
  - "keeps that result" gains one exception: settling a contradiction that changes a `met`
    criterion's wording makes it `changed`
- [x] 5. eval case: implementing doesn't mark both met
  - `implement-leaves-contradictory-criteria-unresolved`: AC1 shows a completed task as done in the
    list, AC2 lists only open tasks
  - its check has free tests in `tests/test_evals.py` — `ClashLeftUnresolved`
- [x] 6. verify reports contradictory criteria
  - the brief's "How to read the specification" carries the rule, copied; the uniqueness check
    allows that one copy

Key decisions:

- one run of each new eval case ($1.48) passed with aido and failed without it:
  `plan-raises-contradictory-criteria` 1.00 vs 0.33, `implement-leaves-contradictory-criteria-unresolved`
  1.00 vs 0.50. Fewer than 3 runs, so nothing was recorded in `docs/evals.md`
- the design note "Open questions: none" no longer holds: r1 decides what a child does with an
  unanswered contradiction

The final design review ran and recorded r1, r2, r3.

### Acceptance

- AC1: met — one run of `plan-raises-contradictory-criteria`, grader `asks-which-result-holds`
- AC2: deferred — the rule is written and pinned in `tests/skills.sh`, but no run has shown the
  rewording; the planning case stops before the user answers
- AC3: met — one run of `implement-leaves-contradictory-criteria-unresolved`, check
  `leaves-the-clash-unresolved`
- AC4: met — the same run: the clash was left unresolved and named, grader `names-the-contradiction`
- AC5: met — `plan-raises-contradictory-criteria` exists and is listed in `docs/evals.md`
  (`CaseDocumentation`)
- AC6: met — `implement-leaves-contradictory-criteria-unresolved` exists, is listed, and its check is
  covered by `ClashLeftUnresolved` in `tests/test_evals.py`
- AC7: deferred — the rule is in the verification brief and pinned in `tests/skills.sh`, but no run
  has shown it; the spec leaves verify without an eval case
