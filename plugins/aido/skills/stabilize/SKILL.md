---
description: Takes over work done outside this workflow — an existing PR, a remote branch, or local changes — and sets up a fresh branch and feature spec to bring it in line with the guidelines. Invoked when the user wants to stabilize, take over, adopt or rework someone else's PR or branch, or runs /aido:stabilize.
disable-model-invocation: false
---

# Stabilize Existing Work

**In Copilot CLI only:** before anything else, read `guidelines/copilot-cli.md` in the plugin root, two folders above this skill's base directory, and follow it. Read every guideline this skill names whole, with `view`, one file per call.

Take over a change started outside this workflow. Set it up so `/aido:2-implement`,
`/aido:3-organize-commits` and `/aido:4-open-pr` can carry it to a clean PR.

Resolve `SPEC.md` and `SPEC.draft.md` first, as "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes.

This skill **reads** the original work and **prepares** a new branch and `SPEC.md`. It builds
nothing. It never pushes to, rewrites, comments on or closes the original PR or branch.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Step 0: Load Context

- run `git fetch origin`
- load `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`,
  `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`,
  `${CLAUDE_PLUGIN_ROOT}/guidelines/testing-principles.md`, `${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md`,
  `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` and
  `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
- gather the host repository's conventions as
  `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` describes
- on a leftover spec, stop, as "A Leftover Spec" in
  `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes
- if `SPEC.md` or `SPEC.draft.md` already exists in the working directory, stop and tell the user:
  this skill creates a new one

## Step 1: Identify the Original Work

Ask with `AskUserQuestion`:

- Question: "Which work should I take over?"
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
  git log --oneline origin/<default-branch>..origin/<branch>
  git diff origin/<default-branch>...origin/<branch>
  ```
- **local changes**: `git status`, `git diff`, `git diff --staged`, and any commits not yet on the
  default branch (`git log --oneline origin/<default-branch>..HEAD`)

Read the touched files in full where the diff alone doesn't show how the change fits in.

## Step 2: Understand the Change

Show the user, briefly:

1. **Type** — feature, fix, refactor or chore
2. **Intent** — what the change is for, in plain words, from the user's or product's point of view.
   Use the PR description and commit messages, but trust the code where they disagree
3. **Gaps against the guidelines** — only concrete ones you checked, each with its file:
   - layers and the Dependency Rule: logic in infrastructure, inner code naming anything in
     infrastructure, behaviour that belongs on an aggregate (see "Architecture" in
     `code-standards.md`)
   - tests: behaviour not covered, the wrong test level, mocked internals
   - commit shape: mixed concerns, vague or non-semantic messages, history out of order
   - anything else in the loaded guidelines that the change breaks

If the change has no real gaps, say so. Stabilizing may then only mean fixing the commit history, and
the user should know that before choosing a strategy.

## Step 3: Propose a New Branch

Ask with `AskUserQuestion`:

- Question: "How should I bring this work onto a new branch?"
- Options:
  - **Reimplement from scratch** — a new branch from the default branch. The original stays untouched
    as a reference, and every behaviour is grown again with TDD
  - **Carry over and adjust** — a new branch from the default branch, with the original changes
    applied as uncommitted work. `/aido:2-implement` then adjusts them and commits in small steps
  - **Cancel** — stop here

Recommend the option the gaps point to: many layer or test gaps → reimplement. Mostly sound code
with a messy history → carry over.

## Step 4: Create the Branch

1. ask for a GitHub Issue ID, if there is one. If the original PR title, description or branch name
   already names an issue, offer it as the default
2. name the branch as **Branch Naming** in `git-workflow.md` describes. It must differ from the
   original branch's name
3. create it from an up-to-date default branch:
   - **reimplement**:
     - local changes → first `git stash push -u -m "stabilize: original work"` to keep them aside,
       then `git checkout -b <branch> origin/<default-branch>`
     - PR or remote branch → `git checkout -b <branch> origin/<default-branch>`
   - **carry over**:
     - local changes → `git stash push -u -m "stabilize: original work"`,
       `git checkout -b <branch> origin/<default-branch>`, then `git stash apply`. Keep the stash as
       a backup
     - PR or remote branch → `git checkout -b <branch> origin/<default-branch>`, then
       `git diff origin/<default-branch>...origin/<original-branch> | git apply`
   - if `git apply` or `git stash apply` hits conflicts, stop and show them to the user. Don't
     resolve them silently

## Step 5: Write and Approve the Specification

Write the first version into `SPEC.draft.md`, which is never committed. It follows "The
Specification Structure" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`, with this skill's
own lines and sections added:

```markdown
# <descriptive title>

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

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
<the changes, written and ordered as "Plan Items" in "The Specification Structure" describes, each
feature item naming its mode and reason as "The Modes" in `tdd.md` defines them. A carry-over item is
normally inside-out, citing the original work>
```

- refine it with the user as `${CLAUDE_PLUGIN_ROOT}/guidelines/refining-a-draft.md` describes,
  alignment check included. Don't ask about the enabling refactoring analysis
- propose the plan and **wait for explicit approval**, as "Approve the plan" in `/aido:1-plan` Step 6
  does. Leave its question on how to continue to Step 6 below. Update the draft with any changes the
  user asks for
- once approved, move it with `mv SPEC.draft.md SPEC.md`. Then follow "The Specification File" in
  `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` for the draft
- commit **only** `SPEC.md`, with the exact message `docs: feature specification`. In carry-over mode
  the original changes stay uncommitted, for `/aido:2-implement` to commit step by step

## Step 6: Hand Off

Tell the user the branch is ready. Then ask "Choose how to continue" from Step 6 of
`${CLAUDE_PLUGIN_ROOT}/skills/1-plan/SKILL.md` with `AskUserQuestion`, and go on as its Step 8 and
**Hand-off Outcomes** in `git-workflow.md` do. Ask nothing else about the hand-off.

In carry-over mode, leave out **Implement in a worktree**, and keep **Implement in a fresh context**.
The uncommitted original changes live in this working directory, and only the fresh context stays in
it. `/aido:2-implement` then adjusts and commits those changes instead of writing them again.

## STOP — Skill Complete

**Do NOT implement anything, organize commits, or open a PR in this skill.** Only
`/aido:2-implement` builds, and it offers the steps after it.

Whenever this skill ends, also when it stops early, end as "Ending a Skill" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes.
