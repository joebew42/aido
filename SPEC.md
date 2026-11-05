# Make aido's language quick to understand

## Context

People sometimes have to think too long to understand aido's specs and acceptance criteria. Long
sentences, abstract wording, too much detail and unfamiliar terms all slow them down. Only PRs,
issues and part of spec writing have language rules today, and nothing covers chat.

## Intent

Everything aido writes for a person should be simple, direct and concise, so it can be understood on
first read. Shorter must not lose what the reader needs. What the skills do stays the same.

## Out of scope

- shortening instructions in skills and guidelines, beyond the wording people see
- renaming internal terms inside those instructions
- changing the skills' steps, approvals, or which questions they ask
- changing labels with an exact meaning, such as `AC1` and `inside-out`
- rewriting specs that are already approved
- a new eval case for language: the PR says language isn't covered

## Acceptance criteria

The language rule

- AC1: When a skill that talks to the user runs, it loads one shared language rule.
- AC2 (manual): The rule asks for short sentences, concrete words, the main point first, and only
  the detail the reader needs.
- AC3 (manual): The rule asks for plain words instead of workflow terms when talking to the user.
- AC4 (manual): The rule says a question must make sense alone and say what each option does.
- AC5 (manual): The rule covers chat answers, explanations, summaries and status updates.

Questions

- AC6 (manual): When a skill dictates a question or option, its wording follows the rule, and it
  still offers the same choices.
- AC7 (manual): When a dictated question names a workflow term, such as "Systemic Design
  Checkpoint", it uses plain words instead.

Specifications

- AC8 (manual): When a spec is written, its Context and Intent aim for about 3 sentences each, and
  may run over when the content needs it.
- AC9 (manual): When a criterion describes behaviour with a trigger, it uses a when/then shape.
- AC10 (manual): When a criterion is written, it aims for about 20 words and stays checkable.
- AC11 (manual): When a spec is written, file names and symbols stay in the plan, unless a criterion
  is about that file.
- AC12 (manual): When a plan item is written, it uses short sentences and keeps its criteria, mode
  and reason.

PRs, issues and reports

- AC13 (manual): When a PR description or GitHub issue is written, it follows the rule and keeps its
  sections.
- AC14 (manual): When a subagent writes a report for the user, such as `/aido:verify`'s, it follows
  the rule and keeps its sections.

Overall

- AC15 (manual): When a person reads a spec written with these rules, they understand its
  description and criteria on first read.
- AC16: When the existing eval cases for the changed skills run, no check scores worse.

## Plan

Skills and guidelines are the only layers here, so each item names those instead of domain,
application or infrastructure.

1. **refactor: gather the existing language rules in one guideline** (enabling) — guidelines, skills.
   Create `guidelines/language.md` with what `4-create-pr`, `github-issues.md` and `1-plan` Step 3
   already say. Each then points to it. The PR checklist keeps a checklist item
2. **load the rule in every skill** (AC1) — inside-out: follows the load lines in
   `3-organize-commits`, and `check` in `tests/hooks.sh` for the test. Touches skills, tests. Adds a
   load step to `multi-phase-switch` and a row to the README's guideline table
3. **write the language rule** (AC2, AC3, AC4, AC5) — inside-out: extends `language.md` from item 1.
   Touches guidelines. It exempts the project's own domain terms and exact labels
4. **shorten the dictated questions** (AC6, AC7) — inside-out: the questions already exist in each
   skill, and only their wording changes. Touches skills, guidelines
5. **add the spec targets** (AC8, AC9, AC10, AC11, AC12) — inside-out: extends "The Specification
   Structure" and "Plan Items" in `specification.md`. Touches guidelines
6. **cover PRs and issues** (AC13) — inside-out: builds on items 1 and 2, and checks the tracking PR
   in `multi-phase-spec-pr`, which doesn't use the `4-create-pr` rules. Touches skills, guidelines
7. **cover subagent reports** (AC14) — inside-out: follows the "copied" brief pattern in `verify`,
   `assess-architecture`, `1-plan` and `2-implement`. Touches skills
8. **confirm the result** (AC15, AC16) — inside-out: follows `docs/evals.md`, and
   `claude --plugin-dir ./plugins/aido` for a real spec to read. No evals run for now, by the user's
   choice, so `## Progress` records AC16 as deferred

## Design notes

- **Where it belongs:** sentence style goes in a new `guidelines/language.md`. Spec shape goes in
  `guidelines/specification.md`, which already owns it. Each skill loads guidelines itself, so every
  `SKILL.md` needs a load line.
- **Existing behaviour and abstractions to reuse:**
  - `guidelines/specification.md` — "Acceptance Criteria", "Plan Items"
  - `skills/4-create-pr/SKILL.md` — "PR Description Checklist", "Default Sections"
  - `guidelines/github-issues.md` — its pointer to the PR rules
  - `skills/1-plan/SKILL.md` — Step 3 **wording** bullet
  - `skills/verify/SKILL.md` — "The Verification Brief", the pattern for copying rules to a subagent
- **Boundaries that must hold:**
  - Plain words replace aido's terms, never the host project's domain terms.
  - The rule doesn't remove required specifics. `guidelines/pr-roadmap.md` still asks for
    implementation-focused language.
  - Labels that skills read stay exact: `AC<n>`, `(manual)`, `met`, `changed`, `deferred`,
    `unchecked`, `(enabling)`, and the mode names.
  - `/aido:verify` shows its report unchanged, so the rule must reach it through the brief.
- **Other modules or consumers affected:** all 13 skills, the README's guideline table, and
  `docs/evals.md`. No grader or parser depends on the wording of a question.
- **Enabling refactorings (planned):** item 1.
- **Deferred:**
  - **Move "Interaction Style" next to the language rule**
  - **Observation:** the only other rule on talking to the user is in `code-standards.md`, which 6
    skills load.
  - **Evidence:** `guidelines/code-standards.md` — "Interaction Style"; `README.md` — guideline table.
  - **Competing explanations:** it covers when to use `AskUserQuestion`, not wording, so the split
    may be fine. No change may be needed.
  - **Assumptions:** keeping the two apart will cause drift.
  - **Confidence:** medium.
  - **What would change it:** a later change to one that the other should have followed.
  - **Recommendation:** move the section into `language.md` and update the README row.
  - **Risk:** six skills' load lists and a README row would need checking.
- **Open questions:** none block implementation.

## Progress

All 8 plan items are done.

- AC1: met — `tests/skills.sh` passes for all 13 skills
- AC2, AC3, AC4, AC5: met — confirmed by the user: a summary of `guidelines/language.md`
- AC6, AC7: met — confirmed by the user: before and after examples of the questions
- AC8, AC9, AC10, AC11, AC12: met — confirmed by the user: a summary of the targets in
  `guidelines/specification.md`
- AC13, AC14: met — confirmed by the user: a summary of the rule reaching PRs, issues and briefs
- AC15: met — confirmed by the user: a sample TODO spec. A fresh agent wrote it from the new rules,
  not through the full `/aido:1-plan` flow
- AC16: deferred — the user chose not to run evals for now

Decisions:

- The final design review found that some words had two names, so the user chose to align them. The
  README, two skill descriptions and one report now use "save", "map" and "design review". The
  descriptions keep "index" and "refactoring opportunities" as trigger words.
- The user chose plainer option labels in `/aido:1-plan`: **Plan it in one step** and **Plan it
  fully**. The section names in the instructions stay.
- `docs/evals.md` didn't change, because no evals ran.

Deferred refactorings: "Move 'Interaction Style' next to the language rule", under `## Design notes`,
with all its fields. It is saved in `refactoring-opportunities/`.
