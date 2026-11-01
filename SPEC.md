# Verify the specification's acceptance criteria across the workflow

## Context

Every feature starts from `SPEC.md`, but today nothing checks that what gets built does what the
specification asks:

- `/aiae:1-plan` only *suggests* a structure for the refined specification ("usually reads…") and
  keeps the user's own, so a specification can be approved without acceptance criteria
- plan items do not say which acceptance criterion they serve, so a criterion the plan misses goes
  unnoticed
- `/aiae:2-implement` never mentions acceptance criteria: a unit is done when the behaviours *the
  plan* gives it have tests. What is verified is the plan, not the specification's intent
- the outer acceptance test of the double loop ("Test-First vs. Strict TDD" in `code-standards.md`)
  is not tied to the specification
- no step — the end of implementation, organizing commits, or the pre-flight review in
  `/aiae:4-create-pr` — checks the criteria, and criteria that cannot be automated have no way to
  be verified at all
- the skills that write a specification disagree on its shape: `/aiae:stabilize` uses `## Intent`,
  `/aiae:1-plan` uses `## Goals`, and `/aiae:multi-phase-spec-pr` has no structure at all

## Intent

Make the specification's acceptance criteria the thread that runs through the workflow:

- every refined specification has the same structure, and the specification states **what** and
  **why**, never **how** — the how belongs to `## Plan` and `## Design notes`
- acceptance criteria are always present, numbered, and approved by the user before `SPEC.md`
  exists
- the plan traces every acceptance criterion to the plan items that deliver it
- implementation turns each automatable criterion into an outer acceptance test, written first as
  the goal post, and checks every criterion before declaring the feature done
- criteria that cannot be automated are confirmed by the user
- the pre-flight review before a PR checks the change against the criteria

The structure of a specification, in this order:

```markdown
# <descriptive title>

GitHub Issue: <repo link>/#<NUMBER>   (or omit)

## Context               — why the change is needed, technical or product
## Intent                — what the change must achieve, not how
## Out of scope          — what it deliberately does not do
## Acceptance criteria   — AC1, AC2, … one checkable statement each
## Plan                  — added by planning; each item names the ACs it serves
## Design notes          — added by planning, when the analysis ran
## Progress              — added by implementation
```

## Out of scope

- `/aiae:5-handle-review`: it still does not modify `SPEC.md` nor re-check acceptance criteria
- `/aiae:pr-review` run on its own, outside the `/aiae:4-create-pr` pre-flight
- specifications written before this change: a `SPEC.md` without numbered acceptance criteria is
  implemented as today — no traceability, no final check — and no migration is offered
- redrawing the diagrams in `docs/`
- a fixed naming scheme for tests: tests are not required to carry criterion IDs

## Acceptance criteria

Specification structure

- AC1: the specification structure above is defined once, and every skill that writes or reads it
  refers to that single definition instead of restating it
- AC2: when refining, `/aiae:1-plan` rewrites the draft into that structure — sections in that order,
  Context, Intent, Out of scope and Acceptance criteria all present — carrying the user's content
  into the matching section and raising with `AskUserQuestion` anything that fits none
- AC3: `/aiae:1-plan` proposes acceptance criteria when the draft has none or too few, and does not
  move the draft to `SPEC.md` until every criterion is numbered, specific, checkable, and the user
  has approved the list
- AC4: each acceptance criterion is marked as checkable by an automated test or as a **manual**
  check that needs the user's confirmation
- AC5: `/aiae:stabilize` writes its specification with the same required sections, keeping its own
  extra ones (Original work, Strategy, What the original does, Gaps against the guidelines)
- AC6: `/aiae:multi-phase-spec-pr` writes the overall specification with the same structure, and a
  phase draft written by `/aiae:1-plan` carries only the acceptance criteria that phase delivers,
  keeping their original IDs

Planning

- AC7: every item in `## Plan` names the acceptance criteria it serves, and every acceptance
  criterion is served by at least one plan item; `/aiae:1-plan` does not ask for plan approval
  while a criterion is unserved

Implementation

- AC8: for every automatable acceptance criterion in scope for the session, `/aiae:2-implement`
  writes the outer acceptance test first, sees it fail for the right reason, and keeps it red as the
  goal post while the units behind it are grown with strict TDD
- AC9: before declaring the feature done, `/aiae:2-implement` checks every acceptance criterion and
  records in `## Progress` its status — met, changed or deferred — with its evidence: the test that
  covers it, or the user's confirmation for a manual check
- AC10: for each manual criterion, `/aiae:2-implement` shows the evidence from the change and asks
  the user to confirm it with `AskUserQuestion`
- AC11: for each criterion that is not met, `/aiae:2-implement` asks with `AskUserQuestion` —
  **Implement it now** (back to TDD) / **Change the criterion** (`SPEC.md` is updated only with the
  user's approval, and the change is recorded in `## Progress`) / **Defer it** (recorded in
  `## Progress`)
- AC12: a partial session checks only the criteria its plan items serve, and `## Progress` lists the
  criteria still unchecked

Pull request

- AC13: the `/aiae:4-create-pr` pre-flight review checks the diff against the acceptance criteria and
  reports any criterion the change does not appear to meet; it reads the specification from the
  branch history when `/aiae:3-organize-commits` has already reverted or moved it
- AC14: a deferred acceptance criterion is named in the PR description

Specifications without acceptance criteria

- AC15: given a `SPEC.md` without numbered acceptance criteria, `/aiae:2-implement` and the
  `/aiae:4-create-pr` pre-flight work as they do today, without asking about criteria

Repository

- AC16 (manual): `README.md` describes the specification structure and how acceptance criteria are
  verified from planning to the PR
- AC17: `claude plugin validate .` and `claude plugin validate ./plugins/aiae` pass

## Plan

The enabling refactoring analysis was skipped.

Layers, for a plugin made of Markdown: the guideline that defines the specification is the
**domain**, the skills that apply it are the **application**, and the README is the **delivery**.
Run `claude plugin validate .` and `claude plugin validate ./plugins/aiae` after each item.

1. **domain — define the specification structure once** (AC1, AC4, AC15) — add a section
   "The Specification Structure" to `plugins/aiae/guidelines/project-conventions.md`, next to "The
   Specification File" (every skill that touches the spec already loads this file):
   - the sections and their order; Context = why, Intent = what (not how), Out of scope, Acceptance
     criteria; Plan, Design notes and Progress added by later skills
   - acceptance criteria rules: numbered `AC1`, `AC2`, …; one checkable statement each; `(manual)`
     marks a criterion that needs the user's confirmation; IDs are never renumbered or reused
   - how a plan item names the criteria it serves, and how `## Progress` records each criterion
     (met + test / met + user confirmation / changed / deferred, with the reason)
   - a specification without numbered acceptance criteria is handled as before this change
2. **application — `/aiae:1-plan` refines into the structure** (AC2, AC3, AC4, AC6) —
   `plugins/aiae/skills/1-plan/SKILL.md`:
   - Step 3: replace the "usually reads" template and "keep the user's own structure" with the
     reference to the structure; carry the draft's content into its sections and raise what fits
     none with `AskUserQuestion`; propose criteria when missing or too few, and mark manual ones
   - Step 3 approval checklist: every criterion numbered, specific, checkable, approved
   - Multi-Phase Project Flow step 4: the phase draft carries only the criteria that phase
     delivers, with their original IDs
3. **application — `/aiae:1-plan` traces the plan to the criteria** (AC7) — Step 6: each plan
   item names the criteria it serves; before asking for approval, check that every criterion is
   served by at least one item; Step 7 checklist updated to match
4. **application — `/aiae:stabilize` uses the structure** (AC5) —
   `plugins/aiae/skills/stabilize/SKILL.md` Step 5: the draft template keeps Original work,
   Strategy, What the original does and Gaps against the guidelines, and adds Context, Intent,
   Out of scope and Acceptance criteria per the shared structure; its plan items name criteria
5. **application — `/aiae:multi-phase-spec-pr` uses the structure** (AC6) —
   `plugins/aiae/skills/multi-phase-spec-pr/SKILL.md`: the overall specification is refined into
   the structure (through `/aiae:1-plan` Step 3, which it already delegates to), and each proposed
   phase names the criteria it delivers, so `/aiae:1-plan` can carry them into the phase draft
6. **application — `/aiae:2-implement` uses criteria as goal posts** (AC8, AC15) —
   `plugins/aiae/skills/2-implement/SKILL.md`:
   - Step 0: note whether the spec has numbered criteria; without them, everything below is
     skipped and the skill works as today, without asking
   - Step 1: present the plan items with the criteria they serve
   - before growing the units of a plan item: write the outer acceptance test for each
     automatable criterion it serves, watch it fail for the right reason, keep it red as the goal
     post (it is committed once green, last, as `git-workflow.md` already says)
   - a red flag for starting a plan item's units without its criterion's acceptance test
7. **application — `/aiae:2-implement` checks the criteria before done** (AC9–AC12) — a new
   "Acceptance Criteria Check" before the final Systemic Design Checkpoint:
   - all plan items done → check every criterion; a partial session → only those its items serve,
     listing the rest as unchecked in `## Progress`
   - automatable → name the green test that covers it; manual → show the evidence and ask the user
     to confirm with `AskUserQuestion`
   - not met → `AskUserQuestion` per criterion: **Implement it now** / **Change the criterion** /
     **Defer it**
   - `## Progress` records each criterion's status and evidence; the completion steps and red flags
     updated to match
8. **application — `/aiae:4-create-pr` checks the criteria** (AC13–AC15) —
   `plugins/aiae/skills/4-create-pr/SKILL.md`:
   - read the specification from the working tree, or from the branch history when it was reverted
     or moved (the `docs: feature specification` commit and any later spec commits)
   - Step 3.7 pre-flight: also check the diff against each criterion and report the ones the change
     does not appear to meet; skipped for a spec without numbered criteria
   - Step 3: a deferred criterion recorded in `## Progress` is named in the PR description
9. **delivery — README** (AC16, manual) — `README.md`, "The specification is at the center" and
   the workflow steps: the structure, and how criteria are verified from planning to the PR
10. **validate** (AC17) — run both `claude plugin validate` commands, and try the changed skills
    with `claude --plugin-dir ./plugins/aiae`

## Progress

- [x] 1. specification structure in `project-conventions.md`
- [x] 2–3. `/aiae:1-plan` refines into the structure and traces the plan — one commit, one skill
- [x] 4. `/aiae:stabilize`
- [x] 5. `/aiae:multi-phase-spec-pr` — the phases are written into the overall spec's `## Plan`,
  each naming its criteria, so `/aiae:1-plan` can carry them into a phase draft
- [x] 6–7. `/aiae:2-implement` goal posts and Acceptance Criteria Check — one commit, one skill;
  the check runs before the final Systemic Design Checkpoint
- [x] 8. `/aiae:4-create-pr` — deferred criteria go in a new optional **Not Included** section
- [x] 9. README
- [x] 10. validation passes after every item

Key decisions:

- a skill's own extra sections (e.g. stabilize's Original work) go after the title, before Context
- the uncommitted red goal post is outside the per-commit gate (from the final checkpoint)
- the repository has no automated tests: each criterion was checked by reading the change

Acceptance criteria:

- AC1: met — `project-conventions.md` "The Specification Structure"; skills refer to it
- AC2, AC3, AC4: met — `1-plan` Step 3 "Rewrite it into the specification structure" and approval
  checklist
- AC5: met — `stabilize` Step 5 template
- AC6: met — `multi-phase-spec-pr` refine and plan steps; `1-plan` Multi-Phase Project Flow step 4
- AC7: met — `1-plan` Step 6 and Step 7 checklist
- AC8: met — `2-implement` "Acceptance Criteria as Goal Posts"
- AC9–AC12: met — `2-implement` "Acceptance Criteria Check" and STOP step 1
- AC13, AC14: met — `4-create-pr` "Read the specification", Step 3.7 and "Not Included"
- AC15: met — `2-implement` Step 0, `4-create-pr` "Read the specification", and the guideline's
  "Specifications Without Acceptance Criteria"
- AC16: met — confirmed by the user: the README's structure paragraph and "Acceptance criteria are
  checked at every stage"
- AC17: met — `claude plugin validate .` and `claude plugin validate ./plugins/aiae` pass

Final Systemic Design Checkpoint: ran. Findings 1–4 (goal post vs commit gate, `## Progress`
written once, `1-plan` refers to the guideline, "automatable" named) were applied as fixup commits.

Deferred refactorings:

- phase criteria are matched by wording between the PR roadmap and the overall `## Plan` —
  `1-plan/SKILL.md` Multi-Phase Project Flow, `git-workflow.md` "PR Roadmap Format" (no place for
  IDs); fixing it means changing the roadmap format and `/aiae:multi-phase-sync`, outside this scope
- the pre-flight's "Acceptance criteria" section has no set place in the brief's fixed order —
  `4-create-pr/SKILL.md` Step 3.7, `pr-review/SKILL.md` "Step 4: Produce the Review Brief"
