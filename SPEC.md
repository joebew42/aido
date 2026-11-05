# 2-implement: a `loop` mode that runs each plan item in a fresh child session

GitHub Issue: https://github.com/joebew42/aido/#41

## Context

A long plan done in one session fills the context. The guidelines get compacted away, and later items
are built with less of the spec in view. `/aido:2-implement` already resumes from `git log` and the
spec's `## Progress`, so the handoff between sessions exists. Today the user loops by hand: run the
skill, stop, run it again.

## Intent

`/aido:2-implement loop` lets the main session orchestrate the plan. It starts one fresh `Agent`
subagent per plan item, and checks each item before starting the next. Each item is built with the
full spec and guidelines in view, and the user no longer restarts the skill by hand. Questions a child
reaches still go to the user, through the orchestrator.

## Out of scope

- running children in parallel, or as `claude -p` processes
- retrying a failed item on its own: a failed check stops the loop
- running unattended: questions still reach the user
- a loop mode in any other skill
- changing how `/aido:2-implement` works without `loop`

## Acceptance criteria

Starting the loop

- AC1: When the skill is run without `loop`, it behaves as it does today.
- AC2: When run as `loop`, it runs every plan item not yet ticked in `## Progress`, in plan order.
- AC3: When run as `loop 7-9`, it runs only items 7 to 9, skipping and naming any already ticked.
- AC4: When the range names an item the plan doesn't have, the loop doesn't start and says why.
- AC5: Before the first child starts, the orchestrator checks the alignment with the repository once.
  It shows the items it will run with their criteria, and asks nothing about scope.

Each child

- AC6: Each item runs in its own fresh `Agent` subagent, briefed with the item and the spec file's path.
- AC7: A child implements only its item: goal posts, TDD, commits and the check of its criteria. It
  never edits the spec file, and returns its results to the orchestrator instead.
- AC8: A child doesn't check the alignment, ask about scope, run the final design review or ask
  about organizing the commits.
- AC9: When a child reaches a question for the user, it pauses and returns the question. The
  orchestrator asks the user and sends the answer back to that same child, which carries on.
- AC17: When a relayed question gets no answer, the loop stops. It names the paused item and the items
  not yet run.

Between children

- AC10: After each child, the orchestrator checks three things: the child's results give each of the
  item's criteria as `met`, `changed` or `deferred`, the working tree is clean, and lint and the full
  suite pass.
- AC11: When all three pass, the next child starts.
- AC12: When one fails, the loop stops and reports what failed and the items not yet run.

Finishing

- AC13: After the last item of the whole plan, the orchestrator asks in one question about the final
  design review and organizing the commits, as the skill does today.
- AC14: When the range ends before the plan does, the orchestrator names the items left, and asks
  neither of those things.

Coverage

- AC15: An eval case runs a two-item plan with `loop`. It checks that each item gets its own commits
  and Progress tick, and that the final question comes only after the last item.

Progress

- AC16: Only the orchestrator writes the spec file. When an item passes its checks, the orchestrator
  ticks it in `## Progress` with the child's results, and commits that update before the next child
  starts.

## Plan

The skill's rules are Markdown, so a criterion's goal post is a check in the new eval case (item 6) or a
phrase check in `tests/skills.sh`. Each item adds its checks before its text.

1. **refactor: give what `## Progress` records its own section** (enabling) — skill. Move the list in
   step 1 of "STOP — Skill Complete" into a named section, such as "What Progress Records". Then
   "STOP — Skill Complete", the loop's child results and the orchestrator's Progress update all
   point to that one list.
2. **run each item in a child** (AC2, AC6, AC7, AC8, AC10, AC11, AC12, AC16) — outside-in: a
   subagent that runs `/aido:2-implement` for one item and returns its results has never been run.
   Touches the 2-implement skill.
   - slice 1: `loop` starts one child for the first item. The child runs the skill for that item,
     skipping the alignment check, the scope question, the final review and the Progress update. It
     returns its results. The orchestrator runs its three checks, writes Progress and commits it
   - slice 2: when the checks pass, the next item's child starts. When one fails, the loop stops and
     reports
3. **relay a child's question** (AC9, AC17) — outside-in: pausing a child and continuing it with
   `SendMessage` is unconfirmed in a plugin skill. Touches the 2-implement skill.
   - slice 1: a child returns its question and pauses. The orchestrator asks the user and sends the
     answer to the same child
   - slice 2: with no answer, the loop stops and names the paused item and the items left
4. **choose the items from the argument** (AC1, AC3, AC4, AC5) — inside-out: follows the argument
   branch in Step 1 of `skills/verify/SKILL.md`, and reuses Step 0.5 and Step 1's item list. Touches
   the 2-implement skill.
5. **finish the loop** (AC13, AC14) — inside-out: reuses the final design review question and the
   "Hand off" rules in "STOP — Skill Complete". Touches the 2-implement skill.
6. **eval case and docs** (AC15) — inside-out: copies the two-item fixture of
   `evals/implement-partial-session-offers-nothing`, a `checks/` script like
   `evals/implement-finishes-the-feature/checks/inner-units-have-tests.sh`, and the grader of
   `evals/implement-offers-to-organize`. Adds the case to `docs/evals.md`, one line on `loop` to
   `README.md`, and bumps the plugin to 4.5.0. Touches evals, docs, the plugin manifest.

## Design notes

- **Where it belongs:** in `plugins/aido/skills/2-implement/SKILL.md`, as a mode gated on the `loop`
  argument. The orchestrator keeps Step 0, Step 0.5, Step 1's item list, the final review question,
  "STOP — Skill Complete" and every edit of the spec file. The child runs the item-building sections:
  "Work in the Item's Mode", "Acceptance Criteria as Goal Posts", "One Test at a Time", the
  on-evidence checkpoint, "Acceptance Criteria Check", "Quality Checks", "Commits".
- **Existing behaviour and abstractions to reuse:**
  - `skills/2-implement/SKILL.md` — Step 0's resume rule ("skip Steps 0.5 and 1 and continue from the
    next unit"), Step 0.5, Step 1's item list, "Acceptance Criteria Check" for a partial session,
    "Hand off" including "nobody answered … start nothing"
  - `guidelines/specification.md` — "Acceptance in Progress", "Modes and Slices in Progress": the
    shape of the child's results and the orchestrator's lines
  - `guidelines/git-workflow.md` — "Before Every Commit" for the child, "Special Cases" for each
    Progress commit
  - `skills/verify/SKILL.md` — Step 1's argument branch, Step 3's "Brief it with:" shape
  - `evals/implement-partial-session-offers-nothing/fixture.sh`,
    `evals/implement-offers-to-organize/graders/`, `tests/evals.py` — `run_case`, `blocks()`
- **Boundaries that must hold:** the phrases `tests/skills.sh` keeps in 2-implement stay word for
  word. Every new section a reference names must exist. Without `loop`, nothing changes. A subagent
  has no `AskUserQuestion`, so the child must return its questions. Only the orchestrator writes the
  spec file. `/aido:3-organize-commits` reads Progress, so the orchestrator writes the same lines a
  single session does.
- **Other modules or consumers affected:** `docs/evals.md` (the case table, required by
  `tests/test_evals.py`, and the costs), `README.md`, `plugins/aido/.claude-plugin/plugin.json`.
- **Enabling refactorings (planned):** item 1.
- **Deferred:**
  - a shared fixture for the implement evals, like `evals/organize-history.sh`. Evidence:
    `evals/implement-offers-to-organize/fixture.sh` and
    `evals/implement-partial-session-offers-nothing/fixture.sh` differ only in the spec body.
    Competing explanation: each case readable alone, and "Existing organization" favours copying.
    Assumptions: none. Confidence: medium. What would change it: a fourth implement case on the same
    app. Recommendation: extract an `implement-todo.sh` helper. Risk: low, the copies drift
  - one shared text for briefing subagents. Evidence: the briefs in `skills/verify/SKILL.md` Step 3,
    `skills/1-plan/SKILL.md` Step 5, `skills/assess-architecture/SKILL.md` Step 2,
    `skills/map-architecture/SKILL.md` 2a and 2c. Competing explanation: each brief is read with its
    own skill, and a guideline gets no path substitution, so no change may be needed. Assumptions:
    the loop child's brief shares little of it. Confidence: low, it rests on similar-looking text.
    What would change it: a fifth brief with the same preamble. Recommendation: none yet. Risk: none
- **Open questions:**
  - whether a child's turns count against the eval runner's `--max-turns`: item 6 sets `max_turns`
    and `timeout_seconds` from a first run
  - each Progress commit squashes into `docs: feature specification` while unpushed, which rewrites
    the item commits above it: the eval check reads `git log` messages and order, not SHAs

## Progress

- [x] 1. refactor: give what `## Progress` records its own section
- [x] 2. run each item in a child
- [x] 3. relay a child's question
- [x] 4. choose the items from the argument
- [x] 5. finish the loop
- [x] 6. eval case and docs

Item 2 slices built: one child for item 1, through the orchestrator's checks and its Progress commit;
the next child on passing checks, and a stop on a failed one. The second slice's text was written with
the first.
Item 3 slices built: a child's question relayed and answered through `SendMessage`; a stop when nobody
answers.

Acceptance:

- AC1: deferred — only the free checks show that today's questions are still in the skill. The existing
  `implement-*` evals were not re-run; the full round before the release covers them
- AC2: met — `implement-loops-over-the-plan`: `starts-a-child-per-item`, `each-item-is-recorded`
- AC3: met — `tests/skills.sh`: the range rule that skips ticked items (checks the text only)
- AC4: met — `tests/skills.sh`: the rule for a range naming an item the plan doesn't have (text only)
- AC5: met — the final run's trace: one alignment check before the first child, no scope question;
  `tests/skills.sh`: "ask nothing"
- AC6: met — `starts-a-child-per-item`; each child ran `/aido:2-implement item <N>`
- AC7: met — `each-item-is-recorded`; no child edited `SPEC.md` in any of the 4 runs
- AC8: met — the final run's trace: no child checked the alignment, asked, ran a review or organized
- AC9: deferred — evals have nobody to answer. Pausing is shown by
  `implement-loop-stops-on-an-unanswered-question`; the answer reaching the same child is untested
- AC10: met — the final run's trace: after each child, the orchestrator ran `git status`, `sh -n` and
  `./test_todo.sh`
- AC11: met — the final run: the second child started after the first passed its checks
- AC12: met — `tests/skills.sh`: "stop the loop. Report what failed" (text only; no run with a failing
  check)
- AC13: met — `offers-the-next-step-at-the-end`, `starts-no-organizing`
- AC14: met — `tests/skills.sh`: the rule for a range that ends before the plan (text only)
- AC15: met — `implement-loops-over-the-plan` passed with aido (one run, so not recorded)
- AC16: met — the final run's trace: the orchestrator committed each Progress update before the next
  child; no child edited `SPEC.md`
- AC17: met — `implement-loop-stops-on-an-unanswered-question` passed with aido (one run)

Decisions:

- a second eval case, `implement-loop-stops-on-an-unanswered-question`, was added for AC17; the plan
  named only one
- a child runs `/aido:2-implement item <N>`, as the user chose, so the item-building rules keep one home
- `max_turns` and `timeout_seconds` for the new cases were set without a recorded run: 80 and 1200, 60
  and 900. One run of each took 2 to 6 minutes
- the final design review ran. Applied: the loop records the items left, with their criteria
  `unchecked`; Step 0's resume rule now covers only a single session; "Child Results" points to "What
  Progress Records" and carries a changed criterion's wording; a child's notices go into its results;
  the implement fixtures share `evals/implement-todo.sh`, which was the deferred shared fixture
- deferred refactorings: none new. The shared text for briefing subagents stays parked
