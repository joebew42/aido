# Keep code on one line in the README tables

GitHub Issue: https://github.com/joebew42/aido/issues/59

## Context

Code shown in the README tables breaks across lines: skill names such as
`/aido:3-organize-commits` and `/aido:assess-architecture`, the hook details `Co-Authored-By` and
`git config aido.allowCommitAttribution true`, and the modes `inside-out` and `outside-in`. The
issue suggests the non-breaking hyphen (U+2011). But code written with it no longer works when a
reader copies it. GitHub also strips `<nobr>` and inline styles, so HTML cannot prevent the break.

## Intent

Every piece of code in the README tables stays on one line. It keeps its plain characters, so a
command copied from a table still works.

## Out of scope

- code outside the README tables
- the non-breaking hyphen, or any other special character inside the code, because it breaks
  copied commands
- changing what the tables say

## Acceptance criteria

- AC1 (manual): On GitHub, no piece of code in a README table breaks across lines, at desktop or
  mobile width.
- AC2 (manual): The code in the README tables contains no non-breaking hyphens or non-breaking spaces, and
  every skill name there names an existing skill.

## Plan

1. **widen the code columns in the README tables** (AC1, AC2) — in-unit: how many non-breaking
   spaces each header needs only shows once GitHub renders it. Touches documentation only.
   - pad these headers with `&nbsp;` until their column fits its longest piece of code: `Skill` in
     the first-feature, single-phase, multi-phase and utilities tables, `Hook` and `Turn it off` in
     the hooks table, and `Mode` in the modes table
   - leave the code itself unchanged
   - render the README with `gh api markdown` to confirm the padding survives. Then ask the user to
     check it on GitHub at desktop and mobile width (AC1)
   - run `tests/skills.sh` to confirm every skill name is still found. Search the code spans in
     the tables for U+2011 and U+00A0 (AC2)

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. widen the code columns in the README tables
- AC1: met — confirmed by the user on GitHub, at desktop and mobile width
- AC2: changed — now (manual). The user dropped the automated check for non-breaking characters as
  not worth keeping. Met: a search of the code in the README tables finds no U+2011 or U+00A0, and
  `tests/skills.sh` finds every skill name
- Decision: the padding needed about 2.6 non-breaking spaces per code character, more than first
  estimated: 64 in the first-feature and single-phase tables, 66 in multi-phase, 84 in utilities
- Decision: the hooks table breaks the line after "containing" with `<br>`, at the user's request,
  so `Co-Authored-By` fits without widening the `Hook` column further
- the final design review was skipped
