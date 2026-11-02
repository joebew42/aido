# Use tables in the README's Your first feature, Skills and Guidelines sections

## Context

The README's Your first feature, Skills and Guidelines sections are bullet lists of short, parallel
entries that readers scan or look up, and they are hard to read that way. Step 1 of Your first
feature runs to five lines while the steps around it take one.

## Intent

Improve the readability of these three sections by presenting them as tables, without losing any of
what they say today.

## Out of scope

- Why aido: AI-Augmented Engineering stays as bullets: each one is a principle with its reasoning,
  which a table would have to cut down
- other lists in the README, such as "Acceptance criteria are checked at every stage" and "Other
  ways to use it"
- rewording the Skills and Guidelines descriptions
- any change to the plugin, so no version bump

## Acceptance criteria

- AC1: Your first feature has a table with one row per skill, `/aido:1-plan` to
  `/aido:5-handle-review` in order, and each row's description is one short sentence or phrase
- AC2: a short paragraph below that table carries the detail removed from the rows: the three draft
  sources, approval as `SPEC.md`, planning, creating the branch, offering to move on to
  implementation, the lighter route for a small, clear change, and reverting `SPEC.md` by default or
  keeping it in the repository's docs
- AC3: Skills has one table under each of its existing headings (Single-phase feature, Multi-phase
  feature, Utilities), listing the same skills in the same order with the same descriptions
- AC4: Guidelines has one table, below its existing introductory sentence, listing the same nine
  files in the same order with the same descriptions
- AC5: `git diff` shows changes only in the Your first feature, Skills and Guidelines sections of
  `README.md`, with no heading changed
- AC6 (manual): the three sections render correctly on GitHub and read more easily than before

## Plan

1. **docs — Your first feature as a table and a paragraph** (AC1, AC2, AC5, AC6): replace the
   numbered list with a Step / Skill / What it does table, and add the paragraph below it
2. **docs — Skills as tables** (AC3, AC5, AC6): turn the list under each of the three headings into a
   Skill / What it does table
3. **docs — Guidelines as a table** (AC4, AC5, AC6): turn the list into a Guideline / What it covers
   table

The enabling refactoring analysis was skipped.

## Progress

- [x] docs — Your first feature as a table and a paragraph
- [x] docs — Skills as tables
- [x] docs — Guidelines as a table

Acceptance criteria:

- AC1: met — throwaway script comparing `README.md` with `main`, not committed
- AC2: met — same script
- AC3: met — same script
- AC4: met — same script
- AC5: met — same script
- AC6: met — confirmed by the user: `README.md` rendered through GitHub's markdown API, 5 tables and
  32 rows, no stray pipes

Decisions: this repository has no tests or linter for the README, so no test was committed for
AC1–AC5.

The user skipped the final Systemic Design Checkpoint: the diff touches only `README.md` and adds no
new concept. No refactorings were deferred.
