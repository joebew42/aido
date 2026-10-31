---
description: Organizes the commit history into a clean, logical structure. Invoked when the user wants to organize commits, clean up commit history, reorder commits, or runs /aiae:3-organize-commits.
disable-model-invocation: false
---

# Organize the Commits

Organize commits into a clean, logical history following project conventions.

`SPEC.md` and `SPEC.md.draft` stand for the spec file and its draft, resolved as "The
Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` describes —
resolve it before reading or writing either.

## Step 0: Load Guidelines

Before organizing commits, load:

- `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` — all commit conventions in that file **must** be respected
- `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` — then gather the host repository's
  conventions as it describes; Step 1 needs them to place `SPEC.md`

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

All commit-organization rules are defined in `git-workflow.md` (loaded above) — that is the single source of truth. This skill **applies** them to an existing working tree / history; it does not redefine them. In scope:

- semantic, lowercase, subject-only messages (`feat:`, `test:`, `refactor:`, `chore:`, `style:`, `docs:`); test-only changes use `test:`; no Claude reference
- group per class/module (tests with their code); inside-out ordering; request/acceptance tests committed last
- keep API-layer commits separate from application code; keep database migrations and any generated schema snapshot in their own commit, separate from model code
- refactoring of pre-existing code in its own `refactor:` commit, before the feature commits that depend on it; refactoring of the feature's own new code stays inside the feature commit
- the `docs: feature specification` commit stays **first**; squash `SPEC.md` edits into it only while unpushed, otherwise add `docs: update feature specification`; the very last commit is the `SPEC.md` outcome chosen in Step 1
- before committing: linting clean and all tests green

This skill owns **final history shaping** (reordering, splitting, the `SPEC.md` outcome); `/aiae:2-implement` produced the per-unit working commits.

## History Management

- if some commits are already pushed, **add** new commits instead of rewriting history
- if history is not pushed, you may reset/reorganize the existing commits
- **always ask before pushing or force pushing** — never push automatically; use `AskUserQuestion` with options **Push** / **Cancel** (or **Force push** / **Cancel** when history was rewritten)

## Step 2: Propose Commit Structure Before Reorganizing

Before performing any rebase or history rewrite, analyze the current commits and use `AskUserQuestion` to present the proposed commit grouping:

> "Here's how I plan to reorganize the commits:
> 1. `docs: feature specification` (first)
> 2. `feat: ...` (grouped by class/module with tests)
> 3. ...
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
- [ ] All commit messages are lowercase
- [ ] All commits use semantic prefixes (feat:, test:, refactor:, chore:, style:, docs:)
- [ ] Database migrations and any generated schema snapshot are in their own commit, separate from model code
- [ ] Tests and implementation are grouped per class/module
- [ ] API changes are separate from application code changes
- [ ] Inside-out strategy followed (internal → outer)
- [ ] Request, integration or acceptance tests are last (if present)
- [ ] No Claude Code references in any commit message
- [ ] No commit body messages (subject line only)
- [ ] No linting issues present
- [ ] All tests pass
