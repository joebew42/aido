---
description: Plans a feature or phase — drafts and refines its specification with the user, then plans the work into SPEC.md. Invoked when the user wants to plan a feature, write or refine a spec, start planning, create a feature branch, or runs /aiae:1-plan.
disable-model-invocation: false
---

# Plan

Turn a feature or phase into an approved specification and plan in `SPEC.md`, then hand off to
`/aiae:2-implement`.

Branch-naming and spec-commit conventions are defined in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` — load it before Step 7.

## The Specification Files

Planning moves through two files at the repository root:

- **`SPEC.md.draft`** — the working draft. It is refined together with the user and is **never
  committed**
- **`SPEC.md`** — the approved specification, plus the plan and design notes. It is committed as
  the first commit of the feature branch and is what every later skill reads

Some repositories already have a `SPEC.md` of their own, so the actual file name is resolved in
Step 1 by "The Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`.
Below, `SPEC.md` and `SPEC.md.draft` stand for the resolved spec file and its draft.

**Never leave both.** Whenever `SPEC.md` exists, `SPEC.md.draft` must not: when you find both, or
right after you create `SPEC.md`, delete `SPEC.md.draft` and tell the user you did.

The stages are strictly in order, and each one ends with the user's approval:

1. **Draft** — the first version lands in `SPEC.md.draft`, and the user approves it as the starting
   point
2. **Refine** — you analyse, refine and reword the draft, asking the user for input where needed,
   until the user approves it; it then moves to `SPEC.md`
3. **Plan** — you propose the plan into `SPEC.md`, and the user approves it
4. **Hand off** — only with an approved plan and a well-written `SPEC.md`, you offer to move to
   `/aiae:2-implement`

## Step 0: Sync with Main Branch

Before starting any planning work:

1. **Fetch latest changes:**
   - run `git fetch origin`

2. **Check if on main branch:**
   - if currently on main/master branch:
     - run `git pull origin main` (or `git pull origin master`)
     - confirm you're up to date with remote
   - if on a different branch:
     - inform user they're not on main
     - confirm current branch is intentional before proceeding

3. **Only proceed after confirming sync is complete**

## Step 1: Check the Specification State

Resolve the spec file first: read the host repository's `CLAUDE.md` and `AGENTS.md` for a named
location, then apply the rule in "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`. On a clash, ask where the spec should go
as that rule describes, and remember whether the user wants the choice recorded — it is committed
in Step 7.

- **`SPEC.md` exists** → the specification is already approved. Delete `SPEC.md.draft` if it is
  there, read `SPEC.md`, and continue at Step 4
- **only `SPEC.md.draft` exists** → `AskUserQuestion`: "There is a `SPEC.md.draft` from an earlier
  session. What would you like to do?" — options **Resume refining it** (continue at Step 3) /
  **Start over** (delete it and continue at Step 2)
- **neither exists** → continue at Step 2

## Step 2: Write the Draft

### Determine the work type

1. **Check if a main plan branch exists:**
   - look for a main plan branch (a branch whose name contains `main-plan-`)
   - check if there's a `SPEC.md` in that branch

2. **If a main plan branch is found, use `AskUserQuestion` to confirm:**
   - Question: "Is this work part of the existing multi-phase project in the `[branch-name]` branch?"
   - Options:
     - **Yes — multi-phase** — follow "Multi-Phase Project Flow" below
     - **No — standalone** — follow "Standalone Project Flow" below

3. **If no main plan branch is found:** follow "Standalone Project Flow" below

### Multi-Phase Project Flow

1. **Check if any phases have been implemented yet:**
   - use `gh pr view <MAIN_PLAN_PR_NUMBER>` to read the main plan PR description
   - look at the Roadmap section and check if ALL items are unchecked (`- [ ]`)
   - if ALL roadmap items are unchecked: propose "No phases have been implemented yet. Would you like to start planning Phase 1?" and proceed to plan Phase 1 without requiring extra prompting
   - if some items are already checked: continue with the existing multi-phase flow below

2. **Analyze phase dependencies and propose parallel work:**
   - read the roadmap and identify all **pending** phases (unchecked items)
   - for each pending phase, reason about whether it depends on the output of another pending phase
   - group phases into dependency tiers:
     - **Tier 1 (independent)**: phases with no dependency on other pending phases — can start immediately in parallel
     - **Tier 2+**: phases that depend on Tier 1 completion, etc.
   - if there are 2 or more independent phases in Tier 1:
     - present the dependency analysis clearly to the user
     - use `AskUserQuestion` with question: "These phases appear independent and could be worked in parallel. Would you like to set up parallel worktrees for them?" and options **Yes — set up worktrees** / **No — plan one phase**
     - if YES: for each independent phase, create a git worktree:
       - run `git worktree add ../<repo-name>-<phase-slug> main` (use a short slug from the phase name)
       - inform the user that each worktree is an isolated copy where a separate Claude session can run `/aiae:1-plan` independently
       - list the worktree paths so the user can open them
       - **STOP** — do not proceed to plan a single phase; the user will run `/aiae:1-plan` in each worktree session
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
     `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` describes
   - include the GitHub Issue ID, if one was provided

### Standalone Project Flow

**Use `AskUserQuestion` to ask how they want to provide the specification:**
- Question: "How would you like to provide the feature specification?"
- Options:
  - **GitHub Issue** — ask for the GitHub issue link, read it with `gh issue view <NUMBER>`, and
    write `SPEC.md.draft` yourself from its content, including the issue reference
    (`GitHub Issue: [github repository link]/#NUMBER`)
  - **Write it myself** — ask the user to create `SPEC.md.draft` with the feature specification,
    and wait until they say it is ready

### Approve the draft

Show the draft, then `AskUserQuestion`: "Is this draft the right starting point? Once you approve
it, I'll analyse and refine it with you." — options **Approve the draft** / **I'll edit it first**
(wait for the user, then ask again) / **Cancel** (stop, leaving the draft in place).

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
- **contradictions** — within the draft, or with how the code works today
- **scope** — what is in, and what is explicitly out
- **wording** — plain, concise language in the project's own vocabulary (see "don't invent domain
  vocabulary" in `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`); acceptance criteria that
  can be tested

**Ask, don't guess.** Whenever a decision belongs to the user — a behaviour the draft leaves open,
a scope choice, a conflict between the draft and the code — ask with `AskUserQuestion`, offering
the plausible answers as options. Group related questions into one call. Use free text only for
genuinely open-ended input.

### Rewrite it into the specification structure

The refined draft always follows "The Specification Structure" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`: Context, Intent, Out of scope and
Acceptance criteria, in that order. It states what and why; how belongs to `## Plan`, in Step 6.

- carry the draft's content into the matching section, in the user's own words where they work
- when part of the draft fits no section — a design idea, a task list, a question — raise it with
  `AskUserQuestion`: move it to the plan, turn it into an acceptance criterion, or drop it
- **acceptance criteria are required.** When the draft has none, or they leave part of the Intent
  unchecked, propose them yourself from the Intent and the code you read
- write them as "Acceptance Criteria" in that same section describes
- show the proposed criteria to the user and ask about any you are unsure of; the list is part of
  what the user approves below

### Approve the specification

Summarise what you changed and why, then `AskUserQuestion`: "Is `SPEC.md.draft` ready to become
`SPEC.md`?" — options **Approve — move it to SPEC.md** / **Keep refining** (ask what to change, and
repeat this step).

On approval:

- [ ] no open questions remain in the draft — resolve any with the user first
- [ ] the draft has Context, Intent, Out of scope and Acceptance criteria, in that order
- [ ] every acceptance criterion is numbered, specific, checkable, and marked `(manual)` when only
      a person can confirm it — fix any that are not, and ask again
- [ ] move it: `mv SPEC.md.draft SPEC.md`
- [ ] confirm `SPEC.md.draft` no longer exists

## Step 4: Check the Architecture Index

If you entered at Step 4 with an existing `SPEC.md`, first load the context as in Step 3 —
**Load the context**.

The architecture index feeds the enabling refactoring analysis in Step 5, which can take long and
is not always needed. Ask first — `AskUserQuestion`: "Should I run the enabling refactoring
analysis? It looks for refactorings that would make this feature easier, and can take a while." —
options **Run the analysis** (continue below) / **Skip it** (skip the rest of this step and Step 5,
and continue at Step 6). Mark neither as recommended.

The index is defined in **Index Location and Shape** in
`${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md`. Identify `<repo-name>` as described there, then:

- **`.skip-map-architecture` exists** → skip this step silently
- **no index** → `AskUserQuestion`: "This repo has no architecture index. It helps me find
  existing abstractions and rules before planning." — options:
  - **Build it now** — run `/aiae:map-architecture`, then continue here
  - **Continue without** — plan without it this time
  - **Never ask for this repo** — create an empty `~/.claude/repos/<repo-name>/.skip-map-architecture`
- **index stale** (see **Staleness** in that same section) →
  `AskUserQuestion`: "The architecture index is `<n>` commits behind `main`." — options **Update it
  now** (run `/aiae:map-architecture` in update mode) / **Use it as is**

## Step 5: Look for Enabling Refactorings — `fable` subagent

"Make the change easy, then make the easy change." Before proposing the plan, check whether the
codebase should change first so the feature lands cleanly. The rules are "Systemic Refactoring" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md` — read that file now if it is not loaded yet.

Launch one `Agent` with `model: "fable"`. Brief it with:

- the path to `SPEC.md` and the repository root
- if there is an index, its directory and the **Reading the Index** steps from
  `${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md`, copied in full
- the "Systemic Refactoring" section and the rules it points to, copied from `code-standards.md`
  — the subagent has not loaded the guidelines
- to search the domain's own vocabulary for where this behaviour belongs, what already implements
  related rules or abstractions, and which boundaries apply — widening only on evidence
- never to edit files
- to return only the **Design notes** below, plus each finding classified as **enabling** (makes
  this feature easier or keeps it from duplicating existing knowledge), **defer** or **no action**

If `fable` is unavailable or the call is denied, run the same brief with the session's model and
say so when presenting the plan.

Check the returned evidence before relying on it: open the files it cites for any finding that
would add a plan item.

## Step 6: Propose the Plan

- go through the specification and propose a plan of the changes
- name the layer each planned change lives in — domain, application service, or infrastructure
  (see "Architecture" in `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`) — and order the plan inside-out:
  domain → application → infrastructure, with what inner code calls out to before what calls in
- put the **enabling** refactorings from Step 5 first, each as its own `refactor:` item, before
  the feature work; deferred findings are not planned, only listed in the Design notes
- name the acceptance criteria each plan item serves, as "Plan Items" in "The Specification
  Structure" (`${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`) describes
- before asking for approval, check that every acceptance criterion is served by at least one plan
  item; add an item for any that is not, or — if the criterion itself is wrong — raise it as below
- a `SPEC.md` without numbered acceptance criteria (see "Specifications Without Acceptance
  Criteria" in the same guideline) is planned without this tracing
- add a `## Plan` section and, when the analysis ran, a `## Design notes` section to `SPEC.md`,
  the notes answering with file and symbol references — `/aiae:2-implement` checks them against what was actually built:

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
- if the user skipped the enabling refactoring analysis in Step 4, there are no enabling
  refactorings to plan and no `## Design notes` section; instead, add this line after `## Plan`:
  `The enabling refactoring analysis was skipped.`
- if planning shows the specification itself is wrong or incomplete, raise it with
  `AskUserQuestion` and update `SPEC.md` only with the user's agreement
- `AskUserQuestion`: "Is the plan approved?" — options **Approve the plan** / **Change it** (ask
  what to change, update `SPEC.md`, and ask again). Do NOT move to Step 7 without approval

## Step 7: Prepare the Feature Branch

Only proceed here when all of these hold:

- [ ] the user explicitly approved the plan
- [ ] `SPEC.md` holds the approved specification, the `## Plan` and the `## Design notes` — or,
      when the enabling refactoring analysis was skipped, the line saying so — with no open
      questions left that block implementation
- [ ] every acceptance criterion is served by at least one plan item
- [ ] `SPEC.md.draft` does not exist

### Branch Creation Checklist

- [ ] branch out to a new branch from main/master
- [ ] name it per the **Branch Naming** rules in `git-workflow.md` — GitHub Issue → `issue-NUMBER-feat-...`, no issue → `feat-...`; include `feat` only for new features

### Commit the Specification

- [ ] commit `SPEC.md` with the exact message `docs: feature specification` (other commit conventions per `git-workflow.md`)
- [ ] if, after a clash, the user chose to record the spec file name, add that line to the host
      repository's `CLAUDE.md` (or `AGENTS.md`) and commit it next as
      `docs: name the feature specification file`

## Step 8: Offer Worktree Isolation

After the branch is created and the specification is committed, use `AskUserQuestion` to ask:

> "Would you like to work in isolation via a worktree? This creates a separate working copy so your main directory stays clean for other work."

- If **YES**:
  1. Create a worktree from the current feature branch: `git worktree add ../<repo-name>-<branch-slug> <branch-name>`
  2. Inform the user of the worktree path
  3. Instruct them to open that directory and run `/aiae:2-implement` there, then stop
- If **NO**: continue to Step 9

## Step 9: Hand Off

`AskUserQuestion`: "The plan is approved and `SPEC.md` is committed. Move on to implementation?" —
options **Start /aiae:2-implement now** / **Stop here** (tell the user they can run
`/aiae:2-implement` whenever they are ready).

On **Start**, invoke the `/aiae:2-implement` skill.

## STOP — Skill Complete

**Do NOT implement anything in this skill.** Do NOT write any code — implementation happens only in
`/aiae:2-implement`.
