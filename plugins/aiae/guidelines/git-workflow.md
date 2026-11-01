# Git Workflow

## Commits

### Before Committing
- ensure no linting issues are present
- ensure all relevant tests pass

### Commit Message Format
- use always lower case
- use semantic commit prefixes (feat, refactor, chore, style, docs, test)
- changes that touch test files only should be prefixed as "test"
- use commit subject line only (no body copy)
- do not add any reference to Claude Code
- do not add Co-Authored-By trailers

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

## Pushing Changes
- always ask the user before pushing
- always set the origin and the branch name explicitly
- example: `git push origin feature-branch-name`

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

## Multi-Phase PR Context

When a PR is part of a multi-phase feature, the Context section should reference the main plan PR by number (e.g., `#40`) rather than an external ticket. This keeps reviewers within GitHub and gives them direct access to the full feature specification without needing access to an external tracker.

## PR Roadmap Format

Use roadmap sections in PRs that are part of a multi-phase feature.

### Item Format

- **Completed items** — include PR number reference:
  `- [x] <description> (#PR_NUMBER)`

- **Current PR** — mark with "THIS PR" instead of a number:
  `- [x] <description> (**THIS PR**)`

- **Pending items** — no PR references:
  `- [ ] <description>`

### Writing Good Roadmap Descriptions

- use specific, implementation-focused language — state what will be built or changed
- describe what the system will do, not vague outcomes
- include technical details when they clarify the phase (e.g., "API support", "keep completed tasks for 30 days")
- match language and terminology from the main feature specification

**API prefixes** — when the project exposes several APIs and a step changes one of them, prefix
the step with that API's name (e.g. `PublicAPI:`), using the names the project already uses.

### Example

```markdown
## Roadmap

- [x] PublicAPI: Add due date and priority fields to the Task type (#12345)
- [x] Keep completed tasks for 30 days instead of deleting them (**THIS PR**)
- [ ] Add API support for filtering tasks by completion state
- [ ] Hide completed tasks from the default TODO list
```

### Common Mistakes

```markdown
- [ ] Let collaborators edit shared lists (#43)  ← Wrong: no PR references on pending items
- [x] Update reminders (**THIS PR**)             ← Too vague: update what about reminders?
- [ ] Add API support                            ← Too vague: support for what?
```

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
