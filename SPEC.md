# Ask before running the enabling and final refactoring analyses

GitHub Issue: https://github.com/joebew42/ai-augumented-engineer/#2

## Context

Two steps of the workflow always launch a `fable` subagent for a systemic refactoring analysis:

- the **enabling refactoring analysis** — `/aiae:1-plan` Step 5, fed by the architecture-index
  check in Step 4
- the **final Systemic Design Checkpoint** — the "Before completion" checkpoint of
  `/aiae:2-implement`, run once every plan item is implemented

Both can take a long time, and for some changes they are not needed. Today the user cannot skip
them.

## Goals

- the user decides, each time, whether the enabling refactoring analysis runs in `/aiae:1-plan`
- the user decides, each time, whether the final Systemic Design Checkpoint runs in
  `/aiae:2-implement`
- skipping either one leaves the rest of the skill working, and leaves a trace where it matters

## Out of scope

- the on-evidence Systemic Design Checkpoint during TDD in `/aiae:2-implement` — it runs inline,
  scoped to the evidence, and is unchanged
- `/aiae:assess-architecture` and `/aiae:map-architecture` — the user invokes them explicitly
- remembering the answer across runs or per repository

## Acceptance criteria

### `/aiae:1-plan`

- before the architecture-index check, the skill asks with `AskUserQuestion` whether to run the
  enabling refactoring analysis; neither option is marked as recommended
- this applies on both paths into the check: after refining a new draft, and when entering with an
  existing `SPEC.md`
- on **run**, the architecture-index check and the enabling refactoring analysis behave as today
- on **skip**:
  - the architecture-index check does not run, so the user is not offered to build or update the
    index
  - no subagent is launched
  - the plan is proposed without enabling refactorings
  - `SPEC.md` has no `## Design notes` section; instead it carries one line saying the enabling
    refactoring analysis was skipped
  - the checks before preparing the feature branch accept a `SPEC.md` without `## Design notes`
    when the analysis was skipped

### `/aiae:2-implement`

- once every plan item is implemented, before the final Systemic Design Checkpoint, the skill asks
  with `AskUserQuestion` whether to run it
- the **run** option is marked as recommended only when the diff against main touches more than
  one module or area, or introduces a new domain concept or abstraction; diff size alone does not
  count. Otherwise the **skip** option is marked as recommended
- the question states briefly why the recommended option is recommended
- on **run**, the checkpoint behaves as today; when `SPEC.md` has no `## Design notes`, the
  subagent is not asked to check them
- on **skip**:
  - no subagent is launched
  - implementation can complete — neither the completion conditions nor the red flags require the
    final checkpoint to have run
  - the `## Progress` section of `SPEC.md` records that the final Systemic Design Checkpoint was
    skipped

### Guidelines

- "Systemic Refactoring" in `code-standards.md` describes the planning-time and before-done checks
  as offered to the user, not mandatory

## Plan

This repository's "code" is skill and guideline text, so the layers map as: the guideline holds
the rule (domain), the skills apply it (application). Ordered inside-out:

1. **`code-standards.md` — "Systemic Refactoring"** (guideline): reword the "when planning" and
   "before the feature is done" bullets so both checks are offered to the user rather than
   mandatory; "during implementation, on evidence" is unchanged. Stay generic — no step numbers,
   no `AskUserQuestion` mechanics, no recommendation rule
2. **`/aiae:1-plan`** (skill):
   - add the question at the start of Step 4, before the index check, on both entry paths (after
     Step 3, and Step 1's "`SPEC.md` exists → continue at Step 4"). Shape it like `/aiae:4-create-pr`
     Step 3.7: options **Run the analysis** / **Skip it**, neither marked as recommended
   - on skip: bypass the rest of Step 4 and all of Step 5, and go to Step 6
   - Step 6: on skip, propose the plan without enabling refactorings and, instead of
     `## Design notes`, write one line after `## Plan` saying the enabling refactoring analysis
     was skipped
   - Step 7 entry checklist: require `## Design notes` only when the analysis ran
3. **`/aiae:2-implement`** (skill):
   - "Before completion": ask first, with options **Run the checkpoint** / **Skip it**. Mark
     **Run** as `(Recommended)` when the diff against main touches more than one module or area,
     or introduces a new domain concept or abstraction, and **Skip** otherwise; diff size alone
     does not count. The question says briefly why the recommended option is recommended
   - the subagent brief asks it to check the Design notes only when `SPEC.md` has them
   - on skip: no subagent; go on to completion
   - "STOP — Skill Complete" and the red flag "Declaring the feature done without the final
     Systemic Design Checkpoint": accept a checkpoint the user chose to skip
   - `## Progress`: record that the final Systemic Design Checkpoint was skipped, when it was
4. run `claude plugin validate .` and `claude plugin validate ./plugins/aiae`

## Design notes

- **Where it belongs:** `plugins/aiae/guidelines/code-standards.md` — "Systemic Refactoring — Look
  Beyond the Changed Lines" (the only definition of the three checks);
  `plugins/aiae/skills/1-plan/SKILL.md` — Step 4, Step 5, Step 6 (`## Design notes` template),
  Step 7 entry checklist, and Step 1's existing-`SPEC.md` path;
  `plugins/aiae/skills/2-implement/SKILL.md` — "Before completion — `fable` subagent", Red Flags,
  "STOP — Skill Complete" and its `## Progress` contents
- **Existing behaviour and abstractions to reuse:**
  - `plugins/aiae/skills/4-create-pr/SKILL.md` — "Step 3.7: Pre-Flight Review (Optional)", the
    shape of an optional step behind `AskUserQuestion`
  - the `(Recommended)` label suffix: `map-architecture/SKILL.md` (**Update (Recommended)**),
    `3-organize-commits/SKILL.md` (**Revert it (Recommended)**); `pr-review/SKILL.md` gives the
    instruction form for a recommendation that depends on context
  - `2-implement/SKILL.md` "Starting context" already says "the spec's `## Design notes`, if
    `/aiae:1-plan` wrote them"; `/aiae:stabilize` and `/aiae:multi-phase-spec-pr` already write
    a `SPEC.md` without Design notes
  - `## Progress` in `2-implement/SKILL.md` already records key decisions and deferred
    refactorings — the home for the skip note
  - existing vocabulary for the recommendation rule: "module", "area", "domain concept",
    "abstraction" (`code-standards.md`, `map-architecture/SKILL.md`)
- **Boundaries that must hold:** the repo's `CLAUDE.md` conventions (`${CLAUDE_PLUGIN_ROOT}/...`
  in skills, file names between guidelines, rules live in skills or guidelines);
  `code-standards.md` stays generic; the on-evidence checkpoint is untouched;
  `.skip-map-architecture` keeps its "never ask for this repo" meaning and is not reused for
  the answer to this question; the "run" paths and the `fable` fallback sentence stay as they are
- **Other modules or consumers affected:** only `/aiae:2-implement` reads `## Design notes`;
  `/aiae:3-organize-commits`, `/aiae:4-create-pr`, `/aiae:5-handle-review`, `/aiae:pr-review` and
  `/aiae:multi-phase-sync` read neither Design notes nor `## Progress`; `README.md` and
  `git-workflow.md` don't describe when the analyses run — no change
- **Enabling refactorings (planned):** none
- **Deferred:** the `fable` fallback sentence repeated verbatim in five skills could become one
  guideline paragraph — superficial, and broader than this change
- **Open questions:** none

## Progress

- [x] `code-standards.md` — the planning and before-done systemic checks are offered, not required
- [x] `/aiae:1-plan` — asks before the index check; the skip path bypasses Steps 4–5 and replaces
  `## Design notes` with one line; the Step 7 checklist accepts that line
- [x] `/aiae:2-implement` — asks before the final checkpoint, recommending a run or a skip by
  design reach; Design notes checked only when present; a skip satisfies "STOP" and the red flag,
  and is recorded in `## Progress`
- Key decisions: option labels **Run the analysis** / **Run the checkpoint** / **Skip it**; the
  skip line in `SPEC.md` reads `The enabling refactoring analysis was skipped.`
- The user skipped the final Systemic Design Checkpoint
- Deferred refactorings: none new (the `fable` fallback sentence repeated across five skills stays
  deferred, see Design notes)
