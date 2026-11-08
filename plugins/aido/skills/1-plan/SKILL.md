---
description: Plans a feature or phase — drafts and refines its specification with the user, from a GitHub issue, their own draft or a conversation, then plans the work into SPEC.md, with a lighter route for a small, clear change. Invoked when the user wants to plan a feature, write or refine a spec, start planning, create a feature branch, or runs /aido:1-plan.
disable-model-invocation: false
---

# Plan

Turn a feature or phase into an approved specification and plan in `SPEC.md`, then hand off to
`/aido:2-implement`.

Branch-naming, spec-commit and hand-off conventions are defined in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` — load it before asking how to continue in Step 6.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## The Specification Files

Planning refines `SPEC.md.draft` with the user, then moves it to `SPEC.md`. They stand for the spec
file and its draft, which Step 1 resolves. "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` holds the rules for both: their names, which is
committed, and that they never exist together.

The stages are strictly in order. Each approval also settles the choice that follows it, as "Asking
Questions" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes:

1. **Draft** — the first version lands in `SPEC.md.draft`; the user approves it as the starting
   point and chooses the route
2. **Refine** — you analyse, refine and reword the draft, asking the user for input where needed;
   the user approves it and chooses whether to run the enabling refactoring analysis, and it moves
   to `SPEC.md`
3. **Plan** — you propose the plan into `SPEC.md`; the user approves it and chooses how to continue
4. **Hand off** — you commit `SPEC.md` and continue as the user chose, which needs no further
   question

A small, clear change can take "Small-Change Route" in Step 2 instead, where one approval covers
the Draft, Refine and Plan stages.

Questions about what the specification should say are not approvals: ask them whenever a decision
belongs to the user. Do not add confirmations beyond those this skill names.

## Step 0: Sync with Main Branch

Before starting any planning work:

1. **Fetch latest changes:**
   - run `git fetch origin`

2. **Check if on the default branch:**
   - if currently on the default branch:
     - run `git pull origin <default-branch>`
     - confirm you're up to date with remote
   - if on a different branch:
     - inform user they're not on the default branch
     - confirm current branch is intentional before proceeding

3. **Only proceed after confirming sync is complete**

## Step 1: Check the Specification State

Resolve the spec file as "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. On a clash, remember whether the
user wants the choice recorded: it is committed in Step 7.

- **`SPEC.md` exists** → the specification is already approved. Delete `SPEC.md.draft` if it is
  there, read `SPEC.md`, and continue at Step 4
- **only `SPEC.md.draft` exists** → `AskUserQuestion`: "`SPEC.md.draft` is left from an earlier session. What should I do with it?" — options **Resume refining it** (use "Determine the work
  type" in Step 2: a phase of a multi-phase project continues at Step 3, standalone work at "Approve
  the draft and choose the route") / **Start over** (delete it and continue at Step 2)
- **neither exists** → continue at Step 2

## Step 2: Write the Draft

### Determine the work type

1. **Check if a main plan branch exists:**
   - look for a main plan branch (a branch whose name contains `main-plan-`)
   - check if there's a `SPEC.md` in that branch

2. **If a main plan branch is found, use `AskUserQuestion` to confirm:**
   - Question: "Is this work part of the multi-phase project in `[branch-name]`?"
   - Options:
     - **Yes — multi-phase** — follow "Multi-Phase Project Flow" below
     - **No — standalone** — follow "Standalone Project Flow" below

3. **If no main plan branch is found:** follow "Standalone Project Flow" below

### Multi-Phase Project Flow

1. **Check if any phases have been implemented yet:**
   - use `gh pr view <MAIN_PLAN_PR_NUMBER>` to read the main plan PR description
   - look at the Roadmap section and check if ALL items are unchecked (`- [ ]`)
   - if ALL roadmap items are unchecked: propose "No phases are done yet. Should I start planning Phase 1?" and proceed to plan Phase 1 without requiring extra prompting
   - if some items are already checked: continue with the existing multi-phase flow below

2. **Analyze phase dependencies and propose parallel work:**
   - read the roadmap and identify all **pending** phases (unchecked items)
   - for each pending phase, reason about whether it depends on the output of another pending phase
   - group phases into dependency tiers:
     - **Tier 1 (independent)**: phases with no dependency on other pending phases — can start immediately in parallel
     - **Tier 2+**: phases that depend on Tier 1 completion, etc.
   - if there are 2 or more independent phases in Tier 1:
     - present the dependency analysis clearly to the user
     - use `AskUserQuestion` with question: "These phases don't depend on each other. Should I set up a worktree for each, so they can run in parallel?" and options **Yes — set up worktrees** / **No — plan one phase**
     - if YES: for each independent phase, create a git worktree:
       - run `git worktree add ../<repo-name>-<phase-slug> <default-branch>` (use a short slug from the phase name)
       - inform the user that each worktree is an isolated copy where a separate Claude session can run `/aido:1-plan` independently
       - list the worktree paths so the user can open them
       - **STOP** — do not proceed to plan a single phase; the user will run `/aido:1-plan` in each worktree session
     - if NO: continue to plan the next logical phase as a single unit (proceed to step 3)
   - if only one phase is pending or no parallelism is possible: skip this step and proceed to step 3

3. **Read the overall specification:**
   - read the overall specification from the main plan branch: the file its
     `docs: feature specification` commit added, via `git show <main-plan-branch>:<path>`
   - ask for a GitHub Issue ID for this specific phase, if there is one

4. **Write the phase draft** into `SPEC.md.draft`:
   - extract the relevant portion for THIS phase from the overall specification
   - focus only on what needs to be implemented in this phase
   - carry over only the acceptance criteria this phase delivers — the phase names them in the
     overall plan — keeping their original IDs, as "The Specification Structure" in
     `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes
   - include the GitHub Issue ID, if one was provided

### Standalone Project Flow

**Use `AskUserQuestion` to ask how they want to provide the specification:**
- Question: "Where should the feature specification come from?"
- Options:
  - **GitHub Issue** — ask for the GitHub issue link, read it with `gh issue view <NUMBER>`, and
    write `SPEC.md.draft` yourself from its content, including the issue reference
    (`GitHub Issue: [github repository link]/#NUMBER`)
  - **Write it myself** — ask the user to create `SPEC.md.draft` with the feature specification,
    and wait until they say it is ready
  - **Start from a conversation** — interview the user, as "Interview the user" below describes,
    and write `SPEC.md.draft` yourself

#### Interview the user

1. Ask openly, in free text, what they want to change and why
2. Ask follow-up questions in groups with `AskUserQuestion`, offering the plausible answers as
   options. When the code can answer a question, read the code instead of asking
3. Stop when nothing blocks writing the draft; refining it comes later. Write what you learned into
   `SPEC.md.draft`, in the user's own words where they work, then continue as for the other options

### Approve the draft

A phase of a multi-phase project has no route to choose. Show the draft, as "Showing What Changed" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md`
describes, then `AskUserQuestion`: "Is this draft the right starting point? If so, I'll refine it with you next." —
options **Approve the draft** (continue at Step 3) / **I'll edit it first** (wait for the user, then
ask again) / **Cancel** (stop, leaving the draft in place).

### Approve the draft and choose the route

For standalone work. Load the context as in Step 3 — **Load the context**. Then judge the draft: a
change is **small and clear** only when all of these hold:

- it has no open decision, and a significant misalignment with the repository (see "What Counts as
  Significant" in `${CLAUDE_PLUGIN_ROOT}/guidelines/repository-alignment.md`) is an open decision
- it touches one module or area
- it introduces no new domain concept or abstraction

Show the draft, as "Showing What Changed" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, say
whether the change looks small and clear, and why, then `AskUserQuestion`: "Is this draft the right starting point, and how much planning does it need?" — with the route you propose
marked as recommended. The user's choice stands, whatever you propose:

- **Plan it in one step** → continue at "Small-Change Route"
- **Plan it fully** → continue at Step 3
- **I'll edit it first** → wait for the user, then ask again
- **Cancel** → stop, leaving the draft in place

### Small-Change Route

The specification and the plan are written together and approved once. Steps 3 to 6 do not run,
apart from Step 5.5, so do not ask about the enabling refactoring analysis.

1. Rewrite `SPEC.md.draft` into "The Specification Structure" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`, keeping every section brief. Propose the
   acceptance criteria yourself when the draft has none
2. Check the rewritten draft against the repository, as "What the Check Looks At" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/repository-alignment.md` describes. A significant misalignment
   is an open decision: continue at "Moving to the full route", where Step 3 raises it
3. Run Step 5.5 against the draft
4. Add a `## Plan` whose items follow Step 6: in order, each naming the criteria it serves and, for a
   feature item, its mode and the reason for it, with every criterion served by at least one item, and
   any opportunity pulled in first. After it, add
   this line: `The enabling refactoring analysis was skipped.`
5. Show what changed in the draft, as "Showing What Changed" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md`
   describes, then ask two questions in one `AskUserQuestion` call:
   - "Do you approve this specification and plan? This is the only approval for this change." — options:
     - **Approve — move it to SPEC.md** — continue with the checks below
     - **Change it** — ask what to change, update the draft, and ask again
     - **Plan it fully** — see "Moving to the full route" below
   - the question on how to continue from "Choose how to continue" in Step 6, whose answer counts
     only on approval

On approval:

- [ ] no open questions remain in the draft
- [ ] the draft has Context, Intent, Out of scope and Acceptance criteria, in that order, then the
      plan
- [ ] every acceptance criterion follows "Acceptance Criteria" in
      `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
- [ ] move it: `mv SPEC.md.draft SPEC.md`
- [ ] confirm `SPEC.md.draft` no longer exists, and continue at Step 7

**Moving to the full route.** When an open decision appears, tell the user why the change is no
longer small; when the user chooses the option above, no explanation is needed. Remove `## Plan` and
the skipped-analysis line from `SPEC.md.draft`, keep the rest, and continue at Step 3. This counts
as approving the draft as the starting point.

## Step 3: Refine the Draft

Only after the draft is approved as a starting point.

### Load the context

1. Load the host repository's conventions as described in `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`
2. If the feature also touches another repository (a shared API, models, events or schema), read that
   repository's agent instruction files (`CLAUDE.md` and `AGENTS.md`) too, if it is available locally
3. Read the code the draft touches, enough to check it against reality

### Analyse, refine and reword

Work through the draft and fix what you find, in `SPEC.md.draft` itself:

- **gaps** — missing behaviour, edge cases, error cases, or acceptance criteria
- **ambiguity** — statements two readers could implement differently
- **contradictions** — within the draft, or with how the code works today. A significant one (see
  "What Counts as Significant" in `${CLAUDE_PLUGIN_ROOT}/guidelines/repository-alignment.md`) goes to
  "Check the alignment with the repository" below; a lesser one stays here
- **scope** — what is in, and what is explicitly out
- **wording** — language that follows `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md`, in the project's
  own vocabulary (see "don't invent domain vocabulary" in
  `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`); acceptance criteria that can be tested

**Ask, don't guess.** Whenever a decision belongs to the user — a behaviour the draft leaves open,
a scope choice, a conflict between the draft and the code — ask with `AskUserQuestion`, offering
the plausible answers as options. Group related questions into one call. Use free text only for
genuinely open-ended input.

### Rewrite it into the specification structure

The refined draft always follows "The Specification Structure" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`: Context, Intent, Out of scope and
Acceptance criteria, in that order. It states what and why; how belongs to `## Plan`, in Step 6.

- carry the draft's content into the matching section, in the user's own words where they work
- when part of the draft fits no section — a design idea, a task list, a question — raise it with
  `AskUserQuestion`: move it to the plan, turn it into an acceptance criterion, or drop it
- **acceptance criteria are required.** When the draft has none, or they leave part of the Intent
  unchecked, propose them yourself from the Intent and the code you read
- write them as "Acceptance Criteria" in that same section describes
- show the proposed criteria to the user and ask about any you are unsure of; the list is part of
  what the user approves below

### Check the alignment with the repository

Run the alignment check on the rewritten draft, as
`${CLAUDE_PLUGIN_ROOT}/guidelines/repository-alignment.md` describes, using the context already
loaded. When a significant misalignment comes up, ask as "When It Is Significant" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/repository-alignment.md` describes, with the draft as the
specification it talks about. Do not ask for approval below until this is settled.

### Approve the specification

Summarise what you changed and why, as "Showing What Changed" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md`
describes, then ask two questions in one `AskUserQuestion` call:

- "Is `SPEC.md.draft` ready to become `SPEC.md`?" — options **Approve — move it to SPEC.md** /
  **Keep refining** (ask what to change, and repeat this step)
- "Once it's approved, should I look for refactorings that would make this feature easier? This can take a while." — options **Run the analysis** /
  **Skip it**. Mark neither as recommended. The answer counts only on approval, and Step 4 acts on it

On approval:

- [ ] no open questions remain in the draft — resolve any with the user first
- [ ] the alignment check ran, and each significant misalignment was revised or recorded
- [ ] the draft has Context, Intent, Out of scope and Acceptance criteria, in that order
- [ ] every acceptance criterion follows "Acceptance Criteria" in
      `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` — fix any that do not, and ask again
- [ ] move it: `mv SPEC.md.draft SPEC.md`
- [ ] confirm `SPEC.md.draft` no longer exists

## Step 4: Check the Architecture Index

If you entered at Step 4 with an existing `SPEC.md`, first load the context as in Step 3 —
**Load the context** — then ask the analysis question from "Approve the specification" on its own,
without its "Once it's approved" opening.

The architecture index feeds the enabling refactoring analysis in Step 5. When the user chose to
skip the analysis, skip the rest of this step and Step 5, and continue at Step 5.5.

The index is defined in **Index Location and Shape** in
`${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md`. Identify `<repo-name>` as described there, then:

- **`.skip-map-architecture` exists** → skip this step silently
- **no index** → `AskUserQuestion`: "This repository has no map of its architecture. A map helps me find existing code and rules before planning. Should I build one?" — options:
  - **Build it now** — run `/aido:map-architecture`, then continue here
  - **Continue without** — plan without it this time
  - **Never ask for this repo** — create an empty `~/.claude/repos/<repo-name>/.skip-map-architecture`
- **index stale** (see **Staleness** in that same section) →
  `AskUserQuestion`: "The architecture map is `<n>` commits behind `<default-branch>`. Should I update it?" — options **Update it
  now** (run `/aido:map-architecture` in update mode) / **Use it as is**

## Step 5: Look for Enabling Refactorings — `fable` subagent

"Make the change easy, then make the easy change." Before proposing the plan, check whether the
codebase should change first so the feature lands cleanly. The rules are in
`${CLAUDE_PLUGIN_ROOT}/guidelines/systemic-refactoring.md` — read that file now, and `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`, which
holds the rules it points to, if it is not loaded yet.

Launch one `Agent` with `model: "fable"`. Brief it with "The Shared Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`, and:

- the path to `SPEC.md` and the repository root
- if there is an index, its directory and the **Reading the Index** steps from
  `${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md`, copied in full
- `systemic-refactoring.md` and the rules it points to in `code-standards.md`, copied
  — the subagent has not loaded the guidelines
- to search the domain's own vocabulary for where this behaviour belongs, what already implements
  related rules or abstractions, and which boundaries apply — widening only on evidence
- to return only the **Design notes** below, plus each finding classified as **enabling** (makes
  this feature easier or keeps it from duplicating existing knowledge), **defer** or **no action**,
  with every field under **What every finding states** in `systemic-refactoring.md`

If `fable` is unavailable, act as "When the Model Is Unavailable" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`.

Confirm any finding that would add a plan item, as **Evidence before action** in
`systemic-refactoring.md` describes.

## Step 5.5: Pull In Parked Refactoring Opportunities

Every plan checks whether a parked refactoring can be made as part of this work, even when the
analysis above was skipped.

Identify `<repo-name>` as defined in **Index Location and Shape** in
`${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md`, and list
`~/.claude/repos/<repo-name>/refactoring-opportunities/`. With no folder or no files, continue
without saying anything.

Otherwise, read the files and `${CLAUDE_PLUGIN_ROOT}/guidelines/systemic-refactoring.md`, if it is not loaded yet.
An opportunity **fits** when this specification changes the code it cites, or when making it first
would make this work easier. For each one that fits, open the cited files and confirm it against the
current code:

- **the code no longer shows the problem** → remove the file and tell the user
- **no opportunity fits** → say so in one line and continue
- **some still hold** → show each one as **Showing a finding** in `systemic-refactoring.md` describes, from its file's
  **Change** and **Why** (`## Refactoring` and `## Why it matters` in a file parked before these
  fields), then ask "These saved refactoring ideas fit this work. Which should I include?", as
  "Asking Questions" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes for picking from a
  list

Each one pulled in becomes an **enabling** plan item that names its file. The rest stay parked.

## Step 6: Propose the Plan

- go through the specification and propose a plan of the changes, with items written and ordered as
  "Plan Items" in "The Specification Structure" (`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`)
  describes
- choose each feature item's mode as "The Modes" in `${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md` describes;
  read that file now. Open what an inside-out item cites and confirm it exists and fits: agents tend to
  over-label work as obvious, so when you can't cite anything, name the unknown instead
- the **enabling** refactorings are those from Step 5 and the opportunities pulled in at Step 5.5;
  deferred findings are not planned, only listed in the Design notes, each with every field under
  **What every finding states** in `systemic-refactoring.md`
- before asking for approval, check that every acceptance criterion is served by at least one plan
  item; add an item for any that is not, or — if the criterion itself is wrong — raise it as below
- a `SPEC.md` without numbered acceptance criteria (see "Specifications Without Acceptance
  Criteria" in the same guideline) is planned without this tracing
- add a `## Plan` section and, when the analysis ran, a `## Design notes` section to `SPEC.md`,
  the notes answering with file and symbol references — `/aido:2-implement` checks them against what was actually built:

  ```markdown
  ## Design notes

  - **Where it belongs:** …
  - **Existing behaviour and abstractions to reuse:** `path` — `Symbol`, …
  - **Boundaries that must hold:** …
  - **Other modules or consumers affected:** …
  - **Enabling refactorings (planned):** …
  - **Deferred:** …
  - **Open questions:** …
  ```
- if the user skipped the enabling refactoring analysis in Step 4, the only enabling refactorings to
  plan are those pulled in at Step 5.5, and there is no `## Design notes` section; instead, add this
  line after `## Plan`:
  `The enabling refactoring analysis was skipped.`
- if planning shows the specification itself is wrong or incomplete, raise it with
  `AskUserQuestion` and update `SPEC.md` only with the user's agreement
- ask for approval as "Approve the plan" below describes. Do NOT move to Step 7 without approval
- once the plan is approved, park each deferred finding, as **Parking an opportunity** in
  `systemic-refactoring.md` describes

### Approve the plan

The specification is already approved, so show only `## Plan` and `## Design notes`, not the approved
specification, with each finding in the notes shown as **Showing a finding** in `systemic-refactoring.md`
describes. After a change, show what changed, as "Showing What Changed" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md`
describes. Then ask two questions in one `AskUserQuestion` call:

- "Is the plan approved?" — options **Approve the plan** / **Change it** (ask what to change, update
  `SPEC.md`, and ask again)
- the question below, whose answer counts only on approval

### Choose how to continue

"Once it is approved, how should we continue?" — options:

- **Implement in a fresh context** (recommended) — commit the specification, so implementing starts
  without the planning conversation
- **Implement here** — start `/aido:2-implement` in this directory
- **Implement in a worktree** — a separate working copy, so this directory stays clean for other work
- **Stop here** — commit the specification and go no further

Step 8 acts on the answer.

## Step 7: Prepare the Feature Branch

Only proceed here when all of these hold:

- [ ] the user explicitly approved the plan
- [ ] `SPEC.md` holds the approved specification, the `## Plan` and the `## Design notes` — or,
      when the enabling refactoring analysis was skipped, the line saying so — with no open
      questions left that block implementation
- [ ] every acceptance criterion is served by at least one plan item
- [ ] `SPEC.md.draft` does not exist

### Branch Creation Checklist

- [ ] branch out to a new branch from the default branch
- [ ] name it as "Branch Naming" in `git-workflow.md` describes

### Commit the Specification

- [ ] commit `SPEC.md` as `docs: feature specification`, as "Special Cases" in `git-workflow.md`
      describes
- [ ] if, after a clash, the user chose to record the spec file name, record and commit it as "The
      Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes

## Step 8: Hand Off

The branch is created and the specification is committed. Continue as the user chose in "Choose how
to continue", without asking again:

- **Implement in a fresh context** → as **Hand-off Outcomes** in `git-workflow.md` describes
- **Implement here** → start `/aido:2-implement`, as **Hand-off Outcomes** in `git-workflow.md`
  describes
- **Implement in a worktree**:
  1. A branch can be checked out in only one place, so return this directory to the default branch:
     `git switch <default-branch>`
  2. Create a worktree from the feature branch: `git worktree add ../<repo-name>-<branch-slug> <branch-name>`
  3. Inform the user of the worktree path
  4. Instruct them to open that directory and run `/aido:2-implement` there, then stop
- **Stop here**, or no answer → as **Hand-off Outcomes** in `git-workflow.md` describes

## STOP — Skill Complete

**Do NOT implement anything in this skill.** Do NOT write any code — implementation happens only in
`/aido:2-implement`.

Whenever this skill ends, including on **Cancel**, **Reject it** or after setting up worktrees, end as
"Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes.
