# Ask which tests to run in `/aido:2-implement loop`

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

GitHub Issue: https://github.com/joebew42/aido/#110

## Context

After each plan item, `/aido:2-implement loop` checks the child's work by running the whole test
suite. In a large codebase, that run is slow and expensive, and it repeats for every item. A single
session already runs only the relevant tests, at each commit.

## Intent

Before the loop runs its first item, the user chooses which tests the loop runs after each item: the
whole test suite, or only the relevant tests. "Relevant" means the same as in the per-commit check.
An unattended loop doesn't block on the question, in Claude Code or in Copilot CLI.

## Out of scope

- a single `/aido:2-implement` session, which keeps running only the relevant tests at each commit
- the per-commit check, and what it counts as relevant
- a final run of the whole suite after the last item, when the user chose the relevant tests

## Acceptance criteria

- AC1: When `/aido:2-implement loop` starts, it asks whether to run the whole test suite or only the
  relevant tests after each item, before the first item runs.
- AC2: When the user chooses the whole test suite, the loop runs it after each item, as today.
- AC3: When the user chooses the relevant tests, the loop runs after each item only the tests the
  per-commit check counts as relevant.
- AC4: When nobody answers the question, the loop runs only the relevant tests after each item.
- AC5: When the user chooses the relevant tests, the loop's check after each item never runs the whole
  test suite.

## Plan

1. **the loop asks which tests to run** (AC1, AC2, AC3, AC4, AC5) — inside-out: follows the loop's
   own question handling in "When a child returns a question", and the reference to
   "Before Every Commit" in `/aido:3-organize-commits` "Run the Tests Once". Touches application
   - first, in `tests/skills.sh`: replace the "and ask nothing" pin, and pin the question, its two
     options, the reference to "Before Every Commit" and the no-answer rule. See them fail
   - in `plugins/aido/skills/2-implement/SKILL.md`, "Loop Mode": "Before the first child" asks once,
     after showing the items, with options **Whole test suite** / **Relevant tests only**. With no
     answer, or when asking is unavailable, it says so and goes on with the relevant tests, in the
     same turn. A loop that doesn't start asks nothing
   - "For each item, in order", step 2: the test check runs what the user chose. Relevant means
     "Before Every Commit" in `git-workflow.md`, for the files the child's commits and the branch
     changed. Lint and the clean tree are checked under both choices
   - `README.md`: the `/aido:2-implement` row mentions the question. Bump `version` in
     `plugins/aido/.claude-plugin/plugin.json` to 6.4.0
2. **Copilot CLI lets the loop go on without an answer** (AC4) — inside-out: follows "Approvals" in
   `plugins/aido/guidelines/copilot-cli.md`. Touches domain
   - first, pin the exception in `tests/skills.sh`, and see it fail
   - add one narrow exception to "Approvals": the loop's question about which tests to run goes on
     with the relevant tests when nobody answers, as `/aido:2-implement` says
3. **an eval shows an unattended loop runs only the relevant tests** (AC3, AC4, AC5) — inside-out:
   follows `implement-loops-over-the-plan` and its fixture on `implement-todo.sh`. Touches
   infrastructure
   - a new case, `implement-loop-runs-the-relevant-tests`: the fixture adds a second test file,
     unrelated to the plan, that leaves a marker when it runs. A check confirms the items are ticked
     and the marker is absent. A grader confirms the loop said it went on with the relevant tests
   - add its row to `docs/evals.md`. Propose one run of the loop cases, and ask first

The enabling refactoring analysis ran and found nothing to plan first.

## Design notes

- **Where it belongs:** `plugins/aido/skills/2-implement/SKILL.md` — "Loop Mode", in "Before the
  first child" (the question) and "For each item, in order" step 2 (the check). That step is the only
  place in the plugin that runs the whole suite. Children and "Child Mode" stay as they are.
- **Existing behaviour and abstractions to reuse:** `plugins/aido/guidelines/git-workflow.md` —
  "Before Every Commit" defines relevant tests; refer to it, don't restate it, as
  `plugins/aido/skills/3-organize-commits/SKILL.md` — "Run the Tests Once" does.
  `plugins/aido/skills/2-implement/SKILL.md` — "Global guidelines" already loads `git-workflow.md`.
  `plugins/aido/guidelines/language.md` — "Asking Questions" shapes the question.
- **Boundaries that must hold:** `tests/skills.sh` pins wording word for word, and fails on a
  reference to a section that doesn't exist. "Before Every Commit" and `tdd.md` stay unchanged. Lint
  and the clean tree are still checked after each item. The loop evals run without `AskUserQuestion`,
  so the loop must not end its turn at the question.
- **Other modules or consumers affected:** `plugins/aido/guidelines/copilot-cli.md` — "Approvals"
  (item 2). `plugins/aido/evals/implement-loops-over-the-plan`, `implement-loop-runs-a-refactoring`
  and `implement-loop-stops-on-an-unanswered-question` now take the relevant-tests path; their single
  test file makes both choices the same run. `docs/evals.md`, `README.md`. The local architecture
  map's line for the loop orchestrator goes stale until `/aido:map-architecture` updates it.
- **Enabling refactorings (planned):** none.
- **Deferred:** none.
- **Open questions:** none. The choice isn't saved: running `loop` again asks again, as AC1 says.
