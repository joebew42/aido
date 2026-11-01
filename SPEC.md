# Make the skills and guidelines more concise

## Context

Spec-driven agentic workflows have become common practice, so we compared this workflow with the
most widely adopted ones: Superpowers, mattpocock/skills, GitHub Spec Kit, OpenSpec, BMAD and Kiro.

The comparison found that the workflow already covers their core practices: project principles
through `CLAUDE.md` and `AGENTS.md`, asking rather than guessing, and acceptance criteria traced
from the plan through to the PR. It found two practices worth adopting, which are tracked in
[issue #9](https://github.com/joebew42/ai-augmented-engineer/issues/9).

The comparison also pointed at what the workflow costs to load. A skill reads its guidelines whole
before any work starts, so `/aiae:2-implement` and `/aiae:pr-review` each load about 18k tokens up
front. `code-standards.md` alone is about 7k tokens, and it includes sections that only some steps
need. Some rules are stated in several places, such as the TDD cycle and the pre-commit gate.
Anthropic's skill authoring guidance is to add only what the agent doesn't already know, because
every token competes with the rest of the session's context.

Making the workflow smaller first also means the practices in issue #9 are added to a smaller
workflow.

## Intent

Reduce what the skills load, and remove repetition across the skills and guidelines, so that agents
spend fewer tokens on instructions. The workflow keeps its stages, its checkpoints and its rules.

A skill's **upfront load** is the estimated tokens (characters ÷ 4) of its `SKILL.md` plus every
guideline file it tells the agent to read on every run. A read that depends on a condition, such as
a Systemic Design Checkpoint happening, does not count. The **baseline** is commit `67c35c7`.

## Out of scope

- adopting new practices: the small-change path and starting from a conversation are in issue #9
- changing what a skill does, the order of the stages, or when the user is asked to decide; the only
  exceptions are the changes AC6, AC12 and AC13 make
- automated skill evals, which we decided against
- a bug-fix flow, a fresh-context review, a subagent per plan item and lasting specs, which we
  decided against
- a glossary or decision records, which are a convention for each host repository, not this workflow
- support for agents other than Claude Code

## Acceptance criteria

- AC1: the upfront load of `/aiae:2-implement` is at most 12,837 tokens, at least 30% below its
  baseline of 18,339
- AC2: the upfront load of `/aiae:pr-review` is at most 12,546 tokens, at least 30% below its
  baseline of 17,923
- AC3: no other skill's upfront load is higher than its baseline: `1-plan` 15,446, `3-organize-commits`
  5,229, `4-create-pr` 13,633, `5-handle-review` 15,194, `assess-architecture` 10,618,
  `map-architecture` 11,933, `multi-phase-spec-pr` 5,328, `multi-phase-switch` 329, `multi-phase-sync`
  9,671, `resolve-migration-conflict` 5,295, `stabilize` 16,069
- AC4: every guideline file and named section referred to from a skill or a guideline exists
- AC5 (manual): every rule that no longer loads up front is still reached by each skill that relied
  on it, at the point that skill needs it
- AC6: the PR description checklist in `/aiae:4-create-pr` no longer forbids bullet lists outright:
  it keeps the rule of narrative for small, focused changes and bullets for three or more distinct
  changes
- AC7 (manual): the TDD cycle and the pre-commit gate are each defined in one place, and every other
  mention refers to it rather than restating it
- AC8 (manual): every passage removed from the skills and guidelines is listed as moved (with where
  to), a duplicate (with the location that keeps it), or dropped (with the reason), and the user has
  reviewed that list
- AC9 (manual): the skills and guidelines still follow the repository's conventions in `CLAUDE.md`,
  and the README's description of the guidelines is still accurate
- AC10: `claude plugin validate .` and `claude plugin validate ./plugins/aiae` both pass
- AC11: `version` in `plugins/aiae/.claude-plugin/plugin.json` is bumped from `1.2.0`
- AC12: `/aiae:multi-phase-spec-pr` asks with `AskUserQuestion` before pushing, as `git-workflow.md`
  requires
- AC13: `/aiae:multi-phase-spec-pr` puts the link to the specification in one position, the top of the
  PR description, in both its Required Sections and its template

## Plan

This repository has no test suite and no code layers: every item changes Markdown or the manifest.
Automatable criteria are checked with commands, and moves come first so that each later diff shows
only content changes. Headings named by other files keep their names unless the item says otherwise.

1. **refactor — move Evolving Guidelines to `evolving-guidelines.md`** (enabling): loaded at the step
   that uses it in `/aiae:4-create-pr`, `/aiae:5-handle-review` and `/aiae:multi-phase-sync`; update
   the reason text in `hooks/hooks.json`
2. **refactor — move Systemic Refactoring to `systemic-refactoring.md`** (enabling): its pointers name
   `code-standards.md`; `/aiae:2-implement` explicitly allows this one read during TDD, at the first
   checkpoint
3. **refactor — move the specification rules to `specification.md`** (enabling): The Specification
   File and The Specification Structure, with every reference updated
4. **refactor — move the TDD cycle and step-size text to `tdd.md`** (enabling): loaded by
   `/aiae:2-implement` and `/aiae:5-handle-review`
5. **refactor — move the roadmap rules to `pr-roadmap.md`** (enabling): loaded by `/aiae:4-create-pr`,
   `/aiae:multi-phase-spec-pr` and `/aiae:multi-phase-sync` where they need them
6. **refactor — define the per-commit gate once** (AC7): one short "Before Every Commit" section in
   `git-workflow.md`, replacing `code-standards.md` Quality Checks and the suite-scope section of
   `testing-principles.md`; skills point to it
7. **`/aiae:2-implement` — stop restating the guidelines** (AC1, AC7): keep the orchestration, and
   point to `tdd.md` and `git-workflow.md` for the cycle, the commit rules and the commit strategy
8. **guidelines — tighten `testing-principles.md` and `code-standards.md`** (AC1, AC2): state the flaky
   test rule once; keep a shorter worked example showing each role, and fewer comment examples
9. **`/aiae:pr-review` — remove its own repetition** (AC2): the two verification procedures and the
   output format restatement
10. **`/aiae:4-create-pr` — resolve the bullet list contradiction** (AC6): remove the blanket "not
    bullet lists" line
11. **remaining skills — replace restatements with pointers** (AC3, AC5): the spec file preamble, the
    "never leave both" rule and commit rules, keeping an explicit load line in `/aiae:multi-phase-spec-pr`
    and `/aiae:4-create-pr`, whose preamble is their only load; trim `/aiae:3-organize-commits` and
    `/aiae:multi-phase-spec-pr` as needed to stay under baseline
12. **references and README — check everything still connects** (AC4, AC5, AC9): resolve every file and
    section reference, confirm each rule is reached where it is needed, and update the README's
    guideline list
13. **removal list — record every removed passage in `## Progress`** (AC8): moved, duplicate or dropped,
    for the user to review
14. **release — measure, validate and bump** (AC1, AC2, AC3, AC10, AC11): measure every skill against
    its baseline, run both `claude plugin validate` commands, and bump `version` to `1.2.1`
15. **`/aiae:multi-phase-spec-pr` — fix the two inconsistencies** (AC12, AC13): ask before pushing, and
    keep the specification link at the top of the description

## Design notes

- **Where it belongs:** the TDD cycle in `tdd.md`, because `/aiae:5-handle-review` needs it as well as
  `/aiae:2-implement`. The per-commit gate in `git-workflow.md`, because `/aiae:3-organize-commits`,
  `/aiae:resolve-migration-conflict` and `/aiae:multi-phase-spec-pr` load that file and not
  `code-standards.md`. The spec file rules in `specification.md`
- **Existing behaviour and abstractions to reuse:** `skills/1-plan/SKILL.md` — the on-demand wording
  "load it before Step 7" and "read that file now if it is not loaded yet";
  `guidelines/project-conventions.md` — "It is defined here only; skills refer to it rather than
  restating it"; `guidelines/code-standards.md` — the pointer form `"<rule>" under <Section>`;
  `hooks/hooks.json` — already enforces the no-trailer and no-auto-memory rules
- **Boundaries that must hold:** only a separate file can leave the upfront load, because files are read
  whole. Subagent briefs copy guidelines and sections (`1-plan`, `2-implement`, `assess-architecture`,
  `map-architecture`), and `multi-phase-spec-pr`, `stabilize`, `4-create-pr` and `assess-architecture`
  refer to other skills' steps by number, so those names and numbers stay. These look alike but mean
  different things, and are not merged: which test level (`code-standards.md`) and which collaborators
  to mock (`testing-principles.md`); the criteria check from evidence in `/aiae:2-implement` and from
  the diff in `/aiae:4-create-pr`; the three ways of locating a spec through its commit;
  `/aiae:stabilize` stopping when a spec exists and the other skills deleting a stray draft
- **Other modules or consumers affected:** `README.md` — the guideline list; `hooks/hooks.json` — reason
  strings naming guideline files. "Do not use auto-memory" moves with Evolving Guidelines and is read
  later, but the hook still enforces it on every run
- **Enabling refactorings (planned):** items 1–5
- **Deferred:** `skills/map-architecture/SKILL.md`
  — its index format is loaded by neither target skill, so tightening it is a separate change
- **Open questions:** none. AC1 was reached without removing a rule (see `## Progress`)

## Progress

### Implemented

- [x] items 1–5: moved to `evolving-guidelines.md`, `systemic-refactoring.md`, `specification.md`,
  `tdd.md` and `pr-roadmap.md`
- [x] item 6: one per-commit gate, "Before Every Commit" in `git-workflow.md`
- [x] items 7–11: `/aiae:2-implement`, the guidelines, `/aiae:pr-review`, `/aiae:4-create-pr` and the
  remaining skills
- [x] items 12 and 14: references, README and version `1.2.1`

### Removal list (AC8)

**Moved**

- `code-standards.md` Evolving Guidelines → `evolving-guidelines.md`
- `code-standards.md` Systemic Refactoring → `systemic-refactoring.md`
- `code-standards.md` Test-Driven Methodology and Test-First vs. Strict TDD → `tdd.md`
- `project-conventions.md` The Specification File and The Specification Structure → `specification.md`
- `git-workflow.md` Multi-Phase PR Context and PR Roadmap Format → `pr-roadmap.md`
- `code-standards.md` Before Every Commit and `testing-principles.md` Scope the Pre-Commit Suite →
  `git-workflow.md` Before Every Commit

**Duplicate** (the location that keeps it)

- `/aiae:2-implement` RED, GREEN and REFACTOR checklists, test-driven intro → `tdd.md`, which gained
  the "no second test while red", "embarrassing hardcoded value", "do not refactor yet", magic numbers,
  Single Level of Abstraction and small-steps wording
- `/aiae:2-implement` TDD and commit Red Flags → condensed to two flags pointing to `tdd.md` and the gate
- `/aiae:2-implement` Commit Messages and Implementation Strategy, `/aiae:3-organize-commits` in-scope
  list and commit checklist lines, `/aiae:multi-phase-spec-pr` commit checklist,
  `/aiae:resolve-migration-conflict` commit parenthetical → `git-workflow.md`; the no-trailer rule is
  also enforced by the hook
- `/aiae:2-implement` host conventions paragraph → `project-conventions.md`
- quality checks in `/aiae:2-implement`, `/aiae:5-handle-review`, `/aiae:resolve-migration-conflict`,
  and `code-standards.md` Before Marking Tasks Complete → the gate
- spec file preamble (shortened) → `specification.md`, which also gained "delete the draft and tell the
  user"; `/aiae:2-implement` keeps that step and lost only its trailing clause
- `/aiae:pr-review` comment verification steps → condensed, pointing to its own card verification
- `/aiae:multi-phase-spec-pr` "MUST include link to `SPEC.md`" checklist line → its Required Sections
- `/aiae:multi-phase-spec-pr` "BEFORE creating the PR, commit" sentence → the order of its steps and
  the commit line below it
- `testing-principles.md` Summary Checklist and numbered flaky-test guidelines → condensed into the
  five bullets of its flaky-test section

**Dropped** (with the reason)

- `/aiae:4-create-pr` "use paragraph/narrative style, not bullet lists": the contradiction AC6 resolves
- `/aiae:pr-review` Output Format section: restated the opening of Step 4; only "clean markdown with
  section headers" is gone, which the required section format already implies
- `/aiae:multi-phase-spec-pr` branch name examples and why the pattern exists: the pattern stays
- `testing-principles.md` second flaky-test example, per-guideline examples, the Arrange-Act-Assert
  "Why", the longer reasons against hoisting stubs and re-asserting effects, and the note that
  per-effect assertions were correct before extraction: explanation, the rules stay
- `code-standards.md` worked example: blank lines and two branches condensed, every role stays
- `code-standards.md` Comments: two of the six examples, the sentence on comments that make a reader
  "slightly slower", examples of external knowledge, and "both halves are required": the bar stays
- `code-standards.md` third-party libraries and domain vocabulary: reasons and examples, the rules stay

### Acceptance criteria

- AC1: met — 12,758 of 12,837, measured with characters ÷ 4
- AC2: met — 10,862 of 12,546, measured with characters ÷ 4
- AC3: met — every other skill is below its baseline; `multi-phase-switch` is unchanged
- AC4: met — a script resolved every file and quoted section reference
- AC5: met — confirmed by the user: the on-demand reads and the steps that use them. The final
  checkpoint then found four gaps, fixed in `refactor: restore the rules the checkpoint found out of reach`
- AC6: met — the checklist line is gone; narrative or bullets is decided by the number of changes
- AC7: met — confirmed by the user: `tdd.md` and "Before Every Commit" in `git-workflow.md`
- AC8: met — confirmed by the user: this removal list
- AC9: met — confirmed by the user: conventions and the README's guideline list
- AC10: met — both `claude plugin validate` commands pass; one warning about a missing icon, unrelated
- AC11: met — `1.2.1`
- AC12: met — Step 2 of `/aiae:multi-phase-spec-pr` asks with **Push** / **Cancel**
- AC13: met — Required Sections and the template both put the link at the top

### Decisions

- the gate's comment rule points to `code-standards.md`, which `/aiae:3-organize-commits` and
  `/aiae:resolve-migration-conflict` don't load; they only read it if a diff adds comments
- `/aiae:3-organize-commits` keeps "All tests pass" beside the gate, because it asks for more than the
  gate's relevant tests

- AC12 and AC13 were added at the user's request after the final checkpoint. The link stays at the
  top, where the template already put it
- the final Systemic Design Checkpoint ran; its findings are fixed, except the stray-draft wording in
  `/aiae:1-plan`, `/aiae:2-implement` and `/aiae:multi-phase-spec-pr`, kept as each skill's own state check

### Deferred

- `skills/map-architecture/SKILL.md` index format: loaded by neither target skill
