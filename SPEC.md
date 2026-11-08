# Plan the design review's refactorings in the specification

GitHub Issue: https://github.com/joebew42/aido/#64

## Context

`/aido:2-implement` offers a final design review once every plan item is done. Today the refactorings
the user accepts are applied right away, in the same long session, with no trace in the
specification. The same happens when a design check during TDD finds a refactoring across modules
and the user chooses to make it now.

## Intent

An accepted refactoring becomes an item of the specification, with its own code, `r1`, `r2`, …, and
is built like a plan item: in a later session or in a subagent. `/aido:2-implement` continues from
the first item not yet done, whether a plan item or a refactoring. `/aido:2-implement loop r1` builds
one refactoring in a subagent, and marks it as done.

## Out of scope

- refactorings the user defers are still parked outside the repository, as today
- refactorings the design checks during TDD make inside the code they already touch, or within the
  item's own module, are still made right away, as today
- the enabling refactorings found by `/aido:1-plan` stay plan items, with no `r` code
- no second final design review runs after the refactorings are done

## Acceptance criteria

Recording

- AC1: When the user accepts a finding of the final design review, it is added to a `## Refactorings`
  section of the specification, with the next free code, and not applied.
- AC2: When a design check during TDD asks about a refactoring that touches another module, one option
  records it as the next refactoring, and implementation goes on.
- AC3: Each refactoring in `## Refactorings` keeps every field a finding states. A code is never
  renumbered or reused.
- AC4: When the final design review records refactorings, the session commits the specification and
  stops. It names `/aido:2-implement` and `/aido:2-implement loop` as the ways to continue.

Running

- AC5: When `/aido:2-implement` runs with nothing given, it offers every unfinished plan item and
  refactoring, with the first unfinished one as the next logical one.
- AC6: When `/aido:2-implement loop r1` runs, a subagent builds refactoring `r1`, and the orchestrator
  ticks it in `## Progress` once the checks pass.
- AC7: `/aido:2-implement loop r1-r3` runs those refactorings in order, skipping and naming any
  already ticked.
- AC8: Plain `/aido:2-implement loop` runs every unfinished plan item, then every unfinished
  refactoring.
- AC9: When `loop` names a refactoring code the specification doesn't have, the loop does not start,
  and says why.

Finishing

- AC10: Organizing the commits is offered only once every plan item and refactoring is done.
- AC11: When the last refactoring is done, the final design review is not offered again.

Other skills

- AC12: `/aido:verify` treats changes a refactoring in `## Refactorings` explains as planned, not as
  deviations.
- AC13: `/aido:3-organize-commits` gives each refactoring its own `refactor:` commit, after the feature
  commits, even when it only reshapes the feature's new code.
- AC14 (manual): The specification structure in `specification.md` and the README describe
  `## Refactorings` and the `loop r1` forms.
- AC15 (manual): The plugin version gets a minor bump.
- AC16: `/aido:3-organize-commits` always recommends opening the PR, whatever `## Progress` says. It
  still names any `unchecked` or `deferred` criterion in that question.

## Plan

1. **refactor: define the line that marks an item done in `## Progress`** (enabling) — documentation
   only. Add a subsection beside "Acceptance in Progress" in `specification.md`: a done item is
   `- [x] <code>. <title>` on one line, for `3` and `r1` alike. Point Loop Mode, "What Progress
   Records" and "STOP — Skill Complete" in `2-implement`, and Step 2 in `3-organize-commits`, to it.
   Keep `[x]` and the title together, so the `implement-loops-over-the-plan` check stays green.
2. **specification structure: the `## Refactorings` section** (AC3, AC14) — inside-out: follows the
   ID rule in "Acceptance Criteria" and the `(enabling)` shape in "Plan Items", both in
   `specification.md`. Touches guidelines.
   - add `## Refactorings` to the template, after `## Design notes` and before `## Progress`, and a
     subsection: codes `r1`, `r2`, … never renumbered or reused, each with every field a finding
     states, built as a `refactor:` item with no mode
   - name `## Refactorings` in "Showing a finding" in `systemic-refactoring.md`
   - add `r1` to the exact labels in `language.md`
3. **record accepted refactorings instead of applying them** (AC1, AC2, AC4, AC11) — inside-out:
   follows the deferred-finding steps in "Before completion" and "On evidence, during TDD" in
   `2-implement`. Touches the `2-implement` skill.
   - final review: accepted findings get the next free code in `## Refactorings`, with no code
     change. When any are recorded, commit `SPEC.md` and stop, naming `/aido:2-implement` and
     `/aido:2-implement loop`
   - TDD check: the cross-module question gains **Plan it for later**, which records the finding and
     carries on. A child returns it in "Child Results" instead, and the orchestrator records it
   - `## Progress` notes that the review ran and recorded refactorings, so it isn't offered again
4. **run refactorings like plan items** (AC5, AC6, AC7, AC8, AC9) — inside-out: follows Loop Mode's
   item selection, range check and child brief, and Step 1, in `2-implement`. Touches the
   `2-implement` skill and `tests/skills.sh`.
   - Step 1 lists unfinished plan items, then unfinished refactorings
   - `loop r<N>` and `loop r<first>-r<last>` choose refactorings. Plain `loop` runs plan items, then
     refactorings. An unknown code stops the loop before it starts
   - a child is started as `item r<N>`, and builds the refactoring with tests kept green
   - update the Loop Mode phrases pinned in `tests/skills.sh` in the same commit
5. **finish only when every item is done** (AC10) — inside-out: follows "plan items remain" in "STOP
   — Skill Complete" and "After the last item it runs" in `2-implement`. Touches the `2-implement`
   skill.
   - unfinished refactorings count as items that remain. Organizing is offered once the last one is
     done, with no second review
6. **organize commits each refactoring on its own, and always offer the PR** (AC13, AC16) —
   inside-out: follows the stand-alone refactoring rule in `git-workflow.md` and the PR offer in Step 2
   of `3-organize-commits`. Touches guidelines, the `3-organize-commits` skill and the
   `organize-offers-the-pr` eval case.
   - `git-workflow.md`: a refactoring from `## Refactorings` always gets its own `refactor:` commit,
     after the feature commits
   - Step 2 always recommends **Open the PR in a fresh context**, whatever `## Progress` says. It
     still names `unchecked` and `deferred` criteria, and no longer reads which items are done
   - the `names-the-open-criteria` grader no longer asks that the PR not be recommended
7. **verify treats planned refactorings as planned** (AC12) — inside-out: follows how "How to read
   the specification" in `verify` treats `## Alignment decisions`. Touches the `verify` skill.
8. **docs and version** (AC14, AC15) — inside-out: follows the `loop 7-9` sentence in the README's
   skills table. Touches the README, `docs/evals.md` and `plugin.json` (`5.0.0` → `5.1.0`).
9. **eval cases** (AC1, AC6, AC8) — inside-out: follows `implement-loops-over-the-plan` and its
   `implement-todo.sh` fixture. Touches `plugins/aido/evals/`.
   - `implement-loop-runs-a-refactoring`: a spec with every plan item done and `r1` open; `loop r1`
     builds and ticks it
   - `implement-review-records-refactorings`: the review's accepted finding lands in
     `## Refactorings`, and no code changes. `tests/test_evals.py` and `tests/skills.sh` stay green

## Design notes

- **Where it belongs:** the section and its codes in `plugins/aido/guidelines/specification.md` —
  "The Specification Structure", which is the only place the structure is defined. Recording, running
  and finishing in `plugins/aido/skills/2-implement/SKILL.md` — "Before completion — `fable`
  subagent", "On evidence, during TDD — session model", "How it was invoked", "Step 1", "Loop Mode",
  "Child Mode", "STOP — Skill Complete". AC12 in `plugins/aido/skills/verify/SKILL.md` — "How to read
  the specification". AC13 and AC16 in `plugins/aido/guidelines/git-workflow.md` — "General
  Principles", and `plugins/aido/skills/3-organize-commits/SKILL.md` — "Step 2".
- **Existing behaviour and abstractions to reuse:**
  - `plugins/aido/guidelines/specification.md` — "Acceptance Criteria": IDs are never renumbered or
    reused
  - `plugins/aido/guidelines/specification.md` — "Plan Items": the `(enabling)` item, with no mode
  - `plugins/aido/guidelines/systemic-refactoring.md` — "What every finding states", "Showing a
    finding"
  - `plugins/aido/skills/2-implement/SKILL.md` — "Loop Mode": selection, range check, the three
    checks, ticking and committing; "Child Mode" and "Child Results"; "Committing systemic
    refactorings"; "What Progress Records", whose "the final design review was skipped" line is the
    model for AC11's note
  - `plugins/aido/evals/implement-loops-over-the-plan/` — the fixture and the `[x]` check
- **Boundaries that must hold:**
  - skills refer to `specification.md` sections by name and don't restate the structure.
    `tests/skills.sh` checks those references and pins Loop Mode phrases
  - only the orchestrator writes `SPEC.md`; a child returns what it would record
  - in `verify`, `## Refactorings` explains a change but is never evidence that something is met
  - skills stay stack-agnostic, with TODO-app examples
- **Other modules or consumers affected:** `README.md` (skills table), `docs/evals.md` (case table),
  `plugins/aido/.claude-plugin/plugin.json`. `plugins/aido/skills/4-open-pr/SKILL.md` — "Step 4.5"
  still reads true, because deferred refactorings stay parked.
- **Enabling refactorings (planned):** item 1. *Define the done-item line once in `specification.md`,
  so the two skills that ask "is every item done" read the same rule.*
  - **Observation:** `2-implement` judges an item done by a tick in `## Progress`;
    `3-organize-commits` judges it by whether a criterion is `unchecked`. `specification.md`
    defines no item line
  - **Evidence:** `plugins/aido/skills/2-implement/SKILL.md` — "Loop Mode";
    `plugins/aido/skills/2-implement/SKILL.md` — "What Progress Records";
    `plugins/aido/skills/3-organize-commits/SKILL.md` — "Step 2";
    `plugins/aido/guidelines/specification.md` — "Acceptance in Progress";
    `plugins/aido/evals/implement-loops-over-the-plan/checks/each-item-is-recorded.sh`
  - **Competing explanations:** no change needed, as only `2-implement` reads ticks. Settled because
    the structure is defined only in `specification.md`, and the `r1` line needs one home there.
    AC16 was changed during implementation, so `3-organize-commits` no longer reads done items
  - **Assumptions:** none
  - **Confidence:** high
  - **What would change it:** the done line no longer being read by `/aido:2-implement` or the eval
    checks
  - **Recommendation:** one subsection in `specification.md`, referred to by both skills
  - **Why it matters:** the `- [x] r1. <title>` line is read by Loop Mode, "What Progress Records" and
    two eval checks. Without one definition, each would describe it its own way
  - **Risk:** pinned phrases in `tests/skills.sh` change in the same commit
- **Deferred:** none.
- **Open questions:** none. The open question on AC13 was settled by the user: always its own commit.
  The `git-workflow.md` rule gains that exception in item 6.

## Progress

- [x] 1. refactor: define the line that marks an item done in `## Progress`
- [x] 2. specification structure: the `## Refactorings` section
- [x] 3. record accepted refactorings instead of applying them
- [x] 4. run refactorings like plan items
- [x] 5. finish only when every item is done
- [x] 6. organize commits each refactoring on its own, and always offer the PR
- [x] 7. verify treats planned refactorings as planned
- [x] 8. docs and version
- [x] 9. eval cases

Acceptance:

- AC1: deferred — the user skipped the eval run; `implement-review-records-refactorings` covers it
- AC2: deferred — pinned in `tests/skills.sh` only; no eval measures it yet
- AC3: deferred — pinned in `tests/skills.sh` only; no eval measures it yet
- AC4: deferred — the user skipped the eval run; `implement-review-records-refactorings` covers it
- AC5: deferred — pinned in `tests/skills.sh` only; no eval measures it yet
- AC6: deferred — the user skipped the eval run; `implement-loop-runs-a-refactoring` covers it
- AC7: deferred — pinned in `tests/skills.sh` only; no eval measures it yet
- AC8: deferred — pinned in `tests/skills.sh` only; no eval measures it yet
- AC9: deferred — pinned in `tests/skills.sh` only; no eval measures it yet
- AC10: deferred — the user skipped the eval run; `implement-loop-runs-a-refactoring` covers it
- AC11: deferred — the user skipped the eval run; `implement-loop-runs-a-refactoring` covers it
- AC12: deferred — pinned in `tests/skills.sh` only; no eval measures it yet
- AC13: deferred — pinned in `tests/skills.sh` only; no eval measures it yet
- AC14: met — confirmed by the user: the "Refactorings" and "Items in Progress" subsections in
  `specification.md`, and the README's `/aido:2-implement` row naming `## Refactorings` and `loop r1`
- AC15: met — confirmed by the user: `plugin.json` goes from `5.0.0` to `5.1.0`
- AC16: changed — the user decoupled organizing from the plan: it always recommends opening the PR,
  and still names open criteria. Then deferred: the user skipped the eval run;
  `organize-offers-the-pr` covers it, with its updated grader

Key decisions:

- AC16 changed at the user's request. Organizing no longer reads which items are done, so the old
  `unchecked` rule, which kept the PR from being recommended, is gone too. The design note on item 1
  was updated to match
- "STOP — Skill Complete" gets no pointer of its own to "Items in Progress": it already follows
  "What Progress Records", which has the pointer
- the commit for the `git-workflow.md` rule came before the commit that pins it in `tests/skills.sh`
- the final design review ran. All six of its findings were applied, each folded into the feature
  commit whose new text it reshaped: ticking refactorings in a single session, keeping the behaviour
  rule in "Boundaries" only, one label **Plan it for later**, no second round of criteria questions,
  clearer wording on asking again about organizing, and this design note

Deferred refactorings: none.
