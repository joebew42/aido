# Shorter skills and plainer writing

## Context

The skills and guidelines add up to about 31,700 words. `1-plan` and `2-implement` are over 4,000
words each. The agent reads a lot before it can act, and the same rule is often written in a
guideline, again in a skill, and again in a checklist.

What the agent writes for people is often too long and over-explained. This covers specs, PRs,
issues and chat. `language.md` asks for plain, short writing, but the skills are written in long,
nested sentences full of workflow terms, and the agent copies the style it reads. The README and
`docs/evals.md` have the same problem.

## Intent

Make every skill and guideline shorter and quicker for an agent to read, without changing what the
workflow does. Write them in the plain style they ask for. Make the agent's own writing shorter and
more direct: it says what happened and the result, and gives a reason only when the reason isn't
obvious or the user asks. Rewrite the README and `docs/evals.md` in the same style.

## Out of scope

- changing what any skill does: its steps, questions, approvals, files and commits stay the same
- a size target: shorter where it helps, judged by reading
- splitting the work into phases: it is one change
- paid eval runs: this change relies on the free checks, and the next full round confirms it
- a new eval case for how short the agent's writing is: the PR says this isn't covered
- the eval cases and the data in `docs/evals/`

## Acceptance criteria

- AC1: When a skill or guideline is compared with its version before the change, every step,
  question, option, approval, file and commit is still there.
- AC2: When a rule is stated in a guideline, the skills point to it instead of restating it.
- AC3 (manual): Every skill and guideline reads in short, plain sentences, with few workflow terms.
- AC4: `language.md` tells the agent to give a reason only when it isn't obvious or the user asks.
- AC5: `language.md` has short before/after examples of wordy and plain text for chat, a spec, a PR
  and an issue.
- AC6 (manual): The skills and guidelines together are clearly shorter than before.
- AC7: When a phrase protected by `tests/skills.sh` is reworded, the protected list has the new
  wording, with the same meaning.
- AC8 (manual): The README and `docs/evals.md` read in short, plain sentences, and keep every fact
  and command they had.
- AC9: When `tests/hooks.sh`, `tests/skills.sh`, `tests/test_skills.py` and `tests/test_evals.py`
  run, they pass.
- AC10: When `claude plugin validate .` and `claude plugin validate ./plugins/aido` run, they pass.

## Plan

This repository has no code layers. Each item names the files it touches instead: guidelines,
skills, tests or docs. Every rewrite conforms to the text it replaces, so feature items are
`inside-out`. The free checks in `tests/skills.sh` are the tests: each item ends with them passing.

1. **refactor: state the spec-file rules once** (enabling) — guidelines, skills. "The Specification
   File" in `specification.md` keeps the rules. `1-plan` "The Specification Files", Step 1 and
   Step 7, `stabilize` Step 5, `multi-phase-spec-pr` and `2-implement` Step 0 point to it. The
   `1-plan` Step 1 cases stay.
2. **refactor: move "an approval also settles the next choice" into `language.md`** (enabling) —
   guidelines, skills. Add it to "Asking Questions". `1-plan`, `2-implement` "Before completion"
   and `3-organize-commits` Step 2 point to it instead of quoting `/aido:1-plan`.
3. **refactor: state the pick-from-a-list question once** (enabling) — guidelines, skills. "Asking
   Questions" in `language.md` gets the rule: up to 4 choices get a multi-select question, more get
   **All** / **None** / **By number**. `github-issues.md`, `1-plan` Step 5.5 and
   `assess-architecture` Step 4 keep their question text and point to it.
4. **refactor: fold "start the next skill here" into "Hand-off Outcomes"** (enabling) — guidelines,
   skills. Add the start-here outcome to `git-workflow.md`. Drop it from `2-implement` and
   `3-organize-commits`, and drop the `/clear` explanation from the `1-plan` option. The pinned
   option labels stay.
5. **refactor: let checklists point to `git-workflow.md`** (enabling) — skills. The branch-naming,
   spec-commit and pushed-history lines in `1-plan`, `2-implement`, `3-organize-commits` and
   `5-handle-review` become pointers. The alignment options restated in `1-plan` and `2-implement`
   Step 0.5 point to "When It Is Significant" in `repository-alignment.md`.
6. **refactor: one name for each design check** (enabling) — skills. `2-implement` says "final design
   review" for the check before completion, and "design check" for the one during a cycle. The
   repeated acceptance-criteria checklists in `1-plan` point to "Acceptance Criteria" in
   `specification.md`.
7. **refactor: state the step-size rule once** (enabling) — guidelines, skills, docs, tests. As
   `2026-11-06-state-the-step-size-rule-once.md` describes: "Step Size" in `tdd.md` keeps it, and the
   other copies in `tdd.md`, `2-implement` and the README point to it. Re-pin one phrase per file.
8. **refactor: share one text for briefing subagents** (enabling) — guidelines, skills. As
   `2026-11-05-share-one-text-for-briefing-subagents.md` describes. A new guideline, `subagents.md`,
   holds the shared bullets: copy `language.md`, never edit files, return a report with no ending
   block, and what to do when `fable` is unavailable. The five briefs in `1-plan`, `2-implement`,
   `verify`, `assess-architecture` and `map-architecture` load it and keep only their own bullets.
   Re-pin the "no ending block" phrase.
9. **make the agent's writing shorter** (AC4, AC5, AC3) — inside-out: follows "How to Write" in
   `language.md`. Touches guidelines. Add the rule to give a reason only when it isn't obvious or the
   user asks. Add short before/after examples for chat, a spec, a PR and an issue. Rewrite the rest of
   `language.md` in the same style. First, so the later rewrites follow it.
10. **rewrite the guidelines** (AC1, AC2, AC3, AC6, AC7) — inside-out: conforms to each guideline as
    it is today. Touches guidelines, tests. Short, plain sentences, no repeated rules, every section
    heading that others refer to kept. Re-pin reworded phrases.
11. **rewrite `1-plan` and `2-implement`** (AC1, AC2, AC3, AC6, AC7) — inside-out: conforms to each
    skill as it is today. Touches skills, tests. Every step, question, option, approval, file and
    commit stays.
12. **rewrite the other skills** (AC1, AC2, AC3, AC6, AC7) — inside-out: conforms to each skill as it
    is today. Touches skills, tests. Same rules as item 11.
13. **rewrite the README and `docs/evals.md`** (AC8) — inside-out: conforms to each file as it is
    today. Touches docs. Keep every fact, command and table.
14. **bump the version and run every check** (AC9, AC10) — inside-out: follows the conventions in
    `AGENTS.md`. Touches the plugin manifest. Bump `version` to 5.5.0, a minor change, because how
    the agent writes changes. Run the four test scripts and both `claude plugin validate` commands.
    The PR says the new writing rule isn't covered by an eval.

## Design notes

- **Where it belongs:** every rule already has an owner guideline: the spec file in
  `specification.md`; commits, pushes and hand-offs in `git-workflow.md`; questions, what-changed
  lists and the ending block in `language.md`; the alignment check in `repository-alignment.md`;
  findings in `systemic-refactoring.md`; the cycle and modes in `tdd.md`. Skills own only their steps
  and questions.
- **Existing behaviour and abstractions to reuse:** the pointer style `"Section" in \`file.md\``,
  which `tests/skills.sh` checks against headings; `git-workflow.md` — "Hand-off Outcomes", "Special
  Cases", "Branch Naming", "Pushing Changes"; `language.md` — "Asking Questions", "Showing What
  Changed", "Ending a Skill"; `repository-alignment.md` — "When It Is Significant".
- **Boundaries that must hold:** every step, question, option, approval, file and commit stays. Every
  `"Section" in \`file.md\`` reference still resolves. Each pinned phrase stays or is re-pinned with
  the same meaning. The structural checks in `tests/skills.sh` stay true: the language rule and the
  ending rule in every skill, `evolving-guidelines.md` named only by `5-handle-review`,
  `--search\`` only in `git-workflow.md`, "Worth examining" before the ending in `5-handle-review`,
  and no finding written with the old field names.
- **Other modules or consumers affected:** `tests/skills.sh` (pins and references). The eval graders
  match only skill names, so headings can change. The architecture map will be out of date after
  this change.
- **Enabling refactorings (planned):** items 1 to 8.
- **Deferred:**
  - Keep the test-run rule for organizing commits in one place. Today it is written, and pinned, in
    both `3-organize-commits` and `git-workflow.md`; a change to it means editing both.
    - **Where:** `plugins/aido/guidelines/git-workflow.md` — "Before Every Commit";
      `plugins/aido/skills/3-organize-commits/SKILL.md` — "Commit Organization Rules", "Run the Tests
      Once"; `tests/skills.sh` — the four pins on it
    - **Confidence:** medium — the two copies may be deliberate, one for the skill and one for the
      rule's owner
    - **Risk:** how agents organize commits; it came from a recent behaviour change, so it wants an
      eval run
  - Move the architecture map rules into a guideline. Today `1-plan`, `2-implement`,
    `assess-architecture` and `systemic-refactoring.md` point into `map-architecture`, so a guideline
    depends on a skill.
    - **Where:** `plugins/aido/skills/map-architecture/SKILL.md` — "Index Location and Shape",
      "Staleness", "Reading the Index"; `plugins/aido/guidelines/systemic-refactoring.md` — "Parking
      an opportunity"
    - **Confidence:** medium — the skill that writes the map may own its shape on purpose
    - **Risk:** every reference into `map-architecture` changes; it adds a file
- **Open questions:** none. Items 7 and 8 were advised against by the analysis: item 7 because the
  step-size rule is worth an eval run, item 8 because guidelines get no path substitution. You chose
  to include both. Item 8 works around the substitution by naming files, as guidelines already do.

## Refactorings

### r1. Let a skill's own brief name an exception to "never edit files"

- **Observation:** `verify` briefs its subagent with "The Shared Brief" and "The Verification Brief".
  The shared brief says "never to edit files". The verification brief allows edits in a throwaway
  worktree, and "Check that each test can fail" makes them. On `main`, the verify brief had no
  never-edit bullet: item 8 moved it into the shared brief, so it now reaches `verify` too.
- **Evidence:**
  - `plugins/aido/guidelines/subagents.md` — "The Shared Brief"
  - `plugins/aido/skills/verify/SKILL.md` — Step 3
  - `plugins/aido/skills/verify/SKILL.md` — "The Verification Brief"
  - `plugins/aido/skills/verify/SKILL.md` — "Check that each test can fail"
- **Competing explanations:** no change is needed, because the specific exception wins — not
  settled: the subagent gets two rules on one point, and nothing says which wins. The exception is
  dead text — ruled out: the check edits a test in the worktree.
- **Assumptions:** none
- **Confidence:** medium — a model that follows the stricter rule is the only case where behaviour
  changes, and nothing shows how often that happens
- **What would change it:** a `verify` eval run where the subagent skips the can-fail check makes it
  high; one where it never does makes it no action
- **Recommendation:** in `subagents.md`, end the bullet with "unless the skill's own brief names an
  exception"
- **Why it matters:** a brief that contradicts itself leaves the subagent to pick
- **Risk:** what the verify subagent does in "Check that each test can fail". The bullet is not pinned

### r2. State once what a design-check brief copies

- **Observation:** the briefs in `1-plan` Step 5, `2-implement` "Before completion" and
  `assess-architecture` Step 2 each carry the same bullet: copy `systemic-refactoring.md` and the
  rules it points to in `code-standards.md`. `1-plan` and `2-implement` also share the index bullet;
  `assess-architecture` has its own.
- **Evidence:**
  - `plugins/aido/skills/1-plan/SKILL.md` — Step 5
  - `plugins/aido/skills/2-implement/SKILL.md` — "Before completion"
  - `plugins/aido/skills/assess-architecture/SKILL.md` — Step 2
  - `plugins/aido/guidelines/subagents.md` — "The Shared Brief"
- **Competing explanations:** no change is needed, because each brief should read whole — not
  settled: the bullet is one rule, and a change to it is three edits. The bullets are different
  rules — ruled out for the `systemic-refactoring.md` bullet, which is identical
- **Assumptions:** what a design-check subagent is handed will change again, as it did when
  `code-standards.md` was added
- **Confidence:** medium — whether it is worth a section rests on the assumption
- **What would change it:** a change applied to one brief and missed in another makes it high; a
  decision that briefs are always written out whole makes it no action
- **Recommendation:** add "The Design-Check Brief" to `subagents.md` with the
  `systemic-refactoring.md` bullet, and let the three briefs point to it. Keep the index bullets where
  they are
- **Why it matters:** the rule on what a design check is handed would live in one place
- **Risk:** what the three design-check subagents receive; wants a run of the matching eval cases

### r3. Keep the test-run rule for organizing commits in one place

- **Observation:** the rule that `3-organize-commits` runs the relevant tests once, on the final
  commit, is written in `git-workflow.md` and again in `3-organize-commits`. `tests/skills.sh` pins
  both copies. They agree. Parked as
  `~/.claude/repos/aido/refactoring-opportunities/2026-11-08-keep-the-test-run-rule-for-organizing-commits-in-one-place.md`
- **Evidence:**
  - `plugins/aido/guidelines/git-workflow.md` — "Before Every Commit"
  - `plugins/aido/skills/3-organize-commits/SKILL.md` — "Commit Organization Rules"
  - `plugins/aido/skills/3-organize-commits/SKILL.md` — "Run the Tests Once"
  - `tests/skills.sh` — the pins on "runs the relevant tests once, on the final commit"
- **Competing explanations:** no change is needed, because one copy owns the rule and the other
  applies it — not settled: the skill restates the rule instead of pointing to it, unlike the other
  checklist lines. The copies have drifted — ruled out: they agree
- **Assumptions:** none
- **Confidence:** medium — the two copies may be deliberate
- **What would change it:** the user saying the skill copy is deliberate makes it no action; an edit
  to one copy without the other makes it high
- **Recommendation:** keep the rule in `git-workflow.md`, let `3-organize-commits` point to it, and
  re-pin
- **Why it matters:** a change to the rule is two edits and four pins
- **Risk:** how agents organize commits; wants a run of the organize-commits eval cases

### r4. Move the rules guidelines need out of skills

- **Observation:** `systemic-refactoring.md` defines `<repo-name>` through `/aido:map-architecture`,
  and `1-plan`, `2-implement` and `assess-architecture` point into `map-architecture` for the index
  rules. `github-issues.md` also relies on `/aido:4-open-pr` for two rules that apply to any GitHub
  body: no hard-wrapped prose, and no reference to Claude Code. Parked as
  `~/.claude/repos/aido/refactoring-opportunities/2026-11-08-move-the-architecture-map-rules-into-a-guideline.md`
- **Evidence:**
  - `plugins/aido/guidelines/systemic-refactoring.md` — "Parking an opportunity"
  - `plugins/aido/skills/map-architecture/SKILL.md` — "Index Location and Shape", "Staleness",
    "Reading the Index"
  - `plugins/aido/guidelines/github-issues.md` — "Open the Issues"
  - `plugins/aido/skills/4-open-pr/SKILL.md` — "PR Description Checklist"
- **Competing explanations:** no change is needed, because guidelines name skills elsewhere too —
  not settled: those name a skill as the actor, these point to a skill as the owner of a rule. The
  GitHub-body rules belong to PRs alone — ruled out: `github-issues.md` applies them to issues
- **Assumptions:** none
- **Confidence:** medium — the skill that writes an artefact may own its rules on purpose
- **What would change it:** the user confirming that skills own their artefact's rules makes it no
  action
- **Recommendation:** move the index rules into a guideline, and the two GitHub-body rules into
  `github-issues.md`. Let the skills point to them
- **Why it matters:** a guideline that points into a skill can't be read on its own
- **Risk:** every reference into `map-architecture`, and the `4-open-pr` checklist; adds a file

## Progress

- [x] 1. refactor: state the spec-file rules once
- [x] 2. refactor: move "an approval also settles the next choice" into `language.md`
- [x] 3. refactor: state the pick-from-a-list question once
- [x] 4. refactor: fold "start the next skill here" into "Hand-off Outcomes"
- [x] 5. refactor: let checklists point to `git-workflow.md`
- [x] 6. refactor: one name for each design check
- [x] 7. refactor: state the step-size rule once
- [x] 8. refactor: share one text for briefing subagents
- [x] 9. make the agent's writing shorter
- [x] 10. rewrite the guidelines
- [x] 11. rewrite `1-plan` and `2-implement`
  - [x] `1-plan` rewritten in short, plain sentences (4,002 → 3,733 words)
  - [x] `2-implement` rewritten the same way (4,144 → 3,962 words)
  - Every step number, heading other files point to, question and option label is kept word for
    word. No pin in `tests/skills.sh` changed.
  - "significant misalignment" became "a conflict with the repository". The linked section names
    stay.
  - `2-implement` "Commits" points to `git-workflow.md`. Its step-size line at the top is gone,
    because "MANDATORY: Tests Before Code" already points to "Step Size" in `tdd.md`.
  - The Red Flags list stays, only shortened: dropping guardrails could change behaviour, and no eval
    runs with this change.
- [x] 12. rewrite the other skills
  - [x] `3-organize-commits`, `4-open-pr`, `5-handle-review`, `multi-phase-switch`,
    `multi-phase-sync`, `multi-phase-spec-pr`, `stabilize`, `verify`, `assess-architecture`,
    `map-architecture` and `resolve-migration-conflict` rewritten in short, plain sentences
  - Item 11's rules held: step numbers, referenced headings, questions, option labels and templates
    kept word for word. No pin in `tests/skills.sh` changed.
  - Skills point to the guideline for the spec-file rule, "Pushing Changes", "Branch Naming" and the
    fallback when `fable` is unavailable.
  - Text handed to subagents is only lightly reworded, because a looser brief could change what they
    do: "The Verification Brief" in `verify`, the area-file format in `map-architecture`, the briefs
    in `assess-architecture`.
  - `resolve-migration-conflict` is 5 words longer: its checklists were already terse, so the
    rewrite aimed at clarity.
- [x] 13. rewrite the README and `docs/evals.md`
  - [x] README: long sentences split; every command, table and link kept
  - [x] `docs/evals.md`: long sentences split; the runner's generated results left untouched
- [x] 14. bump the version and run every check
  - [x] `version` bumped to 5.5.0
- [x] r1. Let a skill's own brief name an exception to "never edit files"
- [x] r2. State once what a design-check brief copies
- [x] r3. Keep the test-run rule for organizing commits in one place
- [x] r4. Move the rules guidelines need out of skills
- r1–r4: each adds checks to `tests/skills.sh`, with tests of their own in `tests/test_skills.py`
- r4: the index rules now live in a new guideline, `architecture-index.md`. The GitHub-body rules
  live in "Writing a GitHub Body" in `github-issues.md`
- r1–r4: AC1–AC10 still met — the four test scripts and both `claude plugin validate` commands pass
- r1–r3: the user skipped the matching eval runs; the next full round covers them
- AC1: met — every question, option label, bold label and section heading of each skill and
  guideline compared before and after; only emphasis was reworded
- AC2: met — skills and guidelines point to the owner guideline for each shared rule (items 1–12)
- AC3: met — confirmed by the user: the rewritten skills and guidelines, with sample changes
- AC4: met — `tests/skills.sh` pins "Give a reason only when it isn't obvious or the user asks" in
  `language.md`
- AC5: met — `tests/skills.sh` pins the "In Chat", "In a Specification", "In a PR" and "In an Issue"
  examples in `language.md`
- AC6: met — confirmed by the user: 31,708 → 30,250 words (−4.6%); skills 20,385 → 19,086
  (−6.4%); `language.md` grew for the AC5 examples
- AC7: met — no pinned phrase needed rewording; `tests/skills.sh` passes
- AC8: met — confirmed by the user: the README and `docs/evals.md` diffs, with a sample change
- AC9: met — `tests/hooks.sh`, `tests/skills.sh`, `tests/test_skills.py` and `tests/test_evals.py`
  pass
- AC10: met — `claude plugin validate .` and `claude plugin validate ./plugins/aido` pass
- the final design review ran and recorded r1, r2, r3, r4
