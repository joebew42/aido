# Offer the next workflow step with a question instead of naming a command

GitHub Issue: https://github.com/joebew42/aido/#36

## Context

The workflow is a sequence of skills, but only the first handoff is interactive. `/aido:1-plan` asks
how to continue and starts `/aido:2-implement` when the user picks it. After that, the user has to know
what comes next and type it:

- `/aido:2-implement` ends by telling the user they can run `/aido:3-organize-commits` when ready. It
  says so even when plan items remain, calling the implementation complete
- `/aido:3-organize-commits` ends with its final checklist and doesn't mention `/aido:4-create-pr` at
  all
- `/aido:stabilize` lists these steps as commands to run, and asks separately about a worktree

Eval runs have nobody to answer, so an offer must never start the next skill by itself. Otherwise an
`implement-*` run could continue into organizing and push its cost up.

## Intent

Each handoff between `/aido:2-implement`, `/aido:3-organize-commits` and `/aido:4-create-pr` becomes a
choice the user answers instead of a command they have to remember, without adding a stop to the
workflow. Following "each approval also settles the choice that follows it" in `/aido:1-plan`, the
offer is asked together with the skill's last approval.

Accepting an offer only starts the next skill. Every approval inside that skill still happens. The
offer doesn't let the user continue without noticing an open or deferred criterion, and the user can
always stop and carry on later in a new session, with a fresh context.

## Out of scope

- offers for later multi-phase steps: a phase already uses the same skills, so it gets these offers,
  and `/aido:multi-phase-sync` comes after a phase PR is merged, so nothing can offer it at that point
- offers after `/aido:4-create-pr` or `/aido:5-handle-review`, which wait on reviewers
- changes to `/aido:1-plan`'s own handoff
- starting a new session automatically

## Acceptance criteria

Offering to organize the commits

- AC1: when `/aido:2-implement` has every plan item done, it asks in the same `AskUserQuestion` call as
  the final Systemic Design Checkpoint question whether to organize the commits once implementation is
  complete, with the options **Organize the commits** (recommended) and **Stop here**
- AC2: when a `/aido:2-implement` session ends with plan items remaining, it offers no organizing, does
  not call the implementation complete, and names the remaining items and `/aido:2-implement` as the way
  to continue them
- AC3: the offer in `/aido:2-implement` names each criterion recorded as `deferred`

Offering to create the PR

- AC4: `/aido:3-organize-commits` asks in the same `AskUserQuestion` call as the commit grouping
  approval whether to create the pull request once the commits are organized, with the options **Create
  the PR** (recommended) and **Stop here**. The answer counts only when the grouping is approved
- AC5: the offer in `/aido:3-organize-commits` names each criterion recorded as `unchecked` or
  `deferred`, and **Create the PR** is not marked as recommended while any is `unchecked`
- AC6: with no specification, the offer in `/aido:3-organize-commits` is still asked, and says nothing
  about criteria
- AC7 (manual): when `/aido:resolve-migration-conflict` runs `/aido:3-organize-commits`, no PR is offered, and
  it goes on to its own force push step

Answering the offer

- AC8 (manual): choosing to continue starts the next skill in the same session once the current skill
  has finished, meaning its `## Progress` is committed or its final checklist holds, with no further
  question about the handoff
- AC9 (manual): if the current skill can't finish cleanly, the next skill doesn't start, and the user
  is told why, even when they chose to continue
- AC10 (manual): **Stop here** names the skill to run later, and says that running it in a new session
  gives it a fresh context
- AC11 (manual): each skill says that accepting its offer approves only starting the next skill, so
  the commit grouping question, the `SPEC.md` outcome question, the verification offer, the push
  approval and the PR review all still happen

Nobody answering

- AC12: when nobody answers, a `/aido:2-implement` run does not start `/aido:3-organize-commits`
- AC13: when nobody answers, a `/aido:3-organize-commits` run does not start `/aido:4-create-pr` and
  does not push

`/aido:stabilize`

- AC14 (manual): `/aido:stabilize` hands off with "Choose how to continue" from `/aido:1-plan` in place of its
  worktree question, asking nothing else about the handoff
- AC15 (manual): in carry-over mode, that question does not offer a worktree

Documentation

- AC16 (manual): the README describes the offers, and that they never replace a later approval
- AC17: `docs/evals.md` lists each eval case this change adds

## Plan

1. **refactor: give the commit grouping approval discrete options** (enabling) — skills. Restate
   `/aido:3-organize-commits` Step 2 as an `AskUserQuestion` with **Approve the grouping** / **Adjust
   it**, keeping the proposed list and the wait before the rebase, so that an answer can count "only
   on approval"
2. **offer the PR from `/aido:3-organize-commits`** (AC4, AC5, AC6, AC8, AC9, AC10, AC11, AC13) —
   outside-in: nobody has run an offer that comes after earlier questions, so it is unknown whether a
   run with nobody answering reaches it, and what an unanswered question leaves in the trace. Touches
   skills, evals
   - slice 1: new case `organize-offers-the-pr`, which allows `AskUserQuestion` and pre-answers the
     `SPEC.md` outcome. The question is asked with the grouping approval, with its options, and the
     skill says what the answer does and doesn't approve, how **Stop here** ends and what happens when
     the work can't finish. No `Skill` call starts `/aido:4-create-pr`, and no `git push` runs
   - slice 2: the same case's fixture records an `unchecked` and a `deferred` criterion. The question
     names both, and **Create the PR** is not recommended
   - slice 3: new case `organize-offers-the-pr-without-criteria`, reusing the fixture of
     `organize-without-a-plan`. The question is asked, and says nothing about criteria
3. **offer to organize from `/aido:2-implement`** (AC1, AC2, AC3, AC8, AC9, AC10, AC11, AC12) —
   inside-out: follows the offer from item 2 and joins the question in "Before completion", whose
   condition already separates a partial session. Rewrites step 3 of "STOP — Skill Complete". Touches
   skills, evals, with new cases `implement-offers-to-organize`, whose fixture has a `deferred`
   criterion, and `implement-partial-session-offers-nothing`
4. **skip the offer in the migration flow** (AC7) — inside-out: follows the caller-side wording in
   `/aido:stabilize` Step 5. `/aido:3-organize-commits` names the flow in its offer rule, and "Wrap Up"
   in `/aido:resolve-migration-conflict` repeats it. Touches skills
5. **hand off from `/aido:stabilize` with the same choice** (AC14, AC15) — inside-out: reuses "Choose
   how to continue" and Step 8 in `/aido:1-plan`. Replaces the command list and worktree question in
   Step 6, and the "do not proceed" ending. Touches skills
6. **document the offers and release them** (AC16, AC17) — inside-out: follows the handoff narrative in
   `README.md` and the case table in `docs/evals.md`. `tests/test_evals.py` checks that every case is
   listed, and `plugin.json` goes to `4.3.0`. Touches docs, tests

Running the new and matching eval cases is billed, so it is proposed and asked about first, as
`docs/evals.md` describes.

## Design notes

- **Where it belongs:** in each skill, next to the approval it joins, as the repository places
  workflow questions: `skills/2-implement/SKILL.md` — "Before completion",
  `skills/3-organize-commits/SKILL.md` — "Step 2", `skills/stabilize/SKILL.md` — "Step 6"
- **Existing behaviour and abstractions to reuse:**
  - `skills/1-plan/SKILL.md` — "Approve the plan" and "Choose how to continue": the shape of two
    questions in one call, with an answer that counts only on approval; "Step 8" for the worktree
  - `skills/2-implement/SKILL.md` — "Before completion" holds the every-plan-item-done condition, and
    runs after the Acceptance Criteria Check, so the `deferred` results are known
  - `guidelines/specification.md` — "Acceptance in Progress", "Specifications Without Acceptance
    Criteria" and "Reading the Approved Specification"
  - `tests/evals.py` — `grade_tool_used`: `max: 0` on `Skill` and on `git push`;
    `evals/plan-stops-before-code` is the precedent for allowing `AskUserQuestion` with nobody answering
- **Boundaries that must hold:**
  - `guidelines/git-workflow.md` — "Pushing Changes": only the permission prompt approves a push, so
    **Create the PR** does not include it
  - `skills/2-implement/SKILL.md` — "Commits": `/aido:3-organize-commits` owns the final history shaping
  - offers join an existing `AskUserQuestion` call and never add one; `/aido:1-plan` stays as it is
- **Other modules or consumers affected:** `skills/resolve-migration-conflict/SKILL.md` — "Wrap Up",
  `README.md`, `docs/evals.md`. The existing `implement-*` and `organize-*` prompts allow no
  `AskUserQuestion`, so the new cases need their own
- **Enabling refactorings (planned):** the commit grouping approval, item 1
- **Deferred:** none
- **Open questions:** none that block implementation. A shared guideline for the offers was ruled out:
  it would add a load to `/aido:3-organize-commits` for a few sentences. The "when ready" wording in
  `/aido:1-plan` and `/aido:4-create-pr` stays, as they are out of scope

## Progress

- [x] Item 1: `refactor:` the commit grouping approval
- [x] Item 2: the PR offer
- [x] Item 3: the organize offer
- [x] Item 4: no offer in the migration flow
- [x] Item 5: the `/aido:stabilize` handoff
- [x] Item 6: docs, the case listing test and version `4.3.0`

Item 2 slices built: the offer, with `organize-offers-the-pr`; naming open criteria; no specification,
with `organize-offers-the-pr-without-criteria`, which needed no skill text of its own.

Acceptance, where the cases are single runs per arm, not recorded:

- AC1: met — `implement-offers-to-organize`, which sees the question; its options and shared call come from
  the skill text, because headless runs have no `AskUserQuestion`
- AC2: met — `implement-partial-session-offers-nothing`
- AC3: met — `implement-offers-to-organize`
- AC4: met — `organize-offers-the-pr`, which sees the question; its options and shared call come from the
  skill text. Graded before the judge fix, and the skill text changed afterwards in item 4
- AC5: met — `organize-offers-the-pr`, with the same caveat on timing
- AC6: changed — narrowed to no specification, agreed with the user, because the case doesn't cover a
  specification without numbered criteria. Met — `organize-offers-the-pr-without-criteria`, graded before
  the judge fix
- AC7: met — confirmed by the user: the rule in `/aido:3-organize-commits` Step 2 and "Wrap Up"
- AC8: met — confirmed by the user: "Hand Off" and step 3 of "STOP — Skill Complete"; not tried live
- AC9: met — confirmed by the user: the same sections; not tried live
- AC10: met — confirmed by the user: the same sections; not tried live
- AC11: met — confirmed by the user: the same sections; not tried live
- AC12: met — `implement-offers-to-organize`
- AC13: met — `organize-offers-the-pr`, with the same caveat on timing as AC4
- AC14: met — confirmed by the user: `/aido:stabilize` Step 6; not tried live
- AC15: met — confirmed by the user: `/aido:stabilize` Step 6; not tried live
- AC16: met — confirmed by the user: the README paragraph after "What planning looks like"
- AC17: met — `CaseDocumentation` in `tests/test_evals.py`

Key decisions and deviations:

- `AskUserQuestion` does not exist in headless runs, so the Design notes' precedent is wrong: the new cases
  grade the final message, and do not allow the tool. `docs/evals.md` says so
- the eval judge answered before reasoning, which failed runs that should pass. The user agreed to fix it
  on this branch: it now reasons first, and its last line holds the verdict. Recorded results from before
  the fix are not re-measured
- the user asked to remove `docs/evals/tracer-bullet-baseline.md`, with the "Reference baseline" section of
  `docs/evals.md`, in its own commit
- the user chose not to record evals for this change, so the PR must say that the new cases have no
  recorded results, and that AC7, AC14 and AC15 aren't covered by evals
- the final Systemic Design Checkpoint was skipped by the user

Deferred refactorings: none.
