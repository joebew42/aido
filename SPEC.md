# Make aido lighter to follow

GitHub Issue: https://github.com/joebew42/aido/issues/42

## Context

Using Claude Code with aido can be tiring. Claude produces information faster than a person can
comfortably take it in, and the workflow keeps the user reading, evaluating and deciding.
`language.md` already makes each sentence quick to understand. What's left is the amount: approvals
show whole documents again, findings list every field in chat, each skill ends in its own shape, and
planning leaves a full context behind for the next skill, which doesn't need it.

## Intent

Reduce what the user has to read. At an approval, show only what changed. Show each finding as one
line in chat, with the full detail on request and still recorded where it is today. End every skill
with the same short block that says what needs the user. At every hand-off between skills, offer to
continue in a fresh context, as issue #42 proposes for planning.

## Out of scope

- letting the user choose the TDD pace in `/aido:2-implement`
- quieter command output
- the `loop` argument for `/aido:2-implement` (#41), which issue #42 mentions
- changing what is recorded in files: `SPEC.md`, parked refactoring ideas and PR descriptions keep
  their current content

## Acceptance criteria

Show only what changed

- AC1: When a skill asks to approve a document the user has already seen, it shows a short plain-language list of changes since then, not the whole document.
- AC2: When `/aido:1-plan` asks to approve the plan, it shows the plan and not the already approved specification.
- AC3: When a document is shown for approval for the first time, it is shown whole.
- AC4: When the user asks to see the whole document, it is shown whole.

One line per finding

- AC5: When a skill shows a design or refactoring finding in chat, it shows one line: what to change and why it matters.
- AC6: When `/aido:assess-architecture` lists its findings, each line also gives the finding's size.
- AC7: When the user asks for a finding in full, every field from `systemic-refactoring.md` is shown.
- AC8: When a finding is recorded in `SPEC.md` or saved as a refactoring idea, it keeps every field it records today.

Same ending for every skill

- AC9: When an aido skill ends, including when it stops early, its last message ends with a block labelled `Done`, `Decided` and `Needs you`.
- AC10: When `Done` or `Decided` has nothing to say, it is left out, and `Needs you` with nothing to say reads "nothing".
- AC11: When a skill's result is a report, the report is shown unchanged, and the block after it lists only what needs the user.
- AC12: When one skill starts another and continues afterwards, the started skill adds no block.

Fresh context at every hand-off

- AC13: When `/aido:1-plan`, `/aido:stabilize`, `/aido:2-implement` or `/aido:3-organize-commits` offers the next skill, it also offers to continue in a fresh context.
- AC14: When the user picks the fresh context, the skill finishes its own work, starts nothing, and ends by telling the user to run `/clear`, then the next skill.
- AC15: The fresh-context option is recommended exactly when continuing to the next skill is recommended.
- AC16 (manual): The README describes the fresh-context option and the ending block.

## Plan

The skills are Markdown, so a criterion's goal post is a phrase check in `tests/skills.sh` (with its
test in `tests/test_skills.py`) or a grader in the new eval case (item 8). Each item adds its checks
before its text. Pinned phrases stay word for word, such as "Is the plan approved?" and "Once
implementation is complete, should I organize the commits?".

1. **refactor: move "Interaction Style" into `language.md`** (enabling) — guidelines. Move the section
   from `code-standards.md` to `language.md`, which all 13 skills load. Update the README's guideline
   table. Then remove the saved idea
   `~/.claude/repos/aido/refactoring-opportunities/2026-11-05-move-interaction-style-next-to-the-language-rule.md`.
2. **refactor: give the hand-off outcomes one home** (enabling) — skills. Add a **Hand-off outcomes**
   section next to "Choose how to continue" in `1-plan`. It holds what the hand-offs share: **Stop
   here** names the next skill, and nobody answering starts nothing. `2-implement` ("STOP — Skill
   Complete" item 3), `3-organize-commits` ("Hand Off") and `stabilize` ("Step 6: Hand Off") refer to
   it. Each keeps its own question, named criteria and recommendation rules.
3. **refactor: add "Why it matters" to the finding fields** (enabling) — guidelines, skills. Add the
   field to "What every finding states" in `systemic-refactoring.md`. `assess-architecture`'s
   **Impact** becomes that field. "Parking an opportunity" cites it for `## Why it matters`.
4. **show only what changed** (AC1, AC2, AC3, AC4) — inside-out: follows "Summarise what you changed
   and why" in `1-plan`'s "Approve the specification". Touches guidelines, skills. Add the rule under
   "Asking Questions" in `language.md`: a document seen before is shown as a short list of changes,
   the first showing is whole, and the whole document is shown on request. The approval steps refer
   to it: in `1-plan`, the draft and small-change approvals and "Approve the plan", which shows only
   `## Plan` and `## Design notes`; `stabilize`'s draft approval; `3-organize-commits` Step 2;
   `4-create-pr` Step 3.5; `map-architecture` 2b; `repository-alignment.md` "When It Is Significant".
5. **one line per finding** (AC5, AC6, AC7, AC8) — inside-out: follows the short form in `1-plan`
   Step 5.5 and the field from item 3. Touches guidelines, skills. Define the one-line form next to
   "What every finding states": the Recommendation and Why it matters, with the full fields on
   request. Use it in `1-plan` Step 5.5, `2-implement`'s on-evidence question and final review, and
   `assess-architecture` Step 3, which adds the size. Design notes, `## Progress` and saved idea files
   keep every field.
6. **end every skill with the same block** (AC9, AC10, AC11, AC12) — outside-in: unknown whether one
   rule in `language.md` is enough for all 13 skills to end with the block, given their six different
   ending shapes. Touches guidelines, skills.
   - slice 1: the rule in `language.md`, with `Done`, `Decided` and `Needs you` added to its exact
     labels. `verify` shows its report unchanged, then the block. A skill another skill started and
     returns from adds none: fold in the precedents in `verify` "STOP — Skill Complete",
     `3-organize-commits` Step 2 and `1-plan` Step 4. The four subagent briefs that copy `language.md`
     say the subagent returns a report and adds no block
   - slice 2: every other skill's ending refers to the rule, including `assess-architecture` and
     `map-architecture` after their reports, and the early stops. In a partial `2-implement` session,
     `Needs you` still offers nothing beyond running it again
7. **offer a fresh context at every hand-off** (AC13, AC14, AC15) — inside-out: extends the
   **Hand-off outcomes** section from item 2 and the existing **Stop here** lines. Touches skills.
   Each hand-off question gains a fresh-context option: **Implement in a fresh context** in `1-plan`
   and `stabilize`, **Organize in a fresh context** in `2-implement`, **Create the PR in a fresh
   context** in `3-organize-commits`. The skill finishes its work, including commits, starts nothing,
   and ends by telling the user to run `/clear`, then the next skill. This option takes the
   "(recommended)" mark whenever continuing has it, and is not recommended when continuing isn't.
8. **eval case, docs and version** (AC9, AC13, AC14, AC15, AC16) — inside-out: copies the fixture and
   graders of `evals/implement-offers-to-organize`. Touches evals, docs, the plugin manifest. A new
   case, `implement-offers-a-fresh-context`, grades the recommended fresh-context option, the `/clear`
   instruction and the ending block. Add it to `docs/evals.md`. Update the hand-off paragraph in
   `README.md` and describe the ending block. Bump the plugin to 4.5.0.

## Design notes

- **Where it belongs:** the three chat rules (show what changed, the ending block, Interaction Style)
  in `plugins/aido/guidelines/language.md`, the only guideline every skill loads; `tests/skills.sh`
  already enforces its load line. The one-line finding next to "What every finding states" in
  `plugins/aido/guidelines/systemic-refactoring.md`. The hand-off outcomes, including the fresh
  context, in a new **Hand-off outcomes** section in `plugins/aido/skills/1-plan/SKILL.md`, which
  already owns "Choose how to continue" and "each approval also settles the choice that follows it".
- **Existing behaviour and abstractions to reuse:**
  - `skills/1-plan/SKILL.md` — "Approve the specification" ("Summarise what you changed and why"),
    "Choose how to continue", "Step 8: Hand Off", Step 5.5's short form
  - `skills/stabilize/SKILL.md` — "Step 6: Hand Off", which already refers to `1-plan`
  - `skills/2-implement/SKILL.md` — "STOP — Skill Complete" item 3; `skills/3-organize-commits/SKILL.md`
    — "Hand Off": the existing **Stop here** and "start nothing" lines
  - `skills/verify/SKILL.md` — "Step 4: Present the Report" and "STOP — Skill Complete": AC11 and
    AC12 already stated for one skill
  - `skills/assess-architecture/SKILL.md` — Step 2's **Size** and **Impact**
  - `evals/implement-offers-to-organize` — fixture and graders
- **Boundaries that must hold:** phrases pinned in `tests/skills.sh` stay word for word, and every
  section a reference names must exist. Files on disk keep every field. The fresh-context option goes
  into the same question as the last approval, adding no stop. `resolve-migration-conflict` still runs
  `3-organize-commits` with no offer. A partial `2-implement` session still offers nothing. Eval runs
  have no question dialog, so the question and the block share the final message, and the block comes
  last. Skills use `${CLAUDE_PLUGIN_ROOT}/…`; guidelines refer to each other by file name.
- **Other modules or consumers affected:** the four subagent briefs that copy `language.md` (`1-plan`
  Step 5, `2-implement` "Before completion", `assess-architecture` Step 2, `verify` Step 3);
  `tests/skills.sh`, `tests/test_skills.py`; the hand-off graders in `evals/implement-offers-to-organize`,
  `organize-offers-the-pr`, `organize-offers-the-pr-without-criteria`,
  `implement-partial-session-offers-nothing` and `plan-stops-before-code`, which stay compatible while
  **Stop here** remains an option; `README.md`, `docs/evals.md`, `plugins/aido/.claude-plugin/plugin.json`.
- **Enabling refactorings (planned):** items 1, 2 and 3.
- **Deferred:**
  - one shared text for briefing subagents. Already saved as
    `2026-11-05-share-one-text-for-briefing-subagents.md`, so it is not saved again. Evidence:
    `skills/1-plan/SKILL.md` Step 5, `skills/2-implement/SKILL.md` "Before completion",
    `skills/assess-architecture/SKILL.md` Step 2, `skills/verify/SKILL.md` Step 3. Competing
    explanation: the briefs differ in what else they copy, so the repetition may be fine. Assumptions:
    none. Confidence: high on the repetition, low on the need to act. What would change it: a fifth
    brief with the same lines. Why it matters: a change to how subagents are briefed is made in four
    places, such as item 6's line. Recommendation: none yet. Risk: none now
- **Open questions:** none.

## Progress

- [x] 1. refactor: move "Interaction Style" into `language.md`; its saved idea is removed
- [x] 2. refactor: give the hand-off outcomes one home
- [x] 3. refactor: add "Why it matters" to the finding fields
- [x] 4. show only what changed
- [x] 5. one line per finding
- [x] 6. end every skill with the same block
- [x] 7. offer a fresh context at every hand-off
- [x] 8. eval case, docs and version

Item 6 slices built: the rule in `language.md`, `verify` and the subagent briefs; every other skill's
ending, checked by a new per-skill rule in `tests/skills.sh`.

- AC1: met — `tests/skills.sh` keeps "show a short plain-language list of what changed since the user last saw it"
- AC2: met — `tests/skills.sh` keeps "show only `## Plan` and `## Design notes`, not the approved specification"
- AC3: met — `tests/skills.sh` keeps "The first time a document is shown, show it whole"
- AC4: met — `tests/skills.sh` keeps "When the user asks to see the whole document, show it whole"
- AC5: met — `tests/skills.sh` keeps "In chat, a finding is shown as one line: its Recommendation and Why it matters"
- AC6: met — `tests/skills.sh` keeps "one line per candidate, with its size"
- AC7: met — `tests/skills.sh` keeps "When the user asks for a finding in full, show every field"
- AC8: met — `tests/skills.sh` keeps "A finding recorded in a file keeps every field"
- AC9: met — `tests/skills.sh` keeps the rule in `language.md` and checks every skill refers to it
- AC10: met — `tests/skills.sh` keeps "Leave out `Done` or `Decided` when it has nothing to say…"
- AC11: met — `tests/skills.sh` keeps "When the result is a report, show the report unchanged…"
- AC12: met — `tests/skills.sh` keeps "A skill that another skill started, and that returns to it, adds no block" and the four brief lines
- AC13: met — `tests/skills.sh` keeps the fresh-context option in `1-plan`, `stabilize`, `2-implement` and `3-organize-commits`
- AC14: met — `tests/skills.sh` keeps "finish this skill's own work, including its commits, start nothing, and tell the user to run `/clear`, then the next skill"
- AC15: met — `tests/skills.sh` keeps "The fresh-context option carries the recommendation whenever continuing would…"
- AC16: met — confirmed by the user: the README's paragraphs on the fresh context and the ending block

The eval cases were not run, by the user's choice: `implement-offers-a-fresh-context` and the new
`recommends-a-fresh-context` grader in `implement-offers-to-organize` measure AC9, AC14 and AC15.

Decisions:

- `1-plan`'s **Stop here** now matches the other hand-offs: it mentions a fresh session, and no answer
  starts nothing
- the "recommended fresh context" check is a grader in `implement-offers-to-organize`, not in the new
  case, which answers the question in advance
- rebased on `main` after #43 added `/aido:2-implement loop`: the version is 4.6.0, not 4.5.0; the
  loop's early stops and child runs follow the ending rule
- `repository-alignment.md` is unchanged: after **Revise**, `1-plan`'s "Approve the specification"
  already shows what changed
- the final design review ran. Three duplicated statements of the ending were cut to one

Deferred refactorings:

- move the hand-off outcomes to a guideline the skills load. Evidence: `skills/1-plan/SKILL.md` —
  "Hand-off outcomes", `skills/2-implement/SKILL.md` — "STOP — Skill Complete" item 3,
  `skills/3-organize-commits/SKILL.md` — "Hand Off". Competing explanation: `1-plan` already owns the
  hand-off rules other skills cite. Assumptions: reading another skill late in a session gets skipped.
  Confidence: medium. What would change it: a run of the fresh-context evals. Recommendation: move it
  only if the evals show the cost. Why it matters: the fresh-context outcome may go unread. Risk: four
  skills and `tests/skills.sh` references. Deferred because no eval evidence exists yet; saved as
  `2026-11-06-move-the-hand-off-outcomes-to-a-loaded-guideline.md`
