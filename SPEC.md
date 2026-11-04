# Make the TDD guidance more concise without letting the agent drift

## Context

The skills and guidelines cost tokens on every turn. `/aido:2-implement` loads about 9,600 words: 2,616
in the skill and about 7,000 in the six guidelines it loads up front.

Rewriting the text as bullets would save little, because the skills are already mostly imperative
lists. The saving is in text that says the same thing twice:

- the modes are defined in `guidelines/tdd.md` and restated in `skills/2-implement/SKILL.md`
- the goal-post rule is in both, in more detail in the skill
- "slice finished" is in both
- "Test-First vs. Strict TDD" and "The Modes", both in `tdd.md`, each choose an approach by uncertainty

Agents drift by skipping a step or losing a rule late in a session, so the gates, the evidence rules and
a short reminder where a rule applies are what hold the work on course. Those stay.

This is a first pass. Removing these duplicates is expected to save 300–400 words, about 4% of what
`/aido:2-implement` loads, and it shows whether cuts of this kind can be made safely.

## Intent

Each of these rules has one home, and `tdd.md` and `2-implement` get shorter, with no rule changing its
meaning.

## Out of scope

- rewriting skills as bullet lists for their own sake
- `1-plan` and the other skills, apart from updating a reference to a section that moved
- loading guidelines later, or splitting `1-plan` into routes
- trimming the Red Flags list, apart from the "slice finished" item if it becomes a pointer
- push-approval text: the skills already hold only one-line pointers to `git-workflow.md`, so there is
  little to cut, and each is a reminder at the moment of the push
- running the evals: this is a wording change with no intended change in meaning. A word-count target
  is also left out, because it could push cuts into rules that should stay

## Acceptance criteria

- AC1: `tdd.md` has a single section for choosing an approach by uncertainty, named "The Modes"
- AC2: no reference in `plugins/aido` or the README points at a section of `tdd.md` that no longer exists
- AC3: the modes, the goal-post rule and "slice finished" are each defined in one file; anywhere else
  they appear as a pointer or a one-line reminder
- AC4: every `AskUserQuestion` in `2-implement` is still there, with the same options, and so is every
  rule requiring evidence
- AC5 (manual): each rule removed from one file still says the same thing in the file that keeps it,
  confirmed by the user reading the diff
- AC6 (manual): a real feature, long enough to compact, keeps to the workflow when tried by hand
- AC7: the PR reports the word counts of `tdd.md` and `2-implement` before and after, and says that the
  evals were not run and so behaviour is checked only by AC6
- AC8: `claude plugin validate .` and `claude plugin validate ./plugins/aido` pass, and the plugin
  version is bumped

## Plan

These items change text rather than code, so there are no layers to name and no tests to grow. A
`grep` stands in for the failing test where a criterion can be checked that way.

1. **merge the two sections of `tdd.md`** (AC1, AC2, AC5) — inside-out: conforms to the existing "The
   Modes" heading, which `specification.md`, `git-workflow.md`, `1-plan`, `stabilize` and `2-implement`
   cite. Touches `guidelines/tdd.md`, `skills/2-implement/SKILL.md`
   - fold "Test-First vs. Strict TDD" into "The Modes", keeping the deciding question, the fast proxies
     and the two failure modes, and saying "obvious implementation" once
   - point `tdd.md`'s GREEN step and the opening of `2-implement` at "The Modes"
   - `grep` for "Test-First vs" across `plugins/aido` and the README finds nothing
2. **give each rule one home** (AC3, AC4, AC5) — inside-out: conforms to the definitions already in
   `tdd.md`. Touches `skills/2-implement/SKILL.md`, `guidelines/tdd.md`
   - modes: `tdd.md` keeps the definitions. "Work the Item's Mode" in `2-implement` points at them and
     keeps what is its own: an item with no mode, "When the plan proves wrong", and a one-line reminder
     to connect the first slice before any edge case
   - goal posts: the checklist stays in `2-implement`, where it applies, and `tdd.md` keeps one line
   - slice finished: `tdd.md` keeps the definition, and the Red Flags line stays as its reminder
   - compare the `AskUserQuestion` lines and the evidence rules in `2-implement` before and after
3. **report and release** (AC7, AC8) — inside-out: follows the version bumps of earlier PRs in
   `plugin.json`. Touches `.claude-plugin/plugin.json`
   - bump the patch version, because no rule changes meaning
   - run both validators, and note the word counts for the PR: `tdd.md` 1,039 and `2-implement` 2,616
     before the change
4. **hand the manual checks to the user** (AC5, AC6) — inside-out: follows the Acceptance Criteria Check
   in `2-implement`. Touches nothing
   - show the diff for AC5, and record AC6 as `unchecked` until the trial on a real feature has run

The enabling refactoring analysis was skipped.

## Progress

- [x] Item 1: merged "Test-First vs. Strict TDD" into "The Modes", as its "Step Size" section
- [x] Item 2: `tdd.md` keeps the mode definitions and "slice finished"; `2-implement` keeps the goal-post checklist
- [x] Item 3: bumped the version to 4.2.1 and ran both validators
- [x] Item 4: showed the changes for AC5; the trial for AC6 is the user's

Acceptance:

- AC1: met — `grep -n '^#' plugins/aido/guidelines/tdd.md` shows "The Modes" with "Step Size" inside it
- AC2: met — `grep` finds no `Test-First vs`, and each "The Modes" and "Step Size" reference resolves
- AC3: met — read against the final text of both files
- AC4: met — the 14 `AskUserQuestion` and evidence lines of `2-implement` are identical before and after
- AC5: met — confirmed by the user: the four wording changes most likely to shift meaning
- AC6: unchecked — needs a trial on a real feature long enough to compact
- AC7: unchecked — belongs to the PR. Word counts: `tdd.md` 1,039 → 989, `2-implement` 2,616 → 2,551, 115 words in all
- AC8: met — both validators pass, and the version is 4.2.1

Decisions:

- the saving is 115 words, below the 300–400 in Context, because the goal-post text in `tdd.md` and the "slice finished" line in Red Flags were already one-line reminders
- the final Systemic Design Checkpoint was skipped by the user
- GitHub issue #34 tracks reducing the cost of the evals
