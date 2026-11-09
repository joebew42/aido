# Git Workflow

## Commits

### Before Every Commit

This is the per-commit gate. It applies to every commit, review fixes included, and before marking a
task complete:

- linting is clean
- the relevant tests pass with no regressions. Relevant means the unit's own tests, its
  collaborators' tests, and the tests of every file the change edited
  (`git diff --name-only origin/<default-branch>...HEAD`). Not only the file directly modified, and
  not the enclosing directory, whose unrelated failures can't be told from a regression
- when a value, constant, flag or API is changed or removed, search for every reference to the old
  form, comments and documentation included, and update them in the same change
- read the diff, and delete every comment it adds that "Comments" in `code-standards.md` doesn't
  allow

One exception: `/aido:3-organize-commits` runs the relevant tests once, on the final commit, instead
of at each commit. The commits it reshapes were tested while they were built, so it runs no tests for
a single commit, not even an outside-in slice's acceptance test. Linting, the search for old
references and the comment clean-up still apply to each of its commits.

### Commit Message Format

- always lower case
- a semantic prefix: feat, refactor, chore, style, docs, test
- `test` for a change that touches only test files
- a subject line only, with no body
- no reference to Claude Code
- no Co-Authored-By trailers, unless the host repository requires them

#### Conventional-commit scopes

Use a scope only when the host repository defines its own (see `project-conventions.md`), such as one
per public API it exposes. Then a commit confined to one of those areas carries the scope, and
application-code commits stay unscoped:

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

- every push needs the user's approval, and a hook asks for it when the push runs. Don't also ask
  with `AskUserQuestion`: run the push, and the permission prompt is the question
- if the user declines, don't retry the push or push another way. Stop, and say what is left
  unpushed
- always name the remote and the branch: `git push origin feature-branch-name`
- never set `aido.allowCommitAttribution`: that opt-out is the user's to set

## Using GitHub CLI

- use `gh` for everything on GitHub, such as reading or creating PRs
- never use `gh pr list --search`: it can return PRs from other repositories. Read a PR you know
  with `gh pr view <NUMBER>`, and list recent ones with `gh pr list --state <state> --limit <n>`

### Reading a PR's Review Comments

Read one PR's review comments with these two calls:

- `gh pr view <NUMBER> --json number,title,url,reviews,comments` — each review's summary and the
  conversation
- `gh api repos/{owner}/{repo}/pulls/<NUMBER>/comments` — the comments on lines of code. `gh`
  fills in `{owner}` and `{repo}` from the current repository

## Commit Organization Strategy

### General Principles

- commit tests with the code they cover
- one commit per class or module: a change to `SomeService` goes with the `SomeService` tests
- give each changed service its own commit, even when the changes are alike: a one-line change to
  `ServiceA` and to `ServiceB` is two commits
- inside-out: the innermost parts first, the outer parts last, within the shape each part's mode
  gives it (see "Shape by Mode" below)
- request or acceptance tests go last, except for an outside-in part's
- API-layer changes get their own commit, apart from application code (models, services). If the
  project defines API scopes, that commit carries one (see "Conventional-commit scopes" above)
- implementations of collaborators, such as `PostgresqlTaskRepository` (see "Collaborators and their
  implementations" in `code-standards.md`), get their own commit, after application code and before
  API-layer commits
- database migrations and any generated schema snapshot get their own commit, apart from model and
  application code, even when a migration and its model were created together
- **stand-alone** refactoring gets its own `refactor:` commit. That is any refactoring of code that
  existed before the feature, even when the feature motivated it: an enabling refactoring planned up
  front, or one found while implementing. It lands before the feature commits that depend on it.
  Refactoring the feature's own new code stays in that feature's commit
- A refactoring from `## Refactorings` always gets its own `refactor:` commit, after the feature
  commits, even when it only reshapes the feature's new code (see "Refactorings" in
  `specification.md`)

### Shape by Mode

Each part of a plan has a mode (see "The Modes" in `tdd.md`), which shapes its commits:

- **`inside-out` and `in-unit`** — the principles above, with the part's acceptance tests last
- **`outside-in`** — one group of commits per slice, in slice order. Each group is inside-out, and
  closed by the slice's acceptance test once it is green. The history is slice-shaped, not literally
  outside-in, because an outer commit calling code from a later commit would fail the per-commit gate
- **no plan, specification or mode** — inside-out. This also covers older specifications

Thin slices can produce several schema changes. While they are unpushed, squash a part's schema
changes into one migration commit, in the first slice that needs it.

A phase merges only as a complete set of slices. Merged partway, an outside-in phase could ship
without what its later slices add.

### Special Cases

- the feature specification, `SPEC.md` or the file named per "The Specification File" in
  `specification.md`, is committed as `docs: feature specification`. That commit is always the
  **first** in history
- while history is unpushed, squash later `SPEC.md` edits into that commit. Once it is pushed, add a
  `docs: update feature specification` commit instead
- the very last commit settles what happens to `SPEC.md`. By default it is a
  `revert: docs: feature specification` that removes it. When the user chooses to keep it, it is a
  `docs: move feature specification to <path>` that moves it into the repository's documentation
- once commits are pushed, add new commits instead of rewriting history

## Hand-off Outcomes

Every skill that offers the next one with a question (`/aido:1-plan`, `/aido:stabilize`,
`/aido:2-implement` and `/aido:3-organize-commits`) acts on the answer the same way, once its own work
is done:

- **start the next skill here**, such as **Implement here**, **Organize the commits** or **Open the
  PR** → invoke the next skill. The answer approves only starting it: all of that skill's own
  questions and approvals still happen. If this skill's work can't finish cleanly, start nothing, and
  tell the user why
- **… in a fresh context** → finish this skill's own work, including its commits, start nothing, and
  tell the user to run `/clear`, then the next skill. A skill can't run `/clear` itself
- **Stop here** → start nothing. Tell the user they can run the next skill later, and that a new
  session gives it a fresh context
- **nobody answered the question, or it couldn't be asked** → start nothing

The fresh-context option carries the recommendation whenever continuing would, and is not recommended
when continuing isn't.

## Branch Management

### Branch Naming

- follow the host repository's branch naming, if it has one. Otherwise:
  - **GitHub Issue ID** → `issue-NUMBER-feat-CHANGE_TITLE` (e.g. `issue-42-feat-shared-lists`)
  - **no issue** → `feat-CHANGE_TITLE`
- include `feat` only when the change is a new feature
- a multi-phase main plan branch is `issue-NUMBER-main-plan-FEATURE_NAME`, or
  `main-plan-FEATURE_NAME` without an issue
- delete local branches whose PRs are merged

### Worktree Branch Discipline

In a `git worktree` for a parallel phase, check the branch with `git branch --show-current` before
implementing. The directory name, such as `todo-app-phase-3-reminders`, doesn't guarantee the right
branch: it may still be on the main-plan branch, or on one from an earlier session. Work committed to
the wrong branch takes a force push to recover.

### History Rewrites

Before a destructive history rewrite (`git reset --hard`, rebase, cherry-pick rebuild), **rely on
`git reflog` for recovery**. Do NOT create backup branches or tags: the reflog already keeps the old
tip, and an extra ref clutters the branch list.

### Syncing with Main/Master Branch

- **use `git rebase`, not `git merge`**, to bring the default branch into a feature branch, e.g.
  `git rebase main`. The history stays linear, with no merge commits
