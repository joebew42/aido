---
description: Takes over work done outside this workflow — an existing PR, a remote branch, or local changes — and sets up a fresh branch and feature spec to bring it in line with the guidelines. Invoked when the user wants to stabilize, take over, adopt or rework someone else's PR or branch, or runs /aiae:stabilize.
disable-model-invocation: false
---

# Stabilize Existing Work

Take over a change that was started outside this workflow and set it up so `/aiae:2-implement`,
`/aiae:3-organize-commits` and `/aiae:4-create-pr` can carry it to a clean PR.

`SPEC.md` and `SPEC.md.draft` stand for the spec file and its draft, resolved as "The
Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` describes —
resolve it before reading or writing either.

This skill **reads** the original work and **prepares** a new branch and `SPEC.md`. It
does not implement anything, and it never pushes to, rewrites, comments on or closes the original
PR or branch.

## Step 0: Load Context

- run `git fetch origin`
- load `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`, `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`,
  `${CLAUDE_PLUGIN_ROOT}/guidelines/testing-principles.md` and `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`
- gather the host repository's conventions as `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` describes
- if `SPEC.md` or `SPEC.md.draft` already exists in the working directory, stop and tell the
  user — this skill creates a new one

## Step 1: Identify the Original Work

Use `AskUserQuestion`:

- Question: "Which work would you like to stabilize?"
- Options:
  - **A pull request** — then ask for the PR number or URL
  - **A remote branch** — then ask for the branch name
  - **My local changes** — the uncommitted and unpushed changes in this working directory

Gather the change:

- **pull request**:
  ```
  gh pr view <number> --json number,url,title,body,headRefName,baseRefName,commits,files
  gh pr diff <number>
  ```
- **remote branch**:
  ```
  git log --oneline origin/main..origin/<branch>
  git diff origin/main...origin/<branch>
  ```
- **local changes**: `git status`, `git diff`, `git diff --staged`, and any commits not yet on main
  (`git log --oneline origin/main..HEAD`)

Read the touched files in full where the diff alone doesn't show how the change fits in.

## Step 2: Understand the Change

Present to the user, briefly:

1. **Type** — feature, fix, refactor or chore
2. **Intent** — what the change is for, in plain language, from the user's or product's point of
   view; use the PR description and commit messages, but trust the code where they disagree
3. **Gaps against the guidelines** — only concrete, verified ones, each with the file it lives in:
   - layering and the Dependency Rule — logic in delivery mechanisms, inner code naming outer
     concepts, behaviour that belongs on an aggregate (see "Architecture" in `code-standards.md`)
   - tests — missing behaviour coverage, wrong test level, mocked internals
   - commit shape — mixed concerns, vague or non-semantic messages, out-of-order history
   - anything else from the loaded guidelines that the change violates

If the change has no meaningful gaps, say so — stabilizing may then be only a matter of commit
history, and the user should know that before choosing a strategy.

## Step 3: Propose a New Branch

Use `AskUserQuestion`:

- Question: "How would you like to stabilize this work on a new branch?"
- Options:
  - **Reimplement from scratch** — new branch from main; the original stays untouched as a
    reference and every behaviour is regrown with TDD
  - **Carry over and adjust** — new branch from main with the original changes applied as
    uncommitted work; `/aiae:2-implement` then adjusts them and commits in small increments
  - **Cancel** — stop here

Recommend the option that fits the gap list: many layering or test gaps → reimplement; mostly
sound code with a messy history → carry over.

## Step 4: Create the Branch

1. Ask for a GitHub Issue ID, if there is one; if the original PR title, description or branch
   name already references an issue, offer it as the default
2. Name the branch per **Branch Naming** in `git-workflow.md`; it must differ from the original
   branch name
3. Create it from an up-to-date main:
   - **reimplement**:
     - local changes → first `git stash push -u -m "stabilize: original work"` so they are kept
       aside, then `git checkout -b <branch> origin/main`
     - PR or remote branch → `git checkout -b <branch> origin/main`
   - **carry over**:
     - local changes → `git stash push -u -m "stabilize: original work"`,
       `git checkout -b <branch> origin/main`, then `git stash apply` (keep the stash as a backup)
     - PR or remote branch → `git checkout -b <branch> origin/main`, then
       `git diff origin/main...origin/<original-branch> | git apply`
   - if `git apply` or `git stash apply` hits conflicts, stop and show them to the user rather than
     resolving them silently

## Step 5: Write and Approve the Specification

Write the first version into `SPEC.md.draft`, which is never committed. It follows "The
Specification Structure" in `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`, with this
skill's own lines and sections added:

```markdown
# <descriptive title>

GitHub Issue: <repo link>/#<NUMBER>   (or omit)
Original work: <PR #N (url) | branch origin/<name> | local changes, stash "stabilize: original work">
Strategy: <reimplement from scratch | carry over and adjust>

## What the original does
<short summary of the behaviour it introduces, per layer>

## Gaps against the guidelines
<from Step 2>

## Context
<why the change is needed>

## Intent
<from Step 2 — what the change must achieve, not how>

## Out of scope
<what it deliberately does not do>

## Acceptance criteria
- AC1: <one checkable statement — the behaviour the original work was meant to deliver>

## Plan
<the changes, each tagged with its layer and the criteria it serves, ordered inside-out:
domain → application → delivery>
```

- refine it with the user as `/aiae:1-plan` Step 3 does — fill gaps, remove ambiguity, reword,
  and ask with `AskUserQuestion` wherever a decision belongs to the user
- propose the plan and **wait for explicit user approval**, as `/aiae:1-plan` Step 6 does;
  update the draft with any changes the user asks for
- once approved, move it with `mv SPEC.md.draft SPEC.md` and confirm `SPEC.md.draft` is gone —
  the two files never exist together
- commit **only** `SPEC.md` with the exact message
  `docs: feature specification` — in carry-over mode the original changes stay uncommitted for
  `/aiae:2-implement` to commit incrementally

## Step 6: Hand Off

Tell the user the branch is ready and the next steps:

1. run `/aiae:2-implement` — it works through the plan in small commits; in carry-over mode it
   adjusts and commits the applied original changes rather than writing them anew
2. run `/aiae:3-organize-commits` to shape the final history
3. run `/aiae:4-create-pr` when they decide it is time to open the PR

Use `AskUserQuestion` to ask whether they want a worktree for this branch, as `/aiae:1-plan`
Step 8 does — **not available in carry-over mode**, because the uncommitted original changes live
in this working directory.

## STOP — Skill Complete

**Do NOT proceed further.** Do NOT implement anything, organize commits, or create a PR.
