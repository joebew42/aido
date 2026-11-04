---
description: Organizes the commit history into a clean, logical structure. Invoked when the user wants to organize commits, clean up commit history, reorder commits, or runs /aido:3-organize-commits.
disable-model-invocation: false
---

# Organize the Commits

Organize commits into a clean, logical history following project conventions.

`SPEC.md` and `SPEC.md.draft` stand for the spec file and its draft: resolve them first, per "The
Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`.

## Step 0: Load Guidelines

Before organizing commits, load:

- `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` — all commit conventions in that file **must** be respected
- `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` — then gather the host repository's
  conventions as it describes; Step 1 needs them to place `SPEC.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`

Do NOT skip this step.

## Step 1: Decide What Happens to `SPEC.md`

Skip this step if the branch has no `SPEC.md`.

The default is to **revert** it, so the specification stays in the branch history but leaves no
file behind. Before proposing the commit structure, ask whether the user would rather keep it in the
repository.

**Find where it would belong**, in this order:

1. the host repository's `CLAUDE.md` or `AGENTS.md` — a place they name for specifications, design
   documents, decision records or other docs
2. an existing documentation folder — e.g. `docs/specs/`, `docs/design/`, `docs/adr/` or `docs/` —
   following how the files already there are named and organized
3. no documentation folder → offer only the default and a path the user types

Name the file after the feature, in the folder's own naming style (e.g.
`docs/specs/shared-todo-lists.md`). Never overwrite an existing file.

**Ask** with `AskUserQuestion`: "What should happen to `SPEC.md` once the feature is done?" —
options:

- **Revert it (Recommended)** — the last commit is `revert: docs: feature specification`
- **Move it to `<inferred path>`** — one option per location found above, up to two, each
  description saying why that location fits
- the user can always type a different path
- if the spec file already lives in a documentation folder (chosen after a clash), offer **Keep it
  where it is** instead of a move — it then needs no last commit

The chosen outcome becomes the **last** commit of the proposed structure below:

- **revert** → `revert: docs: feature specification`
- **move** → `git mv SPEC.md <path>`, committed as `docs: move feature specification to <path>`;
  the content stays as it is

## Commit Organization Rules

All commit-organization rules are defined in `git-workflow.md` (loaded above); this skill **applies** them to an existing working tree / history. Its "Before Every Commit" gate applies to every commit made here. The very last commit is the `SPEC.md` outcome chosen in Step 1.

This skill owns **final history shaping** (reordering, splitting, the `SPEC.md` outcome); `/aido:2-implement` produced the per-unit working commits.

### Follow What Was Actually Built

"Shape by Mode" in `git-workflow.md` shapes each part by its mode. Take the mode from the first of
these that has one, reading the specification as "Reading the Approved Specification" in
`specification.md` describes:

1. `## Progress` — a mode change and the slices built, as "Modes and Slices in Progress" in
   `specification.md` describes
2. the plan — the mode the item names, and its slices
3. otherwise inside-out — a branch with no plan, specification or mode

## History Management

- if some commits are already pushed, **add** new commits instead of rewriting history
- if history is not pushed, you may reset/reorganize the existing commits
- **pushing or force pushing needs the user's approval**, which the permission prompt asks for, per "Pushing Changes" in `git-workflow.md`; say first when the push would rewrite history

## Step 2: Propose Commit Structure Before Reorganizing

Before performing any rebase or history rewrite, analyze the current commits and use `AskUserQuestion` to present the proposed commit grouping:

> "Here's how I plan to reorganize the commits:
> 1. `docs: feature specification` (first)
> 2. `feat: ...` (grouped by class/module with tests)
> 3. for an outside-in part, each slice in turn: its commits inside-out, then its acceptance test
> 4. ...
> N. `revert: docs: feature specification` or `docs: move feature specification to <path>` (last, as chosen in Step 1)
>
> Does this look right, or would you like to adjust the grouping?"

**Wait for user approval before starting the rebase.** The rebase is destructive and hard to undo — getting alignment first avoids rework.

## Final Checklist

After organizing commits, verify ALL of the following:

- [ ] Docs commit message is EXACTLY "docs: feature specification" (if docs present)
- [ ] The last commit carries the `SPEC.md` outcome chosen in Step 1: "revert: docs: feature specification" (default) or "docs: move feature specification to <path>" (if docs present)
- [ ] No `SPEC.md.draft` is left in the working tree
- [ ] Docs commit is the FIRST commit in history (if docs present)
- [ ] Every commit message follows "Commit Message Format" in `git-workflow.md`
- [ ] The order and grouping follow "Commit Organization Strategy" in `git-workflow.md`, with each part
      shaped by the mode "Follow What Was Actually Built" gives it
- [ ] "Before Every Commit" in `git-workflow.md` holds
- [ ] All tests pass
