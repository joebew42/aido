# Git Workflow

## Commits

### Before Every Commit

This is the per-commit gate, including for review fixes. It also applies before marking a task complete.

- linting is clean
- the relevant tests pass with no regressions. Relevant means the unit's own tests, its collaborators' tests, and the tests of every file the change edited (`git diff --name-only origin/<default-branch>...HEAD`), not only the file directly modified and not the enclosing directory, whose unrelated failures can't be told from a regression
- when a value, constant, flag or API is changed or removed, search for all references to the old form, including comments and documentation, and update them in the same change
- read the diff and delete every comment it introduces that "Comments" in `code-standards.md` doesn't allow

### Commit Message Format
- use always lower case
- use semantic commit prefixes (feat, refactor, chore, style, docs, test)
- changes that touch test files only should be prefixed as "test"
- use commit subject line only (no body copy)
- do not add any reference to Claude Code
- do not add Co-Authored-By trailers, unless the host repository requires them

#### Conventional-commit scopes

Use a scope only when the host repository defines its own (see `project-conventions.md`) — for
example, one scope per public API it exposes. When it does, a commit confined to one of those areas
carries the scope, and application-code commits stay unscoped:

```
feat(public-api): expose the completion state on the task type
test(public-api): cover the task completion transitions
```

### Examples
```
feat: add endpoint to share a todo list
refactor: extract due date validation to separate service
test: add coverage for edge cases in task model
chore: update dependencies
```

## The Default Branch

`<default-branch>` stands for the repository's default branch, which may not be called `main`.
Resolve it once per skill run with `git symbolic-ref --short refs/remotes/origin/HEAD`, dropping the
`origin/` prefix. If that fails, use the `HEAD branch` line of `git remote show origin`.

## Pushing Changes
- always ask the user before pushing
- always set the origin and the branch name explicitly
- example: `git push origin feature-branch-name`
- never set `aido.allowCommitAttribution` or `aido.allowMemoryWrites`: those opt-outs are the user's
  to set

## Using GitHub CLI
- use the github command line when interacting with GitHub
- examples: fetching PR info, creating PRs, etc.

## Commit Organization Strategy

### General Principles
- organize commits so that tests and code changes are committed together
- keep commits per class or module (e.g., if changing `SomeService`, include `SomeService` tests in same commit)
- when multiple service classes are changed as part of the same feature, give each service its own commit — even if the changes are similar (e.g., `ServiceA` and `ServiceB` both get a one-line update: two commits, not one)
- use inside-out strategy: commit most internal parts first, end with outer parts
- request or acceptance tests should be committed last
- keep API-layer changes in their own commit, separate from application code (models, services) — if the project defines API scopes, the API commit carries one (see "Conventional-commit scopes" above)
- implementations of collaborators (e.g. `PostgresqlTaskRepository`; see "Collaborators and their implementations" in `code-standards.md`) go in their own commit, after application code and before API-layer commits
- database migrations and any generated schema snapshot go in their own commit, separate from model and application code — even when a migration and its model are created together, split them
- commit **stand-alone** refactoring separately with a `refactor:` prefix — that is any refactoring of code that existed before the feature, even when the feature motivated it (an enabling refactoring planned up front, or a systemic one found while implementing); it lands before the feature commits that depend on it. Refactoring the feature's own new code stays inside that feature's commit

### Special Cases
- the feature specification — `SPEC.md`, or the file named per "The Specification File" in `specification.md` — is committed as `docs: feature specification`, and that commit should always be the **first** in history
- squash later `SPEC.md` edits into that original docs commit **only while history is unpushed**; once it is pushed, add a new `docs: update feature specification` commit instead
- the very last commit settles what happens to `SPEC.md`: by default a `revert: docs: feature specification` that removes it, or — when the user chooses to keep it — a `docs: move feature specification to <path>` that moves it into the repository's documentation
- if commits are already pushed, add new commits instead (do not alter commit history)

## Branch Management

### Branch Naming
- if the host repository defines its own branch naming, follow it; otherwise:
  - **GitHub Issue ID** → `issue-NUMBER-feat-CHANGE_TITLE` (e.g. `issue-42-feat-shared-lists`)
  - **no issue** → `feat-CHANGE_TITLE`
- include `feat` only when the change is a new feature
- for multi-phase main plan branches, use `issue-NUMBER-main-plan-FEATURE_NAME`, or `main-plan-FEATURE_NAME` without an issue
- delete local branches that refer to already merged PRs

### Worktree Branch Discipline

When using `git worktree` for parallel phases, always verify the active branch with `git branch --show-current` before starting implementation. The worktree directory name (e.g. `todo-app-phase-3-reminders`) does not guarantee the correct branch is checked out — it may still point to the main-plan branch or another branch from a previous session. Committing implementation work to the wrong branch (e.g. the main-plan branch) requires a force push to recover, which is disruptive.

### History Rewrites

When performing a destructive history rewrite (`git reset --hard`, rebase, cherry-pick rebuild),
**rely on `git reflog` for recovery** — do NOT create temporary backup branches/tags. The reflog
already preserves the prior tip; an extra backup ref is redundant and clutters the branch list.

### Syncing with Main/Master Branch
- **use `git rebase` over `git merge`** when aligning changes between main/master branch and feature branch
- this keeps commit history clean and linear
- example: `git rebase main` or `git rebase master`
- avoid merge commits when syncing feature branches with main/master
