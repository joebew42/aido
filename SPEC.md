# Rename `/aido:4-create-pr` to `/aido:4-open-pr`

GitHub Issue: https://github.com/joebew42/aido/#56

## Context

The skill that opens a pull request is called `/aido:4-create-pr`. "Open" reads better than
"create" for a pull request. The issue names it `/aido:3-create-pr`, but the skill has since become
step 4, so the number stays 4.

## Intent

The skill is invoked as `/aido:4-open-pr`. The plugin, its docs, tests and evals name it that way,
and say "open" rather than "create" where they talk about the pull request this skill opens.

## Out of scope

- no alias for the old name: `/aido:4-create-pr` stops working
- the recorded eval results under `docs/evals/` and in `docs/evals.md` stay as they were recorded
- no change to what the skill does

## Acceptance criteria

- AC1: When the plugin is loaded, `/aido:4-open-pr` exists.
- AC2: Every `/aido:<name>` outside the recorded eval results names a skill that exists.
- AC3: When `/aido:3-organize-commits` offers the next step, its options say "Open the PR", not
  "Create the PR".
- AC4 (manual): The README, its workflow diagram and the skill's own title say "open" for this step.
- AC5: The eval grader that checks no PR skill was started matches the new name.
- AC6 (manual): The plugin version gets a major bump, because the old command name no longer works.

## Plan

1. **refactor: move the hand-off outcomes to `git-workflow.md`** (enabling) — guidelines, skills,
   tests. Move the **Hand-off outcomes** section from `skills/1-plan/SKILL.md` into
   `guidelines/git-workflow.md`, which `1-plan`, `2-implement`, `3-organize-commits` and `stabilize`
   all load. Point the four skills at it, and move the phrases `tests/skills.sh` pins with it.
   Pulled in from `~/.claude/repos/aido/refactoring-opportunities/2026-11-06-move-the-hand-off-outcomes-to-a-loaded-guideline.md`,
   which is removed once done
2. **rename the skill folder to `4-open-pr`** (AC1, AC4) — inside-out: follows how every skill is
   named by its folder under `plugins/aido/skills/`. Touches skills. The title becomes "Open a Pull
   Request", and the description says "opens".
3. **point the skills, guidelines and tests at the new name** (AC2, AC3) — inside-out: follows the
   existing references in `3-organize-commits`, `stabilize`, `resolve-migration-conflict` and
   `guidelines/github-issues.md`. Touches skills, guidelines, tests. The organize question and its
   options say "open the pull request" and "Open the PR"; `tests/skills.sh` pins the new phrases
4. **point the evals at the new name** (AC2, AC5) — inside-out: follows the existing grader
   `evals/organize-offers-the-pr/graders/starts-no-pr.md`. Touches evals. `input_match` becomes
   `open-pr`; case and grader descriptions, and the case table in `docs/evals.md`, say "open".
   Recorded results stay as they are
5. **update the README and its diagram** (AC2, AC4) — inside-out: follows the existing labels in
   `README.md` and `docs/readme/spec-at-the-center.svg`. Touches docs. "4 · Create PR" becomes
   "4 · Open PR"
6. **bump the plugin to 5.0.0** (AC6) — inside-out: follows `version` in
   `plugins/aido/.claude-plugin/plugin.json`. Touches the manifest

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. refactor: move the hand-off outcomes to `git-workflow.md` — the section is now
  **Hand-off Outcomes** in `guidelines/git-workflow.md`; the parked opportunity file is removed
- [x] 2. rename the skill folder to `4-open-pr`
- [x] 3. point the skills, guidelines and tests at the new name — one commit per skill or guideline
- [x] 4. point the evals at the new name
- [x] 5. update the README and its diagram
- [x] 6. bump the plugin to 5.0.0

Acceptance:

- AC1: changed — narrowed to the new name existing; a permanent test for the old name has little
  value. Met — `tests/skills.sh`: `skills/4-open-pr/SKILL.md keeps: # Open a Pull Request`
- AC2: changed — reworded to what the new reference check covers. Met — `tests/skills.sh`: every
  `/aido:<name> names an existing skill`; a search of tracked files finds `4-create-pr` only in this
  spec
- AC3: met — `tests/skills.sh`: the two `skills/3-organize-commits/SKILL.md keeps` phrases for
  "should I open the pull request?" and **Open the PR in a fresh context**
- AC4: met — confirmed by the user: the README diagram and tables, the SVG diagram and the skill's
  title
- AC5: met — `tests/skills.sh`: `organize-offers-the-pr/graders/starts-no-pr.md matches an existing
  skill`, with `input_match: 'open-pr'`
- AC6: changed — marked manual, since a test pinning one version breaks at the next release. Met —
  confirmed by the user: `plugin.json` is 5.0.0, `main` has 4.7.0

Decisions:

- `/aido:1-plan` now loads `git-workflow.md` before asking how to continue in Step 6, since the
  hand-off outcomes live there
- the skill's description keeps "create a PR" as a trigger phrase, beside "open a pull request"
- two new checks in `tests/skills.sh`: every `/aido:<name>` in the plugin, the evals, the README and
  its images names a skill that exists, and every `Skill` grader's `input_match` matches one
- the commit renaming the skill also changes its own wording, such as "Review PR Before Opening"

The final design review was skipped.
