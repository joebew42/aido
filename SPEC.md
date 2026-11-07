# Make the README shorter and plainer

## Context

PR #47 changed how `/aido:2-implement` writes tests: a unit with a known shape now has all its tests
written together. One line in the README still says the feature is built "test by test". The README
has also grown long. Its opening has four lines before the links, and several sections repeat each
other or use dense wording.

## Intent

Bring the README in line with PR #47, and make it shorter and more direct. The opening becomes the
one-liner, then one line: "Hand Claude Code the whole feature while you stay in the loop! Works with
any stack." The tagline "AI does, you decide." goes. "What planning looks like", "Why aido?", "How it
works" and "Engineering guidelines" are cut down and written in plain words, without losing anything
a user needs to install aido, run its skills, or set up its settings and hooks.

## Out of scope

- quoting PR #47's eval numbers. The results stay in `docs/evals.md`
- changing the skills, the guidelines, the plugin manifest or the images in `docs/readme/`
- the "Get started" install steps, the recommended settings, the hooks table, the "Skills" tables
  and "Other ways to use aido", beyond the step 02 fix and plainer wording where a line is dense

## Acceptance criteria

**Opening and footer**

- AC1: Under the README's title, the opening holds the bold line "A spec-driven, test-driven
  engineering workflow for Claude Code.", then one line, "Hand Claude Code the whole feature while
  you stay in the loop! Works with any stack.", then the links.
- AC2: "AI does, you decide." appears nowhere in the README, including the footer, which shows only
  "aido 🥋".

**Up to date after PR #47**

- AC3: No line of the README says the feature is always built one test at a time, such as step 02's
  "test by test".

**Shorter and plainer**

- AC4 (manual): "What planning looks like" says, in a few short lines, where a draft can come from,
  what the user approves, and the lighter route for small changes.
- AC5 (manual): "Why aido?" makes no point that another README section already makes.
- AC6 (manual): "How it works" has no "You remain in the loop" subsection, and each remaining
  subsection is shorter and plainer than today.
- AC7: "Engineering guidelines" is one line linking `plugins/aido/guidelines/`, with no table.
- AC8: The README has at least 25% fewer lines than today's 333.
- AC9: Every link in the navigation line under the opening leads to a heading in the README.
- AC10 (manual): Read top to bottom, the README describes the workflow as plugin 4.7.0 runs it, and
  still tells a user how to install aido, run each skill, and set up its settings and hooks.

## Plan

1. **opening and footer** (AC1, AC2) — inside-out: follows the README's current header and footer
   layout. Touches `README.md` only
2. **Get started and What planning looks like** (AC3, AC4) — inside-out: rewords the existing five-steps
   table and planning text. Step 02 says the feature is built test-first, not "test by test". The
   planning text keeps the screenshot and covers the draft's sources, the approvals, the small-change
   route and the hand-off to the next skill in a few lines. The ending block example and the
   fresh-context paragraph shrink to one sentence each, or go
3. **Why aido? and How it works** (AC5, AC6, AC9) — inside-out: rewords the existing sections.
   "Why aido?" keeps the name's meaning and the five bullets, cut to one line each where possible,
   and drops points the approvals callout already makes. "You remain in the loop" goes, since "Why
   aido?" says it. The alignment and verify subsections shrink to their main point; the verify vs
   `/code-review` table stays. The SVG stays. The navigation links are checked against the new
   headings
4. **Engineering guidelines** (AC7) — inside-out: replaces the table with one line linking the folder
5. **read-through and checks** (AC8, AC10) — inside-out: counts the lines, reads the README top to
   bottom against plugin 4.7.0's skills, and runs `tests/hooks.sh`, `tests/skills.sh`,
   `tests/test_skills.py`, `claude plugin validate .` and `claude plugin validate ./plugins/aido`.
   The plugin version is not bumped, because the plugin doesn't change

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. opening and footer
- [x] 2. Get started and What planning looks like
- [x] 3. Why aido? and How it works
- [x] 4. Engineering guidelines
- [x] 5. read-through and checks

- AC1: changed — at the user's request, the second line and "Works with any stack." share one line.
  Met — checked by a scratch script, not committed, as the repository has no README tests
- AC2: met — the scratch script finds no "AI does, you decide." in the README
- AC3: met — step 02 says "test-first"; the scratch script finds no "test by test"
- AC4: met — confirmed by the user: the three-paragraph planning section
- AC5: met — confirmed by the user: "Why aido?" with three bullets, the approvals and
  specification-first bullets dropped
- AC6: met — confirmed by the user: "You remain in the loop" removed, the other subsections shortened
- AC7: met — the scratch script finds one line linking `plugins/aido/guidelines/`, no table
- AC8: met — 247 lines, against 333
- AC9: met — the scratch script resolves every navigation link to a heading
- AC10: met — confirmed by the user after reading the README top to bottom

Decisions:

- "Measuring it" now says the evals can also compare with an earlier version of aido, which PR #47
  added. It quotes no numbers
- a few dense lines in the settings and hooks notes were shortened, as the plan allowed
- the plugin version is unchanged, because only the README changed

The final design review was skipped.
