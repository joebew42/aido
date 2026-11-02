# The Feature Specification

## The Specification File

The workflow keeps each feature's specification in one file at the repository root, `SPEC.md` by
default, with its working draft next to it as the same name plus `.draft` (`SPEC.md.draft`). Some
repositories already have a `SPEC.md` of their own, so every skill resolves the actual name with
this rule, and the first match wins:

1. **The host repository names it** — its `CLAUDE.md` or `AGENTS.md` says where the workflow's
   feature specification goes (e.g. "the aido feature specification lives in `FEATURE-SPEC.md`").
   Use that path
2. **The branch already has one** — on a feature branch whose history has a
   `docs: feature specification` commit, the spec file is the file that commit added:
   `git log --format=%H --grep='^docs: feature specification$' <default-branch>..HEAD`, then
   `git show --name-only --format= <sha>`
3. **No clash** — `SPEC.md` does not exist on the default branch
   (`git cat-file -e origin/<default-branch>:SPEC.md` fails). Use `SPEC.md`. This workflow never
   leaves its own spec on the default branch — `/aido:3-organize-commits` reverts it or moves it
   into the docs — so a `SPEC.md` there belongs to the repository
4. **Clash** — `SPEC.md` is the repository's own. Ask with `AskUserQuestion`: "This repository
   already has its own `SPEC.md`. Where should the feature specification go?" — options
   **`FEATURE-SPEC.md` (Recommended)** / **`docs/specs/<feature-slug>.md`**, and the user can type
   another path. Never write to the repository's own `SPEC.md`

After a clash (step 4), offer with `AskUserQuestion` to record the choice in the host repository's
`CLAUDE.md`, or `AGENTS.md` if that is the file it uses, so step 1 answers it next time — options
**Record it** / **Not now**. On **Record it**, add one line naming the path, and commit it on the
feature branch right after the spec commit as `docs: name the feature specification file`.

Skills write **`SPEC.md`** and **`SPEC.md.draft`** for readability; read them as the resolved spec
file and its draft. Resolve once per skill run. Never keep a draft next to its spec file: when you find both, delete the
draft and tell the user.

### Reading the Approved Specification

Once the commits are organized, the spec file may already be reverted or moved into the docs, so
read it from wherever it is now:

- the spec file in the working tree, or the path it was moved to (the
  `docs: move feature specification to <path>` commit)
- otherwise, from the branch history: the content just before the
  `revert: docs: feature specification` commit — `git show <revert-sha>^:<spec-file>`

## The Specification Structure

Every skill that writes a specification uses this structure, and every skill that reads one relies
on it. It is defined here only; skills refer to it rather than restating it.

```markdown
# <descriptive title>

GitHub Issue: <repo link>/#<NUMBER>   (or omit)

## Context

<why the change is needed — the technical or product situation that calls for it>

## Intent

<what the change must achieve — not how>

## Out of scope

<what it deliberately does not do>

## Acceptance criteria

- AC1: <one checkable statement>
- AC2 (manual): <one statement only a person can confirm>

## Plan

<added by planning>

## Design notes

<added by planning, when the enabling refactoring analysis ran>

## Progress

<added by implementation>
```

**The specification states what and why, never how.** Context, Intent, Out of scope and Acceptance
criteria are written and approved before any planning. How the change is built belongs to
`## Plan` and `## Design notes`. A skill may add sections of its own after the title (for
example, where the original work came from), but the required sections keep their names and order.

### Acceptance Criteria

- number them `AC1`, `AC2`, … in order; an ID is never renumbered or reused, even when a criterion
  is changed or deferred — other sections and the commit history refer to it
- each one is a single, specific statement that can be checked — a behaviour, not a task
- a criterion an automated test can check is **automatable** and carries no marker; one that only
  a person can confirm (documentation reads well, a screen looks right) is **manual**, marked
  `(manual)` after its ID
- group them under short plain-text labels when the list is long; the numbering stays continuous
- a specification split into phases keeps the overall IDs in every phase: a phase carries only the
  criteria it delivers, with their original IDs

### Plan Items

Each item in `## Plan` names the criteria it serves, in parentheses after its title — e.g.
`1. **domain — let a list be shared** (AC1, AC3)`. Every criterion is served by at least one item.
An item that serves none (an enabling refactoring) says so: `(enabling)`.

### Acceptance in Progress

`## Progress` records each criterion that has been checked, one line each:

- `AC1: met — <test that covers it>`
- `AC2: met — confirmed by the user: <what was shown>`
- `AC3: changed — <what changed and why>` (the criterion in `## Acceptance criteria` is updated too)
- `AC4: deferred — <why>`
- `AC5: unchecked` — its plan items are not done yet

### Specifications Without Acceptance Criteria

A specification approved before this structure existed may have no `## Acceptance criteria` section,
or criteria without `AC` numbers. Skills that read it work as they did before: the plan alone is
verified, no criteria are checked, and nothing is asked about them.
