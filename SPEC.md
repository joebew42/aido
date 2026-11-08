# Suggest repository conventions only after handling a review

GitHub Issue: https://github.com/joebew42/aido/issues/61

## Context

Three skills end by suggesting conventions for the repository's `CLAUDE.md` or `AGENTS.md`:
`/aido:4-open-pr`, `/aido:5-handle-review` and `/aido:multi-phase-sync`. Only
`/aido:5-handle-review` has good evidence to work from, because review comments are the best sign
of a convention the codebase follows but hasn't written down. `/aido:4-open-pr` usually runs in a
fresh context on a cleaned-up diff, and `/aido:multi-phase-sync` runs after the reviews were handled.

Asking there does harm. The "wait for a second occurrence" check can never pass on one diff. Weak
evidence invites rules that are really facts about one feature. A convention committed after the
user approved the PR stays unpushed unless they notice. Asking when there is nothing to find teaches
the user to ignore the question where it matters.

## Intent

Suggest conventions only after handling a review. Let the user decide what to do with a convention
seen only in this PR: accept it, or look for the same point in earlier PRs' review comments. Commit
a convention before the push, so it is pushed with the review fixes. Make sure the agent reads the
guidance on review comments before it ends the skill. Record a refactoring in a short format that is
quick to read.

## Out of scope

- other sources of conventions, such as the spec's recorded differences from the plan or the commit
  history
- new skills for retrospectives or for challenging a spec
- the other checks a convention must pass, which stay as they are
- searching PRs that were not merged

## Acceptance criteria

Where conventions are suggested

- AC1: When `/aido:4-open-pr` opens a PR, it suggests no repository conventions.
- AC2: When `/aido:multi-phase-sync` syncs the main plan, it suggests no repository conventions.
- AC3: When `/aido:5-handle-review` has handled a review, it still looks for conventions in the
  review comments.
- AC4 (manual): `evolving-guidelines.md` describes suggesting conventions after handling a review,
  not after completing a PR or a phase.

A convention seen only in this PR

- AC5: When a convention passes every other check but only this PR's review shows it, the user is
  asked to accept it or to look in earlier PRs' review comments.
- AC6: When the user accepts it, the convention is added and committed with no further question.
- AC7: When the user chooses to look, they are asked how many recently merged PRs to read, and only
  those PRs' review comments are read.
- AC8: When an earlier PR makes the same point, the convention is offered in the usual question on
  which conventions to add, citing that PR.
- AC9: When no earlier PR makes the same point, the user is told so and asked whether to add it
  anyway or drop it.

Committing and pushing

- AC10: When a convention is added, it is committed before the push, so the push carries it with the
  review fixes.
- AC11: When the user declines the push, the skill's ending lists every unpushed commit, including a
  convention's.

Reading order

- AC12: In `/aido:5-handle-review`, the guidance on which review comments are worth examining comes
  before the line that ends the skill.

Evals

- AC13: An eval case gives `/aido:5-handle-review` a review with only one-off fixes, and passes when
  no convention is suggested or committed.
- AC14: An eval case gives `/aido:5-handle-review` a review with a convention-shaped point seen only
  once, and passes when the agent asks to accept it or look in earlier PRs, committing no convention.

Recording a refactoring

- AC15: When a refactoring is written down, it states only Change, Why, Where, Confidence and Risk,
  and Confidence gives its reason when it isn't high.
- AC16 (manual): `systemic-refactoring.md` still asks the agent to weigh other explanations and check
  the code before it records a finding.

## Plan

1. **refactor: state the single-occurrence rule once** (enabling) — guideline. In
   `evolving-guidelines.md`, "Skip this step if" refers to the generality test. It no longer repeats
   check 4 ("a recurring pattern") or step 2 ("already written down"). After this, the rule the
   feature changes lives in one place.
2. **stop suggesting conventions when opening a PR or syncing the main plan** (AC1, AC2) —
   inside-out: follows how the other skills end, with the "Ending a Skill" line that
   `tests/skills.sh` requires. Remove Step 5 from `4-open-pr` and Step 2 from `multi-phase-sync`,
   keeping each ending sentence. Add a free check in `tests/skills.sh`: only `5-handle-review` names
   `evolving-guidelines.md`. Touches skills, tests.
3. **suggest conventions after handling a review** (AC3, AC4) — inside-out: rewords the opening of
   `evolving-guidelines.md` and keeps its process. Touches guideline.
4. **ask about a convention seen only in this PR** (AC5, AC6, AC7, AC8, AC9) — in-unit: the wording
   of the new branch in the generality test's check 4 and in step 5. Touches guideline.
   - one question per such convention, at most 2, with the options **Accept it** and **Look in
     earlier PRs**
   - accepting adds and commits it, as step 6 does
   - looking asks how many recently merged PRs to read. They are listed by recency with
     `gh pr list --state merged --limit <n>`, never with `--search`, then read one by one
   - found → it joins the step 5 question, citing the PR. Not found → say so, and ask **Add it
     anyway** or **Drop it**
   - a PR's review comments are read in one way, named once in the guideline.
     `5-handle-review` Process item 1 uses it for the current PR too
5. **commit conventions before the push, and read the guidance before the ending** (AC10, AC11,
   AC12) — inside-out: follows "Pushing Changes" in `git-workflow.md`. Touches skills, tests.
   - in `5-handle-review`, the order becomes: implement the fixes, suggest conventions, show the
     summary, push, end
   - the guidance on which review comments are worth examining moves into the conventions step,
     above the ending line
   - a declined push lists every unpushed commit in `Needs you`
   - a free check in `tests/skills.sh` confirms the guidance comes before the ending line
6. **eval: a review with only one-off fixes suggests nothing** (AC13) — inside-out: follows
   `organize-offers-the-pr` and `base_app` in `organize-history.sh`. Touches evals, docs.
   - the fixture pushes a feature branch to the local origin and writes the review to
     `.fixture/review.md`
   - the prompt says where the review is, and takes "Approve all" as the answer to the feedback
     question
   - an `llm` grader: the final message suggests no convention
   - a shell check: no `docs:` commit, and `CLAUDE.md` and `AGENTS.md` are untouched
   - a row in the cases table of `docs/evals.md`
7. **eval: a convention seen once asks before anything is added** (AC14) — inside-out: follows
   item 6. Touches evals, docs. The review has one point worth a convention. An `llm` grader: the
   final message asks to accept it or look in earlier PRs. The same shell check: nothing committed.
8. **record a refactoring in five short fields** (AC15, AC16) — inside-out: follows the field list
   under "What every finding states" in `systemic-refactoring.md`. Touches guidelines, tests, evals.
   - the list becomes Change, Why, Where, Confidence and Risk. Other explanations, assumptions and
     what would change the conclusion stay as checks made before recording, not fields
   - the heading "What every finding states" keeps its name, so the skills that cite it don't change
   - the parked-opportunity template, "Showing a finding" and the example in `specification.md`
     follow the new fields
   - the refactoring in the `implement-loop-runs-a-refactoring` fixture, and r1–r3 here, are
     rewritten in them
   - a free check in `tests/skills.sh` pins the five fields

Every item runs `tests/hooks.sh`, `tests/skills.sh` and `tests/test_skills.py`. The last commit
bumps `version` in `plugins/aido/.claude-plugin/plugin.json` to 5.4.0. No eval covers the
earlier-PR search (AC7 to AC9), so the PR says so.

## Design notes

- **Where it belongs:** when conventions are suggested stays in the skills. Only
  `/aido:5-handle-review` keeps the step. What happens to a convention seen once belongs in
  `evolving-guidelines.md`, as an outcome of the generality test that feeds its step 5 question.
  The order "conventions, commit, push, end" belongs to `5-handle-review/SKILL.md`.
- **Existing behaviour and abstractions to reuse:**
  - `plugins/aido/guidelines/evolving-guidelines.md` — step 5 is the usual question AC8 refers to;
    step 6 already commits and never pushes
  - `plugins/aido/guidelines/git-workflow.md` — "Pushing Changes", "Using GitHub CLI"
  - `plugins/aido/skills/multi-phase-sync/SKILL.md` — Process item 3: PRs read one by one with
    `gh pr view`, and no `gh pr list --search`
  - `plugins/aido/guidelines/github-issues.md` — a guideline that gives a skill a bounded `gh`
    procedure
  - `tests/evals.py` — `run_case`, `grade_llm`, `shell_checks`; `snapshot` ignores `.fixture/`
  - `plugins/aido/evals/organize-history.sh` — `base_app`, a TODO app with a local bare origin
  - `plugins/aido/evals/implement-offers-a-fresh-context/prompt.md` — "take the answer as"
- **Boundaries that must hold:**
  - every skill keeps its "Ending a Skill" sentence, which `tests/skills.sh` pins
  - every `"Section" in file.md` reference resolves to a real heading
  - guidelines refer to each other by file name; skills use `${CLAUDE_PLUGIN_ROOT}/...`
  - each new eval case appears in `docs/evals.md` (`tests/test_evals.py`)
- **Other modules or consumers affected:**
  - `plugins/aido/hooks/deny-memory-writes.sh` and `tests/hooks.sh` cite
    "evolving-guidelines.md: do not use auto-memory". The file name and that rule stay
  - the local architecture map still says `/aido:4-open-pr` suggests conventions. Refresh it with
    `/aido:map-architecture` after the change
- **Enabling refactorings (planned):** item 1.
  - **Observation:** `evolving-guidelines.md` discards a convention seen once in two places: check 4
    of the generality test, and the last bullet of "Skip this step if". The "Skip" list also repeats
    step 2 twice. AC5 changes what happens to a convention seen once.
  - **Evidence:**
    - `plugins/aido/guidelines/evolving-guidelines.md` — step 3, "It reflects a recurring pattern"
    - `plugins/aido/guidelines/evolving-guidelines.md` — "Skip this step if", "it emerged from a
      single occurrence"
    - `plugins/aido/guidelines/evolving-guidelines.md` — "Skip this step if", "all practices are
      already documented" and "it restates an existing rule"
  - **Competing explanations:** the "Skip" list is a deliberate quick filter. Settled against: it
    comes after the process, and the guideline itself warns that two phrasings of one rule drift
    apart. No change is needed, because the feature can edit both places. Settled against: the new
    branch is awkward to state twice, and a missed copy would contradict AC5.
  - **Assumptions:** the agent reads the whole guideline, so a leftover bullet would compete with
    the new question.
  - **Confidence:** medium
  - **What would change it:** the "Skip" list being meant as a second statement. Then the feature
    edits both places instead.
  - **Recommendation:** make "Skip this step if" refer to the generality test and step 2, so the
    single-occurrence rule lives only in check 4.
  - **Why it matters:** the rule the feature changes would otherwise change in two places.
  - **Risk:** guideline only; no test pins its wording. It changes agent behaviour, so items 6 and 7
    give the matching eval run.
- **Deferred:** none.
- **Open questions:**
  - with aido, the push hook asks, and under `--permission-mode dontAsk` that should be denied. Not
    confirmed by a run. Either way the cases still check what they mean to
  - the agent may try `gh` before reading `.fixture/review.md`. The origin is a local path, so `gh`
    should fail fast. The first one-run check confirms it
  - plain Claude Code never suggests conventions, so AC13's case passes without aido and AC14's
    fails without it. That is the measurement, and `docs/evals.md` says so

## Refactorings

### r1. move "how to read a PR's review comments" to git-workflow.md

- **Change:** move the steps under "Using GitHub CLI" in `git-workflow.md`, and update the two
  places that point to them.
- **Why:** they live in the conventions guideline, which only `5-handle-review` may load, so no
  other skill can reuse them.
- **Where:**
  - `plugins/aido/guidelines/evolving-guidelines.md` — `Reading a PR's Review Comments`
  - `plugins/aido/skills/5-handle-review/SKILL.md` — Process item 1
- **Confidence:** medium — no other skill needs the steps yet.
- **Risk:** low; wording only, and the free checks catch a broken reference.

### r2. write the `gh pr list --search` warning once

- **Change:** state it once under "Using GitHub CLI" in `git-workflow.md`.
- **Why:** it appears twice, in different words, and two copies drift apart.
- **Where:**
  - `plugins/aido/skills/multi-phase-sync/SKILL.md` — Process item 3
  - `plugins/aido/guidelines/evolving-guidelines.md` — step 5
- **Confidence:** high
- **Risk:** none.

### r3. remove a leftover rule from 5-handle-review

- **Change:** under "Not worth examining", keep only "a correction that applies only to the file
  under review", and point to the guideline for the rest.
- **Why:** the skill still says a point made once should be dropped, while the guideline now asks
  the user about it. Another line repeats step 2 of the guideline.
- **Where:**
  - `plugins/aido/skills/5-handle-review/SKILL.md` — `Not worth examining`
  - `plugins/aido/guidelines/evolving-guidelines.md` — step 2 and step 3, check 4
- **Confidence:** medium — the agent may follow the guideline anyway; the eval
  `handle-review-asks-about-a-convention-seen-once` would show it.
- **Risk:** changes what the agent reads. Run that eval case once afterwards.

## Progress

- [x] 1. refactor: state the single-occurrence rule once
  - the near-duplicate warning moved from "Skip this step if" into step 2, so nothing it said was lost
- [x] 2. stop suggesting conventions when opening a PR or syncing the main plan
  - `4-open-pr` ends in a `STOP — Skill Complete` section; `multi-phase-sync` ends as Process item 8
- [x] 3. suggest conventions after handling a review
  - step 1 of the guideline's process now names the review comments and their fixes too
- [x] 4. ask about a convention seen only in this PR
  - the question about a convention seen once became its own step 5; the usual question moved to
    step 6 and adding the chosen ones to step 7
  - how many PRs to read is asked with the options 5, 10 and 20
  - "Reading a PR's Review Comments" names `gh pr view --json reviews,comments` and
    `gh api repos/{owner}/{repo}/pulls/<NUMBER>/comments`
- [x] 5. commit conventions before the push, and read the guidance before the ending
  - `5-handle-review` now ends with "Suggest Repository Conventions", then "Push and End"
  - step 7 of the guideline says not to push, because the skill pushes afterwards
  - `tests/skills.sh` also pins the phrases for AC10 and AC11
- [x] 6. eval: a review with only one-off fixes suggests nothing
  - the case shares `handle-review.sh` (fixture) and `handle-review-checks.sh` (shell check) with item 7
- [x] 7. eval: a convention seen once asks before anything is added
  - `docs/evals.md` says why the first case should pass without aido and the second fail without it
- [x] 8. record a refactoring in five short fields
  - `1-plan` still reads the old headings in opportunity files parked before the change
  - r1–r3 above are rewritten in the five fields
- [x] r1. move "how to read a PR's review comments" to git-workflow.md
  - the steps are now `### Reading a PR's Review Comments` under "Using GitHub CLI" in
    `git-workflow.md`; step 5 of `evolving-guidelines.md` and `5-handle-review` Process item 1 point
    there, so `tests/skills.sh` checks both references
- [x] r2. write the `gh pr list --search` warning once
  - the warning is stated once under "Using GitHub CLI" in `git-workflow.md`; `multi-phase-sync`
    Process item 3 and step 5 of `evolving-guidelines.md` point to it
  - `tests/skills.sh` checks that only `git-workflow.md` warns against `gh pr list --search`
- [x] r3. remove a leftover rule from 5-handle-review
  - "Not worth examining" in `5-handle-review` keeps only the correction that applies to one file; a
    new line leaves the rest to the guideline's process: what is already written down, and a point
    only this PR's review makes

Acceptance criteria:

- AC1: met — `tests/skills.sh`: "only 5-handle-review suggests conventions, not 4-open-pr"
- AC2: met — `tests/skills.sh`: "only 5-handle-review suggests conventions, not multi-phase-sync"
- AC3: met — `tests/skills.sh`: "5-handle-review suggests conventions"
- AC4: met — confirmed by the user: the guideline's new opening and step 1
- AC5: deferred — only the eval `handle-review-asks-about-a-convention-seen-once` shows it, and it
  has not run yet
- AC6: deferred — no eval covers it
- AC7: deferred — no eval covers it
- AC8: deferred — no eval covers it
- AC9: deferred — no eval covers it
- AC10: deferred — no eval covers it; `tests/skills.sh` only pins the skill's wording
- AC11: deferred — no eval covers it; `tests/skills.sh` only pins the skill's wording
- AC12: met — `tests/skills.sh`: "5-handle-review gives the review guidance before its ending"
- AC13: met — eval case `handle-review-suggests-nothing`, not yet run
- AC14: met — eval case `handle-review-asks-about-a-convention-seen-once`, not yet run
- AC15: met — `tests/skills.sh`: "every finding is recorded in the five fields" and the pinned field
  list in `systemic-refactoring.md`
- AC16: met — confirmed by the user: the "Before recording a finding" list in
  `systemic-refactoring.md`

Key decisions:

- the plugin version is bumped to 5.4.0 in its own commit
- the user chose not to run the two new eval cases in this session
- after r3, the user chose not to run `handle-review-asks-about-a-convention-seen-once`; the next full
  round covers it

The final design review ran and recorded r1, r2, r3. It also noted that the design notes' step
numbers in `evolving-guidelines.md` are now one higher (the usual question is step 6, adding is
step 7), and that step 7 now says the calling skill pushes.

Deferred refactorings: none.

Units remaining: none.
