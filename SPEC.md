# Don't rely on `/aido:3-organize-commits` alone to keep the feature spec off the default branch

GitHub Issue: https://github.com/joebew42/aido/#81

## Context

aido is spec-first: the spec is the first commit on a branch, and is removed at the end. Only
`/aido:3-organize-commits` removes it, so a branch that skips that skill, is opened by hand, or is
squash-merged leaves `SPEC.md` on the default branch. Every later feature then takes that leftover
for the repository's own file, and nothing removes it. Moving the spec into the docs keeps its Plan
and Progress, which describe one moment and soon go stale.

## Intent

Every skill near the end of a branch settles the spec the same way, from one shared rule. The spec
file tells any reader, aido user or not, to remove it before merging. A leftover spec on the default
branch is recognised as one, rather than taken for the repository's own file. Keeping the spec means
distilling what lasts into the docs, not moving the whole file. The README says aido is spec-first.

## Out of scope

- keeping the spec out of git, such as in the PR body or a git-ignored file
- a hook that warns about the spec before a push
- removing a leftover spec automatically. The user removes it in its own PR
- keeping a spec up to date over the feature's life (spec-anchored)
- `/aido:2-implement` and `/aido:verify`: they don't settle the spec

## Acceptance criteria

Settling the spec

- AC1: When `/aido:4-open-pr` runs on a branch whose spec has no outcome commit, it offers revert or
  distil before pushing.
- AC2: When `/aido:5-handle-review` runs on such a branch, it offers revert or distil after the review
  commits, before pushing.
- AC3: When the branch's spec already has an outcome commit, `/aido:4-open-pr` and
  `/aido:5-handle-review` don't ask about it.
- AC4: `/aido:3-organize-commits`, `/aido:4-open-pr` and `/aido:5-handle-review` offer the same
  outcomes, from one shared section of `specification.md`.
- AC19: On the main plan branch of a multi-phase feature, `/aido:4-open-pr` and
  `/aido:5-handle-review` don't offer to settle the spec.

The marker line

- AC5: When a skill writes a spec at the root of the host repository, the line after its title says
  it is a working spec to remove before merging, by reverting the `docs: feature specification`
  commit.
- AC6 (manual): A reader who doesn't know aido understands from that line what to do with the file.

Leftover specs

- AC7: When the spec file on the default branch, `SPEC.md` or a path the repository names, has the
  marker line, or a `docs: feature specification` commit added it, it counts as a leftover spec.
- AC8: When a skill about to write a new spec finds a leftover spec, it tells the user and stops,
  asking them to remove it in its own PR.
- AC9: When that file has neither the marker line nor such a commit, it doesn't count as a leftover.
  A `SPEC.md` like that is still the repository's own file.

Distilling

- AC10: When the user chooses to distil, a `docs:` commit writes the problem and decisions into a new
  or existing doc, with the acceptance criteria if the user wants them.
- AC11: The distilled text holds no plan, progress, design notes, refactorings or marker line.
- AC12: The user approves the distilled text before it is committed.
- AC13: When the user distils, the revert of the spec is still the last commit.
- AC14: No skill offers to move the spec into the docs unchanged.

A spec outside the root

- AC15: When the spec file lives outside the root of the host repository, no skill offers to settle
  it.

Older branches

- AC16: When a branch has an older `docs: move feature specification to <path>` commit, skills still
  read the spec from that path.

The README

- AC17 (manual): The README says aido is spec-first: a spec lives as long as its branch, and lasting
  knowledge goes into the PR, the issue or distilled docs.
- AC18 (manual): The README's diagram says organizing the commits reverts or distils the spec.

## Plan

1. **refactor: move the spec outcome into `specification.md`** (enabling) — domain, application.
   Move Step 1 of `/aido:3-organize-commits` into a new "Closing the Specification" section of
   `specification.md`, behaviour unchanged. Only that section names the outcome commits. "Special
   Cases" in `git-workflow.md`, and Step 2 and the Final Checklist of `/aido:3-organize-commits`, say
   "the outcome commit" and point there.
2. **distil instead of move** (AC10, AC11, AC12, AC13, AC14, AC15, AC16) — inside-out: follows the
   docs-place search and question that item 1 moves into the section. Touches domain, application.
   - the options become **Revert it** (recommended) and **Distil it into `<path>`**. **Keep it where
     it is** stays for a spec already in a docs folder
   - distil: show the distilled text for approval, then commit it as
     `docs: distil feature specification into <path>`. The revert follows as the last commit
   - keep: the last commit removes the marker line, as `docs: keep feature specification at <path>`.
     An older spec with no marker line needs no commit
   - "Reading the Approved Specification" keeps reading an older move commit, and reads a distilled
     spec from before the revert
3. **tell when the spec is settled** (AC3, AC19) — inside-out: follows rule 2's
   `git log --grep` in "The Specification File". Touches domain.
   - settled: a revert, keep or older move commit comes after the branch's spec commit
   - the outcome commit is last when it is made. Later commits, such as review fixes, don't reopen it
   - a main plan branch, whose name contains `main-plan-`, is never settled
4. **`/aido:4-open-pr` settles the spec** (AC1, AC3, AC4, AC19) — inside-out: follows the shape of
   Step 0.5 and the section from items 1 to 3. Touches application.
   - a new step after the verification offer, before the push. It loads the host conventions the
     section needs
   - "Read the specification" no longer says the spec may have moved
   - `tests/skills.sh` pins that the skill points to "Closing the Specification"
5. **`/aido:5-handle-review` settles the spec** (AC2, AC3, AC4, AC19) — inside-out: follows "Push and
   End" and the section from items 1 to 3. Touches application.
   - Step 0 loads `specification.md`. The new step runs after the convention commit, before the push
   - "DO NOT change `SPEC.md`" becomes "don't change what the spec says"
   - the phrases `tests/skills.sh` pins stay. It also pins the pointer to "Closing the Specification"
6. **the marker line** (AC5, AC6) — inside-out: follows the template in "The Specification
   Structure". Touches domain, application.
   - the template's first line after the title:
     `> Working specification for this branch. Remove it before merging: revert the
     \`docs: feature specification\` commit.`
   - `/aido:stabilize` adds it to its own template. `/aido:1-plan` doesn't copy it twice when it cuts a
     phase draft from the overall spec
7. **recognise a leftover spec** (AC7, AC8, AC9) — inside-out: extends rules 3 and 4 of "The
   Specification File". Touches domain, application.
   - rule 3 checks the file on the default branch for the marker line, or a
     `docs: feature specification` commit in its history
   - before writing a new spec, `/aido:1-plan`, `/aido:stabilize` and `/aido:multi-phase-spec-pr`
     check the resolved path, rule 1's included. On a leftover, they tell the user to remove it in its
     own PR, and stop. `/aido:2-implement` and `/aido:verify` don't stop
8. **say aido is spec-first in the README** (AC17, AC18) — inside-out: follows "One specification
   connects the whole workflow". Touches infrastructure.
   - a short spec-first paragraph there
   - the diagram and its alt text say "reverts it, or distils it into your docs"
9. **eval case: `/aido:4-open-pr` settles a spec still on the branch** (AC1) — inside-out: follows the
   shape of `organize-offers-the-pr`. Touches infrastructure.
   - graders: it asks about the spec before any push, and with nobody answering it pushes nothing
   - the PR says the leftover stop and distilling aren't covered by an eval

Bump `version` in `plugins/aido/.claude-plugin/plugin.json` to `5.9.0`. The PR shows the template, and
the outcome commits, before and after.

## Design notes

- **Where it belongs:** `specification.md` owns the spec file's whole life: a new "Closing the
  Specification" section, rules 3 and 4 of "The Specification File", and the template. Skills say only
  when they settle the spec, and point there.
- **Existing behaviour and abstractions to reuse:** `plugins/aido/skills/3-organize-commits/SKILL.md`
  — Step 1 (docs-place search, "Never overwrite an existing file", the question);
  `plugins/aido/guidelines/specification.md` — rule 2's `git log --grep`, rule 3's
  `git cat-file -e`, "Reading the Approved Specification"; `plugins/aido/guidelines/language.md` —
  "Showing What Changed" for the distil approval.
- **Boundaries that must hold:** no guideline points into a skill (`tests/skills.sh`). Every
  `"Section" in \`file.md\`` reference matches a heading, so "Special Cases", "The Specification
  File" and "Reading the Approved Specification" keep their names. `/aido:5-handle-review` keeps its
  pinned phrases, and its convention step before its ending. Only skills about to write a spec stop on
  a leftover. The main plan branch keeps its spec.
- **Other modules or consumers affected:** `git-workflow.md` "Special Cases";
  `3-organize-commits`, `4-open-pr`, `5-handle-review`, `1-plan`, `stabilize` and
  `multi-phase-spec-pr`; `README.md` and `docs/readme/spec-at-the-center.svg`; `tests/skills.sh` and
  `tests/test_skills.py`. No eval grader checks the move outcome. Fixtures write specs without the
  marker line, which stays valid. The local architecture map goes stale until
  `/aido:map-architecture` runs.
- **Enabling refactorings (planned):** item 1. It moves the outcome choice out of
  `/aido:3-organize-commits`, so three skills share it rather than copy it. It also names the outcome
  commits in one place, rather than five.
- **Deferred:** none.
- **Open questions:** none. Decided while planning: a settled spec is recognised by its outcome
  commit, not by a missing marker line, because older specs have none. A squash-merged leftover is
  caught only by its marker line. `/aido:4-open-pr` settles after the verification offer.

## Refactorings

### r1. Leave a spec outside the repository root to the repository

- **Change:** When the repository has its own `SPEC.md`, offer only `FEATURE-SPEC.md` or a path the
  user types, no longer `docs/specs/<feature-slug>.md`. A spec file outside the root, from that typed
  path or a path the repository names, belongs to the repository: no skill offers to settle it, and it
  gets no marker line. **Keep it where it is** and its `docs: keep feature specification at <path>`
  commit go away.
- **Why:** "Settling It" says a kept spec with no marker line needs no commit, but "When the Spec Is
  Settled" finds a settled spec only by its outcome commit, so `/aido:4-open-pr` and
  `/aido:5-handle-review` ask again on every run. The user decided that a docs folder is the host
  repository's responsibility, so aido doesn't settle what lives there.
- **Where:**
  - `plugins/aido/guidelines/specification.md` — "The Specification File", rule 5
  - `plugins/aido/guidelines/specification.md` — "The Specification Structure", the marker line
  - `plugins/aido/guidelines/specification.md` — "When the Spec Is Settled" and "Settling It"
  - `tests/skills.sh` — the keep commit pin
- **Confidence:** high
- **Risk:** changes AC5 and AC15, agreed with the user. A spec already placed in `docs/specs/` by an
  older branch is no longer offered for settling.

### r2. Judge a leftover by the commit that added the file

- **Change:** Make the second command in "A Leftover Spec" look at the commit that added the current
  file, such as `git log -1 --diff-filter=A --format=%s origin/<default-branch> -- <path>`, and compare
  its subject with `docs: feature specification`.
- **Why:** The command prints every `docs: feature specification` commit that ever touched the path.
  A repository that merges without squashing, then adds its own `SPEC.md`, would be told to remove
  it, against AC9.
- **Where:**
  - `plugins/aido/guidelines/specification.md` — "A Leftover Spec", the second command
- **Confidence:** medium. The command's behaviour is certain, but the case is rare.
- **Risk:** a file added, removed and added again is judged by its latest add, which is the intended
  meaning.

### r3. State once when no skill asks about the spec

- **Change:** State the three cases in "When the Spec Is Settled": no spec on the branch, already
  settled, or a main plan branch means ask nothing. `/aido:4-open-pr` and `/aido:5-handle-review` keep
  only when they settle, what they do when nobody answers, and the pointer.
- **Why:** Both skills repeat the line, and `tests/skills.sh` pins it in both. The guideline's own
  wording reads as if a main plan branch would be asked about. A new case would need three edits.
- **Where:**
  - `plugins/aido/guidelines/specification.md` — "When the Spec Is Settled"
  - `plugins/aido/skills/4-open-pr/SKILL.md` — "Step 0.75: Settle the Specification"
  - `plugins/aido/skills/5-handle-review/SKILL.md` — "Settle the Specification"
  - `tests/skills.sh` — the pinned phrases for both skills
- **Confidence:** medium. The repeat may be deliberate, and no eval covers the skip cases.
- **Risk:** changes how agents read two skills. AC3 and AC19 rest on these lines.

## Progress

- [x] 1. refactor: move the spec outcome into `specification.md`
  - "Closing the Specification" holds the outcome choice. `/aido:3-organize-commits` and "Special
    Cases" say "the outcome commit" and point there
  - `tests/skills.sh` checks that only `specification.md` names the outcome commits
- [x] 2. distil instead of move
  - the options are **Revert it**, **Distil it into `<path>`** and, for a spec already in a docs
    folder, **Keep it where it is**
  - distilling into an existing doc adds to it. Whether to include the acceptance criteria is asked
    with the approval of the distilled text
  - "Reading the Approved Specification" reads a distilled spec from just before the revert
- [x] 3. tell when the spec is settled
  - "When the Spec Is Settled" in "Closing the Specification": one `git log --grep` after the spec
    commit finds a revert, keep or older move commit
- [x] 4. `/aido:4-open-pr` settles the spec
  - Step 0.75, between the verification offer and the push. With nobody answering, it pushes nothing
  - `tests/skills.sh` checks the pointer to "Closing the Specification" and the step's place
- [x] 5. `/aido:5-handle-review` settles the spec
  - "Settle the Specification" sits between the convention step and "Push and End". With nobody
    answering, it pushes nothing and lists the unpushed commits
  - `tests/skills.sh` checks the pointer, the guideline load and the step's place
- [x] 6. the marker line
  - the template, `/aido:stabilize`'s template and the multi-phase example put it after the title. A
    phase draft keeps one, whether or not the overall spec has it
  - `tests/skills.sh` checks the line follows the title of every template
- [x] 7. recognise a leftover spec
  - a new rule 4 in "The Specification File", and "A Leftover Spec" below it. The old clash rule is now
    rule 5
  - the check runs only when the branch has no spec commit of its own. Skills that don't write a spec
    say so in one line and carry on
- [x] 8. say aido is spec-first in the README
  - a spec-first paragraph under "One specification connects the whole workflow". The diagram and its
    alt text say "reverts it, or distils it into your docs"
- [x] 9. eval case: `/aido:4-open-pr` settles a spec still on the branch
  - `open-pr-settles-the-spec`: the prompt skips verification, since runs can't answer it. Graders:
    asks about the spec, pushes nothing, opens no PR
  - for the PR: the leftover stop and distilling aren't covered by an eval
- [x] r1. Leave a spec outside the repository root to the repository
  - the clash question offers **`FEATURE-SPEC.md`** or a path the user types, no longer
    `docs/specs/<feature-slug>.md`. **Keep it where it is** and the keep commit are gone
  - a spec outside the root gets no marker line, and no skill asks about it, `/aido:3-organize-commits`
    included
  - decided with the user: a docs folder is the host repository's responsibility. r1 grew from its
    recorded change, and is committed as `feat:` because it changes behaviour
  - a path outside the root that the repository names still goes through the leftover check, which
    only stops a skill and settles nothing
- [x] r2. Judge a leftover by the commit that added the file
  - checked in a scratch repository: a repository's own `SPEC.md` added after a reverted spec is no
    longer flagged, and a real leftover still is
- [x] r3. State once when no skill asks about the spec
  - "When the Spec Is Settled" lists the three cases. `/aido:4-open-pr` and `/aido:5-handle-review`
    settle the spec only if that section says to ask, and `tests/skills.sh` checks no skill repeats
    the list
- the tests pin each step of the change. `tests/skills.sh` also pins the cases where no skill asks
  about the spec, in "When the Spec Is Settled"
- the version is 5.9.0
- the eval case `open-pr-settles-the-spec` has not run yet, nor the organize cases after r1 and r3:
  the user chose not to run them now
- the final design review ran and recorded r1, r2, r3

### Acceptance

- AC1: met — `tests/skills.sh`: "4-open-pr settles the spec after the verification offer, before the push", and its pointer to "Closing the Specification"
- AC2: met — `tests/skills.sh`: "5-handle-review settles the spec after the review commits, before the push", and its pointer
- AC3: met — `tests/skills.sh`: the "No skill asks about the spec when" list, and both skills' pointers to "When the Spec Is Settled"
- AC4: met — `tests/skills.sh`: the pointers in all three skills, and "only specification.md names the commits that settle the spec"
- AC5: changed — a spec outside the repository root belongs to the repository and gets no marker line. Covered by `tests/skills.sh`: "puts the marker line after the title of every spec it writes", and "A spec written outside the root of the host repository has none"
- AC6: met — confirmed by the user: the marker line's wording
- AC7: met — `tests/skills.sh`: "A Leftover Spec" pins, and "the leftover check looks for the marker line the template writes"
- AC8: met — `tests/skills.sh`: the "A Leftover Spec" pointers in `/aido:1-plan`, `/aido:stabilize` and `/aido:multi-phase-spec-pr`, and the stop message
- AC9: met — `tests/skills.sh`: "A file with neither is the repository's own", and the pin on the command that reads the commit that added the file
- AC10: met — `tests/skills.sh`: the distil option and commit pins
- AC11: met — `tests/skills.sh`: "The distilled text holds no plan, progress, design notes, refactorings or marker line"
- AC12: met — `tests/skills.sh`: "the user approves it before it is committed"
- AC13: met — `tests/skills.sh`: "The revert still follows, as the last commit"
- AC14: met — `tests/skills.sh`: "no skill offers to move the spec into the docs unchanged"
- AC15: changed — the keep option is gone, and no skill asks about a spec outside the root. Covered by `tests/skills.sh`: "the spec file lives outside the root of the host repository", "no skill keeps the spec in the docs, or offers a docs folder for it", and the pointers to "When the Spec Is Settled" in all three skills
- AC16: met — `tests/skills.sh`: the move commit pin in "Reading the Approved Specification"
- AC17: met — confirmed by the user: the spec-first paragraph in the README
- AC18: met — confirmed by the user: the diagram label "reverts it, or distils it into your docs"
- AC19: met — `tests/skills.sh`: "the branch is a main plan branch, whose name contains `main-plan-`" in the no-ask list, and the pointers to "When the Spec Is Settled" in `/aido:4-open-pr` and `/aido:5-handle-review`
