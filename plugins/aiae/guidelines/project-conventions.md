# Project Conventions

This workflow is a set of globally available skills, not tied to any repository. The skills and
guidelines are deliberately stack-agnostic: anything specific to a language, framework, toolchain
or team comes from the repository being worked on (the **host repository**).

Before planning, implementing, reviewing or committing, gather the host repository's conventions
in this order:

1. **Agent instruction files** in the repository the skill is operating in — `CLAUDE.md` and
   `AGENTS.md`. Look at the repository root and in every directory between the root and the files
   being changed; a nested file covers its own subtree. Claude Code loads `CLAUDE.md`
   automatically; read `AGENTS.md` explicitly.
2. **The repository itself**, for anything those files don't cover — `README`, `CONTRIBUTING`,
   manifests and lockfiles, linter and formatter configuration, CI configuration (the commands the
   pipeline runs are the authoritative test and lint commands), and the existing code and tests
   next to the change.
3. **The user** — when a convention still can't be determined and it matters, ask with
   `AskUserQuestion`. Never guess a command that changes state, such as a database migration.

The host repository is **authoritative on every topic it covers**; the nearest agent instruction
file wins over one higher up the tree; the global guidelines fill in whatever is left.

Know these before writing code, and load them once per skill rather than re-discovering them:

- how to run a single test, the tests for one file, and the whole suite
- how to lint, format and type-check
- the test framework, and where test files live and how they are named
- where each architectural layer lives (see "Architecture" in `code-standards.md`)
- the database migration tool: how to create, apply and roll back a migration, and whether a
  generated schema snapshot is committed
- code-generation steps that must run after certain changes
- any project-specific commit scopes, branch naming, PR template, labels or reviewers
- where the feature specification goes, if the repository names it (see "The Specification File")

A new rule that only applies to one stack or project belongs in that repository's `CLAUDE.md` or
`AGENTS.md`, never in these global guidelines.

## The Specification File

The workflow keeps each feature's specification in one file at the repository root, `SPEC.md` by
default, with its working draft next to it as the same name plus `.draft` (`SPEC.md.draft`). Some
repositories already have a `SPEC.md` of their own, so every skill resolves the actual name with
this rule, and the first match wins:

1. **The host repository names it** — its `CLAUDE.md` or `AGENTS.md` says where the workflow's
   feature specification goes (e.g. "the aiae feature specification lives in `FEATURE-SPEC.md`").
   Use that path
2. **The branch already has one** — on a feature branch whose history has a
   `docs: feature specification` commit, the spec file is the file that commit added:
   `git log --format=%H --grep='^docs: feature specification$' <default-branch>..HEAD`, then
   `git show --name-only --format= <sha>`
3. **No clash** — `SPEC.md` does not exist on the default branch
   (`git cat-file -e origin/<default-branch>:SPEC.md` fails). Use `SPEC.md`. This workflow never
   leaves its own spec on the default branch — `/aiae:3-organize-commits` reverts it or moves it
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
file and its draft. Resolve once per skill run, and never keep a draft next to its spec file.

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
