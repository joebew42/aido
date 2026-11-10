---
description: Plans a feature or phase — drafts and refines its specification with the user, from a GitHub issue, their own draft or a conversation, then plans the work into SPEC.md, with a lighter route for a small, clear change. Invoked when the user wants to plan a feature, write or refine a spec, start planning, create a feature branch, or runs /aido:1-plan.
disable-model-invocation: false
---

# Plan

**In Copilot CLI only:** before anything else, read `guidelines/copilot-cli.md` in the plugin root, two folders above this skill's base directory, and follow it. Read every guideline this skill names whole, with `view`, one file per call.

Turn a feature or phase into an approved specification and plan in `SPEC.md`. Then hand off to
`/aido:2-implement`.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` before asking how to continue in Step 6. It
holds the rules for branch names, the spec commit and hand-offs.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## The Specification Files

Planning refines `SPEC.md.draft` with the user, then moves it to `SPEC.md`. Step 1 resolves both
names. "The Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` holds their
rules: the names, which one is committed, and that they never exist together.

The stages run in order. Each approval also settles the choice after it, as "Asking Questions" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes:

1. **Draft** — the first version goes into `SPEC.md.draft`. The user approves it as the starting
   point and chooses the route
2. **Refine** — you analyse, refine and reword the draft, and ask the user where needed. The user
   approves it and chooses whether to run the enabling refactoring analysis. It moves to `SPEC.md`
3. **Plan** — you add the plan to `SPEC.md`. The user approves it and chooses how to continue
4. **Hand off** — you commit `SPEC.md` and continue as the user chose, with no further question

A small, clear change can take the "Small-Change Route" in Step 2 instead. There, one approval
covers Draft, Refine and Plan.

Questions about what the specification says are not approvals. Ask them whenever a decision belongs
to the user. Add no confirmations beyond those this skill names.

## Step 0: Sync with Main Branch

Before any planning:

1. run `git fetch origin`
2. **on the default branch** → run `git pull origin <default-branch>` and confirm it is up to date
   with the remote
3. **on another branch** → tell the user, and confirm the branch is intended before going on

Go on only once the sync is done.

## Step 1: Check the Specification State

Resolve the spec file as "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. After a clash, remember whether the
user wants the choice recorded. Step 7 commits it.

On a leftover spec, stop before anything below, as "A Leftover Spec" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes.

- **`SPEC.md` exists** → the specification is approved. Delete `SPEC.md.draft` if it is there, read
  `SPEC.md`, and continue at Step 4
- **only `SPEC.md.draft` exists** → `AskUserQuestion`: "`SPEC.md.draft` is left from an earlier session. What should I do with it?" — options **Resume refining it** (use "Determine the work
  type" in Step 2: a phase of a multi-phase project continues at Step 3, standalone work at "Approve
  the draft and choose the route") / **Start over** (delete it and continue at Step 2)
- **neither exists** → continue at Step 2

## Step 2: Write the Draft

### Determine the work type

1. look for a main plan branch, one whose name contains `main-plan-`, and check whether it has a
   `SPEC.md`
2. **one is found** → `AskUserQuestion`: "Is this work part of the multi-phase project in `[branch-name]`?" — options:
   - **Yes — multi-phase** — follow "Multi-Phase Project Flow" below
   - **No — standalone** — follow "Standalone Project Flow" below
3. **none is found** → follow "Standalone Project Flow" below

### Multi-Phase Project Flow

1. **Check whether any phase is done.** Read the main plan PR with
   `gh pr view <MAIN_PLAN_PR_NUMBER>`, and look at its Roadmap section:
   - every item unchecked (`- [ ]`) → propose "No phases are done yet. Should I start planning Phase 1?" and plan Phase 1 without waiting for more prompting
   - some items checked → go on below

2. **Look for phases that can run in parallel.** Read the pending phases (unchecked items) in the
   roadmap. For each, decide whether it depends on another pending phase. Group them in tiers:
   - **Tier 1 (independent)**: phases that depend on no other pending phase. They can start now, in
     parallel
   - **Tier 2+**: phases that depend on Tier 1, and so on

   With 2 or more phases in Tier 1, show the analysis, then `AskUserQuestion`: "These phases don't depend on each other. Should I set up a worktree for each, so they can run in parallel?" — options **Yes — set up worktrees** / **No — plan one phase**:
   - **Yes** → for each independent phase, run
     `git worktree add ../<repo-name>-<phase-slug> <default-branch>`, with a short slug from the
     phase name. Tell the user each worktree is a separate copy where its own Claude session can run
     `/aido:1-plan`, and list the paths. Then **STOP**: plan no phase here
   - **No** → plan the next logical phase, at step 3

   With one pending phase, or nothing to run in parallel, skip to step 3.

3. **Read the overall specification** from the main plan branch: the file its
   `docs: feature specification` commit added, with `git show <main-plan-branch>:<path>`. Ask for
   the GitHub Issue ID of this phase, if there is one.

4. **Write the phase draft** into `SPEC.md.draft`:
   - take only the part of the overall specification that this phase builds
   - carry over only the acceptance criteria this phase delivers, as the overall plan names them.
     Keep their IDs, as "The Specification Structure" in
     `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes
   - carry over any `## Design decision`, cut to this phase, as "Design Decision" in
     `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes
   - add the GitHub Issue ID, if there is one
   - keep a single marker line under the title, as "The Specification Structure" in
     `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` shows it, whether or not the overall
     specification has one

### Standalone Project Flow

`AskUserQuestion`: "Where should the feature specification come from?" — options:

- **GitHub Issue** — ask for the issue link, read it with `gh issue view <NUMBER>`, and write
  `SPEC.md.draft` from it, with the issue reference
  (`GitHub Issue: [github repository link]/#NUMBER`)
- **Write it myself** — ask the user to create `SPEC.md.draft`, and wait until they say it is ready
- **Start from a conversation** — interview the user, as "Interview the user" below describes, and
  write `SPEC.md.draft`

#### Interview the user

1. Ask in free text what they want to change, and why
2. Ask follow-up questions in groups with `AskUserQuestion`, with the likely answers as options. When
   the code can answer a question, read the code instead
3. Stop once nothing blocks the draft. Refining comes later. Write what you learned into
   `SPEC.md.draft`, in the user's words where they work, then continue as for the other options

### Approve the draft

A phase of a multi-phase project has no route to choose. Show the draft, whole the first time, as
"Showing What Changed" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes. Then `AskUserQuestion`: "Is this draft the right starting point? If so, I'll refine it with you next." —
options **Approve the draft** (continue at Step 3) / **I'll edit it first** (wait for the user, then
ask again) / **Cancel** (stop, and leave the draft in place).

### Approve the draft and choose the route

For standalone work. Load the context as **Load the context** in
`${CLAUDE_PLUGIN_ROOT}/guidelines/refining-a-draft.md` describes. Then judge the draft. A change is **small and clear** only when all of these hold:

- it has no open decision. A conflict with the repository, as "What Counts as Significant" in
  `${CLAUDE_PLUGIN_ROOT}/guidelines/repository-alignment.md` defines it, is an open decision
- it touches one module or area
- it adds no new domain concept or abstraction

Show the draft, whole the first time, as "Showing What Changed" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, and say whether the change looks small and clear, and why. Then `AskUserQuestion`: "Is this draft the right starting point, and how much planning does it need?" — with the route you propose
marked as recommended. The user's choice stands:

- **Plan it in one step** → continue at "Small-Change Route"
- **Plan it fully** → continue at Step 3
- **I'll edit it first** → wait for the user, then ask again
- **Cancel** → stop, and leave the draft in place

### Small-Change Route

The specification and the plan are written together and approved once. Steps 3 to 6 don't run,
except Step 5.5. Don't ask about the enabling refactoring analysis.

1. Rewrite `SPEC.md.draft` into "The Specification Structure" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`, with every section brief, keeping any
   `## Design decision` as "Rewrite it into the specification structure" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/refining-a-draft.md` says. Propose the acceptance criteria
   yourself when the draft has none
2. Check the rewritten draft against the repository, as "What the Check Looks At" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/repository-alignment.md` describes. A conflict with the
   repository is an open decision: continue at "Moving to the full route", where Step 3 raises it
3. Run Step 5.5 against the draft
4. Add a `## Plan` whose items follow Step 6: in order, each naming the criteria it serves and, for a
   feature item, its mode and why. Every criterion is served by at least one item, and any
   opportunity pulled in comes first. It follows any `## Design decision`, as Step 6 says. After it,
   add this line:
   `The enabling refactoring analysis was skipped.`
5. Show what changed in the draft, as "Showing What Changed" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes. Then ask two questions in one
   `AskUserQuestion` call:
   - "Do you approve this specification and plan? This is the only approval for this change." — options:
     - **Approve — move it to SPEC.md** — continue with the checks below
     - **Change it** — ask what to change, update the draft, and ask again
     - **Plan it fully** — see "Moving to the full route" below
   - the question from "Choose how to continue" in Step 6. Its answer counts only on approval

On approval:

- [ ] no open questions remain in the draft
- [ ] the draft has Context, Intent, Out of scope and Acceptance criteria, in that order, then any
      `## Design decision`, then the plan
- [ ] every acceptance criterion follows "Acceptance Criteria" in
      `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
- [ ] move it: `mv SPEC.md.draft SPEC.md`
- [ ] confirm `SPEC.md.draft` is gone, and continue at Step 7

**Moving to the full route.** When an open decision comes up, tell the user why the change is no
longer small. When the user picked the option above, say nothing. Remove `## Plan` and the
skipped-analysis line from `SPEC.md.draft`, keep the rest, and continue at Step 3. This counts as
approving the draft as the starting point.

## Step 3: Refine the Draft

Only once the draft is approved as the starting point.

Refine it as `${CLAUDE_PLUGIN_ROOT}/guidelines/refining-a-draft.md` describes: load the context,
analyse, refine and reword the draft, rewrite it into the specification structure, and check its
alignment with the repository. Then ask for approval below.

### Approve the specification

Show what you changed and why, as "Showing What Changed" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes. Then ask two questions in one
`AskUserQuestion` call:

- "Is `SPEC.md.draft` ready to become `SPEC.md`?" — options **Approve — move it to SPEC.md** /
  **Keep refining** (ask what to change, and repeat this step)
- "Once it's approved, should I look for refactorings that would make this feature easier? This can take a while." — options **Run the analysis** /
  **Skip it**. Mark neither as recommended. The answer counts only on approval. Step 4 acts on it

On approval:

- [ ] no open questions remain in the draft. Settle any with the user first
- [ ] the alignment check ran, and each conflict with the repository was revised or recorded
- [ ] the draft has Context, Intent, Out of scope and Acceptance criteria, in that order
- [ ] every acceptance criterion follows "Acceptance Criteria" in
      `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`. Fix any that don't, and ask again
- [ ] move it: `mv SPEC.md.draft SPEC.md`
- [ ] confirm `SPEC.md.draft` is gone

## Step 4: Check the Architecture Index

If you entered at Step 4 with an existing `SPEC.md`, first load the context as **Load the context** in
`${CLAUDE_PLUGIN_ROOT}/guidelines/refining-a-draft.md` describes. Then ask the analysis question from "Approve the specification" on its own,
without its "Once it's approved" opening.

The architecture index feeds the analysis in Step 5. When the user chose to skip the analysis, skip
the rest of this step and Step 5, and continue at Step 5.5.

**Index Location and Shape** in `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md` defines the
index. Find `<repo-name>` as it describes, then:

- **`.skip-map-architecture` exists** → skip this step, and say nothing
- **no index** → `AskUserQuestion`: "This repository has no map of its architecture. A map helps me find existing code and rules before planning. Should I build one?" — options:
  - **Build it now** — run `/aido:map-architecture`, then continue here
  - **Continue without** — plan without it this time
  - **Never ask for this repo** — create an empty `~/.claude/repos/<repo-name>/.skip-map-architecture`
- **index out of date** (see **Staleness** in that same file) →
  `AskUserQuestion`: "The architecture map is `<n>` commits behind `<default-branch>`. Should I update it?" — options **Update it
  now** (run `/aido:map-architecture` in update mode) / **Use it as is**

## Step 5: Look for Enabling Refactorings — `fable` subagent

"Make the change easy, then make the easy change." Before proposing the plan, check whether the code
should change first, so the feature fits in cleanly. Read
`${CLAUDE_PLUGIN_ROOT}/guidelines/systemic-refactoring.md` now, which holds the rules. Read
`${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md` too, if it isn't loaded: the rules point into it.

Launch one `Agent` with `model: "fable"`. Launch it even when the change looks small: a fresh context
finds what this planning conversation has stopped seeing, so checking the code yourself does not
replace it. Brief it with "The Shared Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`, and:

- the path to `SPEC.md` and the repository root
- when `SPEC.md` has a `## Design decision`, that the developer approved it, so findings work within
  the chosen approach
- if there is an index, its directory and the **Reading the Index** steps from
  `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md`, copied in full
- "The Design-Check Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`
- to search the domain's own words for where this behaviour belongs, what already implements related
  rules or abstractions, and which boundaries apply. It widens the search only on evidence
- to return only the **Design notes** below, and each finding classified as **enabling** (makes this
  feature easier, or keeps it from duplicating existing knowledge), **defer** or **no action**, with
  every field under **What every finding states** in `systemic-refactoring.md`

If `fable` is unavailable, act as "When the Model Is Unavailable" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`.

Confirm each finding classed enabling or defer, as **Evidence before action** in
`systemic-refactoring.md` describes, since either can become a plan item. Then ask about each one,
one at a time, as **Asking about a
finding** in `systemic-refactoring.md` describes — options **Plan it first** / **Defer** /
**No action**. **Plan it first** matches a finding classed enabling, and **Defer** one classed
defer:

- **Plan it first** → it becomes an **enabling** plan item
- **Defer** → it is listed in the Design notes, and parked once the plan is approved
- **No action** → it is dropped

List the findings classed no action in one line, with no question.

## Step 5.5: Pull In Parked Refactoring Opportunities

Every plan checks whether a saved refactoring idea can be made as part of this work, even when the
analysis was skipped.

Find `<repo-name>` as **Index Location and Shape** in
`${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md` defines it, and list
`~/.claude/repos/<repo-name>/refactoring-opportunities/`. With no folder or no files, continue and
say nothing.

Otherwise, read the files, and `${CLAUDE_PLUGIN_ROOT}/guidelines/systemic-refactoring.md` if it isn't
loaded. An opportunity **fits** when this specification changes the code it cites, or when making it
first would make this work easier. For each one that fits, open the cited files and check it against
the current code:

- **the code no longer shows the problem** → remove the file and tell the user
- **none fits** → say so in one line and continue
- **some still hold** → ask about each one on its own, as **Asking about a finding** in
  `systemic-refactoring.md` describes, from its file's **Change** and **Why** (`## Refactoring` and
  `## Why it matters` in an older file) — options **Include it** / **Leave it saved**. Recommend
  **Include it**, unless the idea is broader or riskier than this change justifies

Each one pulled in becomes an **enabling** plan item that names its file. The rest stay saved.

## Step 6: Propose the Plan

Before anything else in this step, read `${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md`, which defines the
modes each feature item needs.

- propose a plan of the changes, with items written and ordered as "Plan Items" in "The
  Specification Structure" (`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`) describes
- choose each feature item's mode as "The Modes" in `tdd.md` describes. Open what an inside-out item
  cites, and confirm it exists and fits.
  Agents tend to call work obvious too often: when you can't cite anything, name the unknown instead
- the **enabling** refactorings are the findings the user chose to plan first at Step 5, and the
  opportunities pulled in at Step 5.5. The findings the user deferred are not planned. List them in
  the Design notes, each with every field under **What every finding states** in
  `systemic-refactoring.md`
- before asking for approval, check that at least one plan item serves each acceptance criterion. Add
  an item for any that has none, or raise it as below when the criterion itself is wrong
- a `SPEC.md` without numbered acceptance criteria (see "Specifications Without Acceptance
  Criteria" in the same guideline) is planned without this check
- add a `## Plan` section. When the analysis ran, also add a `## Design notes` section, whose answers
  name files and symbols. `/aido:2-implement` checks them against what was built:

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
- when the user skipped the analysis in Step 4, plan only the enabling refactorings pulled in at
  Step 5.5, and add no `## Design notes`. Add this line after `## Plan` instead:
  `The enabling refactoring analysis was skipped.`
- when `SPEC.md` has a `## Design decision`, the plan follows its chosen approach. When it can't,
  such as when the code rules the approach out, raise it as below
- if planning shows the specification is wrong or incomplete, ask with `AskUserQuestion`. Update
  `SPEC.md` only with the user's agreement
- ask for approval as "Approve the plan" below describes. Do NOT move to Step 7 without approval
- once the plan is approved, park each deferred finding, as **Parking an opportunity** in
  `systemic-refactoring.md` describes

### Approve the plan

The specification is already approved, so show only `## Plan` and `## Design notes`, not the approved
specification. Show each finding in the notes as **Showing a finding** in `systemic-refactoring.md`
describes. After a change, show what changed, as "Showing What Changed" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes. Then ask two questions in one
`AskUserQuestion` call:

- "Is the plan approved?" — options **Approve the plan** / **Change it** (ask what to change, update
  `SPEC.md`, and ask again)
- the question below. Its answer counts only on approval

### Choose how to continue

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` first, if it isn't loaded. Steps 7 and 8
follow its rules for branch names, the spec commit and hand-offs.

"Once it is approved, how should we continue?" — options:

- **Implement in a fresh context** (recommended) — commit the specification, so implementing starts
  without the planning conversation
- **Implement here** — start `/aido:2-implement` in this directory
- **Implement in a worktree** — a separate working copy, so this directory stays free for other work
- **Stop here** — commit the specification and go no further

Step 8 acts on the answer.

## Step 7: Prepare the Feature Branch

Go on only when all of these hold:

- [ ] the user approved the plan
- [ ] `SPEC.md` holds the approved specification, the `## Plan`, and the `## Design notes` or the
      line saying the analysis was skipped. No open question blocks implementing
- [ ] at least one plan item serves each acceptance criterion
- [ ] `SPEC.md.draft` doesn't exist

### Branch Creation Checklist

- [ ] create a new branch from the default branch
- [ ] name it as "Branch Naming" in `git-workflow.md` describes

### Commit the Specification

- [ ] commit `SPEC.md` as `docs: feature specification`, as "Special Cases" in `git-workflow.md`
      describes
- [ ] if the user chose to record the spec file name after a clash, record and commit it as "The
      Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes

## Step 8: Hand Off

The branch exists and the specification is committed. Continue as the user chose in "Choose how to
continue", without asking again:

- **Implement in a fresh context** → as **Hand-off Outcomes** in `git-workflow.md` describes
- **Implement here** → start `/aido:2-implement`, as **Hand-off Outcomes** in `git-workflow.md`
  describes
- **Implement in a worktree**:
  1. A branch can be checked out in only one place, so switch this directory back to the default
     branch: `git switch <default-branch>`
  2. Create a worktree from the feature branch: `git worktree add ../<repo-name>-<branch-slug> <branch-name>`
  3. Tell the user the worktree path
  4. Tell them to open that directory and run `/aido:2-implement` there, then stop
- **Stop here**, or no answer → as **Hand-off Outcomes** in `git-workflow.md` describes

## STOP — Skill Complete

**Do NOT implement anything in this skill.** Write no code: implementing happens only in
`/aido:2-implement`.

Whenever this skill ends, including on **Cancel**, **Reject it** or after setting up worktrees, end as
"Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes.
