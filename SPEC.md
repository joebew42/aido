# `/aido:stabilize` offers to plan the work in phases

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

GitHub Issue: https://github.com/joebew42/aido/#102

## Context

`/aido:stabilize` always plans the work it takes over as one change: one branch, one `SPEC.md`, one
PR. Work started outside this workflow, such as a proof of concept, a demo or an MVP, is often too
big for that. Rebuilding it in one go is a big-bang change, hard to follow and to review.
`/aido:multi-phase-plan` already splits a feature into phases, each its own PR, but
`/aido:stabilize` never offers it.

## Intent

When stabilizing existing work, aido asks whether to plan it as one change or in phases, and
recommends one by the size of the work. In phases, each phase rebuilds its part, with the original
work as a reference, so it can be built and released in small slices.

## Out of scope

- carrying the original changes over into the phases. Each phase rebuilds its part
- naming the original work in each phase's spec. Only the main spec names it
- changing how `/aido:multi-phase-plan` splits or tracks phases
- splitting the original commits or PR into several PRs automatically

## Acceptance criteria

The choice

- AC1: When `/aido:stabilize` has shown what the original work does and its gaps, it asks whether to
  plan it as one change or in phases.
- AC2: The question recommends phases when the work spans several areas or would make one large PR,
  and one change otherwise.
- AC3: When the user chooses one change, `/aido:stabilize` goes on as before: rebuild or carry over,
  one branch, one `SPEC.md`.

In phases

- AC4: When the user chooses phases, `/aido:stabilize` doesn't ask whether to rebuild or carry over.
- AC5: When the user chooses phases with local changes, they are stashed as
  `stabilize: original work`, and the working directory is left clean.
- AC6: When the user chooses phases, `SPEC.draft.md` names the original work, what it does and its
  gaps, and has no plan.
- AC7: When the user chooses phases, `/aido:stabilize` creates no branch and commits nothing.
- AC8: After writing that draft, `/aido:stabilize` asks whether to start `/aido:multi-phase-plan` now
  or stop. On stop, it tells the user to run it later.
- AC9: When `/aido:multi-phase-plan` plans from that draft, the main spec still names the original
  work.

Documentation

- AC10 (manual): The README's "Take over existing work" says the work can be planned in phases.

## Plan

1. **refactor: keep a skill's own lines and sections while refining** (enabling) — touches the
   guidelines. In `plugins/aido/guidelines/refining-a-draft.md`, "Rewrite it into the specification
   structure", next to the `## Design decision` rule: lines and sections a skill wrote after the title,
   such as the original work, stay unchanged and in place, and are never asked about. `tests/skills.sh`
   pins the sentence
2. **refactor: state the stash of local changes once in `/aido:stabilize`** (enabling) — touches the
   skills. One sentence holds `git stash push -u -m "stabilize: original work"`. Step 4's reimplement
   and carry-over branches point to it, keeping "stash first, then create the branch" and
   `git stash apply` for carry-over. The draft template stays one, so the marker check in
   `tests/skills.sh` still covers it
3. **refactor: create the main plan branch from the up-to-date default branch** (enabling) — touches
   the skills. `plugins/aido/skills/multi-phase-plan/SKILL.md`, "Create Main Plan Branch", names the
   base as `/aido:1-plan` Step 7 and `/aido:stabilize` Step 4 do. `tests/skills.sh` pins it
4. **ask whether to plan in one change or in phases** (AC1, AC2, AC3) — inside-out: follows Step 3's
   question in `plugins/aido/skills/stabilize/SKILL.md`, which recommends an option from what Step 2
   found. Touches the skills
   - a new step after "Step 2: Understand the Change" asks "one change or in phases", recommending
     phases when the work spans several areas or would make one large PR
   - one change goes on at Step 3, unchanged
5. **the phases route** (AC4, AC5, AC6, AC7, AC8, AC9) — inside-out: follows the Step 5 template and
   Step 6's hand-off through **Hand-off Outcomes** in `git-workflow.md`, which already lists
   `/aido:stabilize`. Touches the skills
   - skips Steps 3 and 4: no rebuild-or-carry-over question, no branch
   - stashes local changes as item 2 states, leaving the working directory clean
   - writes `SPEC.draft.md` from the same template, with `Strategy: rebuild in phases` and no
     `## Plan`, and doesn't refine it. Its original-work lines and sections reach the main spec
     through item 1
   - commits nothing, and asks "start `/aido:multi-phase-plan` now, or stop". On stop, it tells the
     user to run `/aido:multi-phase-plan`, not `/aido:1-plan`, later
6. **say what `/aido:stabilize` does in either route** (AC10) — inside-out: follows the README's "Plan
   a multi-phase feature" section. Touches the skills and README
   - the `description:` front matter and opening lines no longer promise a branch in every route
   - the README's "Take over existing work" says the work can be planned in phases
7. **pin the new wording and bump the version to 6.2.0** — a new feature: a minor change. Touches
   `tests/skills.sh` and `plugins/aido/.claude-plugin/plugin.json`

The PR shows the stabilize draft before and after, and says no eval case covers `/aido:stabilize`.
Items 1 and 5 change how agents behave, so implementing proposes one eval run before the PR.

## Design notes

- **Where it belongs:** `plugins/aido/skills/stabilize/SKILL.md` — a new step between "Step 2:
  Understand the Change" and "Step 3: Propose a New Branch"; the phases route reuses Step 5's
  template and Step 6's hand-off. The rule for keeping a skill's sections belongs in
  `plugins/aido/guidelines/refining-a-draft.md` — "Rewrite it into the specification structure"
- **Existing behaviour and abstractions to reuse:**
  `plugins/aido/skills/multi-phase-plan/SKILL.md` — "Review and Refine Feature Spec", the "only
  `SPEC.draft.md` exists" case, which approves and refines a waiting draft;
  `plugins/aido/guidelines/git-workflow.md` — "Hand-off Outcomes"; `plugins/aido/guidelines/language.md`
  — "Ending a Skill", the block shown before starting the next skill;
  `plugins/aido/guidelines/specification.md` — "A skill may add its own sections after the title"
- **Boundaries that must hold:** stabilize never touches the original PR or branch, builds nothing,
  and never commits `SPEC.draft.md`. Step 0's stops stay. `tests/skills.sh` lines 108, 314, 362 and
  the marker check (515–522) stay green. The Copilot CLI line stays word for word
- **Other modules or consumers affected:** `/aido:multi-phase-plan` reads the draft and now names
  its branch base. `/aido:1-plan` would offer "Resume refining it" on a waiting phases draft, which is
  why the stop message names `/aido:multi-phase-plan`. The architecture map's stabilize entry, "creates
  a fresh branch", is out of date until `/aido:map-architecture` runs again
- **Enabling refactorings (planned):** items 1, 2 and 3
- **Deferred:** none
- **Open questions:** none. Unpushed local commits stay where they are, as they do today, since the
  main plan branch starts from the default branch (item 3)

## Refactorings

### r1. allow a skill's own lines, not only sections, in the specification structure

- **Change:** In `specification.md`, say "A skill may add its own lines and sections after the title".
- **Why:** The new rule in `refining-a-draft.md` says "The Specification Structure" allows a skill's
  lines and sections, but that guideline names only sections. Stabilize's `Original work:` and
  `Strategy:` are lines, and AC9 relies on them.
- **Where:**
  - `plugins/aido/guidelines/specification.md` — "The Specification Structure"
  - `plugins/aido/guidelines/refining-a-draft.md` — "Rewrite it into the specification structure"
- **Confidence:** high
- **Risk:** none to behaviour. No check pins the `specification.md` sentence.

### r2. drop "as before" from stabilize's one change route

- **Change:** Drop "as before" from "**One change** → go on at Step 3, as before", and update its pin.
- **Why:** An agent reading the skill has no "before". The words record this branch's change.
- **Where:**
  - `plugins/aido/skills/stabilize/SKILL.md` — "Step 2.5: Choose One Change or Phases"
  - `tests/skills.sh` — the phrase pins
- **Confidence:** high
- **Risk:** the pin changes with it.

### r3. state once how a branch is created from the up-to-date default branch

- **Change:** State it under "Branch Management" in `git-workflow.md`. `/aido:multi-phase-plan`,
  `/aido:stabilize` and `/aido:1-plan` point to it.
- **Why:** Three skills state it three ways: fetch then branch from origin, the same command four
  times in stabilize Step 4, and a pull then branch in `/aido:1-plan`. A change to it is made in
  three places.
- **Where:**
  - `plugins/aido/skills/multi-phase-plan/SKILL.md` — "Create Main Plan Branch"
  - `plugins/aido/skills/stabilize/SKILL.md` — "Step 4: Create the Branch"
  - `plugins/aido/skills/1-plan/SKILL.md` — "Branch Creation Checklist", "Step 0: Sync with Main Branch"
  - `plugins/aido/guidelines/git-workflow.md` — "Branch Management"
- **Confidence:** medium — `/aido:1-plan` reaches the same result another way, maybe on purpose.
- **Risk:** touches `/aido:1-plan` and several pins in `tests/skills.sh`.

### r4. let /aido:1-plan point a phases draft to /aido:multi-phase-plan

- **Change:** `/aido:1-plan` Step 1 recognises a draft with `Strategy: rebuild in phases` and points
  to `/aido:multi-phase-plan`, instead of offering **Resume refining it** / **Start over**.
- **Why:** Only stabilize's stop message guards a waiting phases draft. In a later session,
  `/aido:1-plan` would plan it as one change, or delete it on **Start over**.
- **Where:**
  - `plugins/aido/skills/1-plan/SKILL.md` — "Step 1: Check the Specification State"
  - `plugins/aido/skills/stabilize/SKILL.md` — "The Phases Route"
- **Confidence:** medium — it assumes the user returns later and runs the wrong command.
- **Risk:** `/aido:1-plan` would read a line only `/aido:stabilize` writes. It changes agent
  behaviour, so it needs an eval run or a new case.

### r5. deliver or stop promising the original work as each phase's reference

- **Change:** Either `/aido:1-plan`'s phase flow passes the original work on to each phase, or
  stabilize and the README stop promising it for every phase. Name unpushed local commits in the
  `Original work:` line too.
- **Why:** A phase's spec gets only its part of the main spec, so only its planning session sees the
  original work, and `/aido:2-implement` never does. Unpushed commits sit on a branch the spec never
  names.
- **Where:**
  - `plugins/aido/skills/stabilize/SKILL.md` — "Step 2.5", "The Phases Route", Step 5 template
  - `plugins/aido/skills/1-plan/SKILL.md` — "Multi-Phase Project Flow"
  - `README.md` — "Take over existing work"
- **Confidence:** medium — the spec put naming the original work in a phase spec out of scope, on
  purpose.
- **Risk:** changes what phase drafts contain, a format `/aido:1-plan` writes. The unpushed commits
  gap exists in the one change reimplement route too.

## Progress

- [x] 1. refactor: keep a skill's own lines and sections while refining
- [x] 2. refactor: state the stash of local changes once in `/aido:stabilize`
- [x] 3. refactor: create the main plan branch from the up-to-date default branch
- [x] 4. ask whether to plan in one change or in phases
- [x] 5. the phases route
- [x] 6. say what `/aido:stabilize` does in either route
- [x] 7. pin the new wording and bump the version to 6.2.0
- [x] r1. allow a skill's own lines, not only sections, in the specification structure
- [x] r2. drop "as before" from stabilize's one change route
- [x] r3. state once how a branch is created from the up-to-date default branch
- [x] r4. let /aido:1-plan point a phases draft to /aido:multi-phase-plan — dropped, no change
- [x] r5. deliver or stop promising the original work as each phase's reference

Key decisions:

- the new step is numbered 2.5, so Steps 3 to 6 and their references keep their numbers
- the phases route asks its own two-option question, through **Hand-off Outcomes**, rather than
  Step 6's "Choose how to continue"
- no eval run: no case covers `/aido:stabilize`, and the plan cases' drafts have no skill sections.
  The user chose to rely on the free checks
- the final design review ran and recorded r1, r2, r3, r4, r5. It also found the design notes'
  `tests/skills.sh` line numbers out of date, and that `/aido:1-plan` Step 7 names no base command
- r3: `/aido:1-plan` Step 0 still pulls the default branch, since it updates the code planning
  reads. Only its Step 7 points to **Creating a Branch**
- r4: dropped. The user wants `/aido:1-plan` never to name or start `/aido:multi-phase-plan`.
  Only stabilize's stop message guards a waiting phases draft
- r5: the user chose to stop promising it. Stabilize and the README now say the main spec names the
  original work, as a reference while planning the phases. The Intent's "with the original work as a
  reference" is no longer delivered for each phase. The `Original work:` line also names unpushed
  local commits

### Acceptance

- AC1: met — `stabilize asks one change or phases after showing the change, before proposing a branch`, and the question pin
- AC2: met — pin `Recommend **In phases** when the work spans several areas, or would make one large PR`
- AC3: met — pin `**One change** → go on at Step 3`; Steps 3 to 6 unchanged
- AC4: met — pin `Don't ask Step 3's question, and create no branch`
- AC5: met — pin `keep local changes aside, as **Keeping local changes aside** in Step 1 says`, and `stabilize states the stash of local changes once`
- AC6: met — pin ``with `Strategy: rebuild in phases`, and no `## Plan` ``; the Step 5 template names the original work and its gaps
- AC7: met — pins `create no branch` and `Don't refine it, and commit nothing`
- AC8: met — pins for the question, ``options **Plan the phases now** / **Stop here**`` and the later `/aido:multi-phase-plan` message
- AC9: met — pin in `refining-a-draft.md` keeping a skill's lines and sections, and `/aido:multi-phase-plan` refining a waiting draft
- AC10: met — confirmed by the user: the README's "Take over existing work" steps 2 and 4
