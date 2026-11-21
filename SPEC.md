# Verify checks written conventions too

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

## Context

`/aido:verify` answers one question: did we build what we agreed to build? It checks requirements,
and reports a broken rule from the repository's `CLAUDE.md` or `AGENTS.md` as a deviation. It
deliberately gives no opinion on style or design.

Conventions are applied while implementing, but the agent that wrote the code is the one checking
them. And verify also runs on PRs built outside the workflow, where nothing applied them. A
two-axis review, conventions and correctness, closes that gap. A full second axis would blur
verify's single question and overlap `/code-review`.

## Intent

Verify also reports, from its fresh context, where the change breaks a written convention. It checks
only written rules: the repository's agent instruction files, and aido's `code-standards.md` and
`testing-principles.md`, where the repository doesn't override them. Each finding names the rule it
breaks and where. These findings sit in their own section of the report, apart from the requirement
buckets, so verify still answers its question first.

## Out of scope

- opinions on style or design with no written rule behind them
- general defects: `/code-review` covers them
- changing how requirements are sorted as verified, insufficient evidence or unmet
- fixing anything: verify still changes nothing

## Acceptance criteria

- AC1: When the change breaks a rule in the repository's agent instruction files, the report lists
  it under a Conventions section, not under Deviations.
- AC2: When the change breaks a rule in `code-standards.md` or `testing-principles.md`, the report
  lists it under Conventions.
- AC3: When the repository's instruction files override an aido rule, the report follows the
  repository's rule.
- AC4: Each convention finding names the rule it breaks, with its source file, and the `path` and
  symbol where it's broken.
- AC5: When the change breaks no written rule, the Conventions section reads `none`.
- AC6: A convention finding never changes how a requirement is sorted.
- AC7: The report doesn't list style or design concerns that no written rule backs.
- AC8 (manual): The README describes verify as checking agreed requirements and written conventions.

## Plan

1. **verify — check written conventions in the Verification Brief** (AC1, AC2, AC3, AC4, AC5, AC6,
   AC7) — inside-out: follows the brief's existing "agreed constraints" check, and how
   `2-implement` hands guideline rules to a fresh-context subagent through "The Design-Check Brief".
   Touches `skills/verify/SKILL.md`:
   - Step 0 also loads `code-standards.md` and `testing-principles.md`. Step 3 tells the subagent
     to read them
   - the brief gains a **conventions** check: written rules only, where the repository wins over an
     aido rule, each finding naming its rule, source file, `path` and symbol
   - broken repository rules move from Deviations to a new `## Conventions` report section, after
     Deviations. `none` when empty. Convention findings never change how a requirement is sorted
   - the intro line "ignores bugs, style and design" and Step 4's closing note are reworded to match
   - `tests/skills.sh` checks that the report template has `## Conventions`, with a failing case in
     `tests/test_skills.py`
2. **eval — verify reports a broken convention** (AC1, AC2, AC4, AC6) — inside-out: follows
   `evals/verify-accepts-a-real-test`. A branch that meets its criteria, with a test that calls the
   behaviour inside its assertion, and a rule from the fixture's `AGENTS.md` that the code breaks.
   Graders: both criteria still verified, and both broken rules listed under Conventions, each
   naming its rule and source
3. **docs — README describes the conventions check** (AC8) — inside-out: follows "Verify what was
   agreed" in `README.md`. Updates that section and the verify row in the Skills table
4. **release — bump the plugin's minor version** (AC1) — inside-out: follows the bump in every
   previous plugin change. `plugins/aido/.claude-plugin/plugin.json`. The PR shows the report before
   and after, since the report format changes

The enabling refactoring analysis was skipped.

## Refactorings

### r1. Name the guideline Step 0 gathers conventions from

- **Change:** In verify's Step 0, name `project-conventions.md` where it says "as the latter describes".
- **Why:** Step 0 now loads four guidelines, so "the latter" points at `testing-principles.md`, which says nothing about gathering conventions.
- **Where:** `plugins/aido/skills/verify/SKILL.md` — `## Step 0: Load Context`
- **Confidence:** high
- **Risk:** None beyond the sentence. No check pins this wording.

### r2. Share one helper that scaffolds an eval case in the eval tests

- **Change:** Extract one helper that runs a case's `fixture.sh` in a temporary directory, and use it in the three test classes.
- **Why:** The same body is copied three times. A change to how fixtures run must be made in each copy.
- **Where:**
  - `tests/test_evals.py` — `ConventionBroken.scaffolded`
  - `tests/test_evals.py` — `ClashReworded.scaffolded`
  - `tests/test_evals.py` — `ClashVerified.scaffolded`
- **Confidence:** high
- **Risk:** Low. Only test code changes, and `tests/all.sh` shows any break.

## Progress

- [x] 1. verify — check written conventions in the Verification Brief
  - the brief checks written conventions in the lines the change adds or edits, and the report lists them under `## Conventions`, after Deviations
  - `tests/skills.sh` checks the report's section order, and keeps the rules for AC3 and AC6 word for word
  - decision: Step 4's note now says verify checks agreed requirements and written conventions only. `/aido:4-open-pr` still copies only deviations into the PR description, so broken conventions no longer reach it
- [x] 2. eval — verify reports a broken convention
  - case `verify-reports-a-broken-convention`: `AGENTS.md` bans `perl`, which `complete` uses, and the AC2 test runs the command inside its check
  - `tests/test_evals.py` checks the fixture: both tests pass, both rules are broken, the branch is clean, and the three graders
- [x] 3. docs — README describes the conventions check
  - "Verify what was agreed", the verify row in the Skills table, and "Review someone else's PR"
- [x] 4. release — bump the plugin's minor version
  - 6.4.0 → 6.5.0
- [x] r1. Name the guideline Step 0 gathers conventions from
- [x] r2. Share one helper that scaffolds an eval case in the eval tests
  - the helper replaces all seven copies in `tests/test_evals.py`, not only the three the finding named, and the one-line `scaffolded` methods are gone
- the final design review ran and recorded r1, r2

### Acceptance

- AC1: met — one run of `verify-reports-a-broken-convention` with aido listed the `AGENTS.md` rule under Conventions, with Deviations `none`
- AC2: met — the same run listed the `testing-principles.md` rule under Conventions
- AC3: deferred — no eval covers it. Only the skill's wording, pinned in `tests/skills.sh`, backs it
- AC4: met — the same run named each rule, its source file, and where it breaks: the `complete` branch of `todo.sh` and the AC2 check in `test_todo.sh`
- AC5: deferred — no eval covers it. Only the report template's `none` rule backs it
- AC6: met — the same run verified AC1 and AC2 while listing both broken rules
- AC7: deferred — no eval covers it. Only the skill's wording backs it
- AC8: met — confirmed by the user: the new paragraph in "Verify what was agreed", the Skills table row and "Review someone else's PR"
