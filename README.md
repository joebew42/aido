# AI-Augmented Engineer

A Claude Code plugin marketplace with one plugin, `aiae`: a stack-agnostic, test-driven engineering
workflow. The skills carry no language, framework or third-party conventions of their own — they
read them from the repository they are working in (its `CLAUDE.md` and `AGENTS.md`).

## What is an AI-Augmented Engineer?

An AI-augmented engineer uses an AI agent to do more of the work, without handing over the
judgement. The agent explores the code, drafts the specification, writes the tests and the code,
and shapes the commits and the pull request. The engineer decides what gets built, approves every
step that matters, and stays accountable for the result.

The workflow is built around that split:

- **The engineer decides, the agent proposes.** Each stage ends with an explicit approval — the
  specification, the plan, the commit structure, the pull request — and the agent asks instead of
  guessing whenever a choice is yours.
- **Specification before code.** Every feature starts as a draft that is refined with you into
  `SPEC.md`, then planned. Implementation only starts from an approved plan.
- **Small, reviewable steps.** Code grows test by test with test-driven development, so each change
  is easy to follow and to stop.
- **Good engineering practices by default.** Clean architecture, deliberate refactoring, focused
  tests and a clean commit history are part of every step, not an afterthought.
- **Your repository's rules come first.** The workflow brings practices, not conventions. How to
  test, lint, name or structure code comes from your repository — first from its `CLAUDE.md` and
  `AGENTS.md`, then from the code itself.

## Install

```
/plugin marketplace add <owner>/<repo>
/plugin install aiae@ai-augumented-engineer
```

Every skill is then available as `/aiae:<skill>`.

### Recommended user settings

The guidelines ask for commits and PRs without AI attribution and for no auto-memory. A plugin
can't set these, so add them to your `~/.claude/settings.json`:

```json
{
  "autoMemoryEnabled": false,
  "attribution": { "commit": "", "pr": "" }
}
```

The plugin's hooks also block commit messages with `Co-Authored-By` trailers and writes to Claude's
memory directory.

## Skills

### Single-phase feature

- `/aiae:1-plan` — draft, refine and plan a feature into `SPEC.md`
- `/aiae:2-implement` — implement the feature with TDD
- `/aiae:3-organize-commits` — organize the commit history
- `/aiae:4-create-pr` — create a pull request
- `/aiae:5-handle-review` — handle PR review feedback

### Multi-phase feature

- `/aiae:multi-phase-spec-pr` — create the specification tracking PR
- `/aiae:multi-phase-switch` — switch to the main plan branch
- `/aiae:multi-phase-sync` — sync the main plan with progress

### Utilities

- `/aiae:resolve-migration-conflict` — resolve database migration conflicts after a rebase, with any migration tool
- `/aiae:pr-review` — review a PR from a reviewer's perspective (summary, focus areas, safety assessment)
- `/aiae:stabilize` — take over a PR, remote branch, or local changes made outside this workflow
- `/aiae:map-architecture` — build or update a slim index of the repo's domain areas and their building blocks
- `/aiae:assess-architecture` — assess the architecture area by area and open GitHub issues for the refactorings you pick

## Quick start

### A simple feature

1. `/aiae:1-plan` — drafts the specification in `SPEC.md.draft` (from a GitHub issue, or one you
   write), refines it with you until you approve it as `SPEC.md`, plans the work, creates the
   branch, and offers to move on to implementation
2. `/aiae:2-implement` — builds the feature
3. `/aiae:3-organize-commits` — cleans up the commit history, and asks whether to revert `SPEC.md`
   (the default) or keep it in the repository's docs
4. `/aiae:4-create-pr` — creates the pull request

### A multi-phase feature

1. Write the overall feature specification in `SPEC.md.draft`
2. `/aiae:multi-phase-spec-pr` — creates the main tracking PR
3. For each phase (or set of parallel phases):
   - `/aiae:1-plan` — plans the phase, and offers parallel worktrees for independent phases
   - `/aiae:2-implement`, `/aiae:3-organize-commits`, `/aiae:4-create-pr`
   - `/aiae:multi-phase-sync` — updates the main plan and starts the next phase

### Taking over someone else's work

1. `/aiae:stabilize`, pointed at the PR, remote branch, or local changes
2. Choose whether to reimplement from scratch or carry the original changes over and adjust them
3. Approve the plan it writes into `SPEC.md`
4. Continue with `/aiae:2-implement`, `/aiae:3-organize-commits` and `/aiae:4-create-pr`

### A migration conflict after a rebase

Run `/aiae:resolve-migration-conflict` when another PR's migration was merged while yours was open.

## Guidelines

The skills load these from `plugins/aiae/guidelines/`:

- `git-workflow.md` — commit conventions, branching strategy, GitHub CLI usage
- `code-standards.md` — test-driven development, design principles, quality checks, interaction style
- `testing-principles.md` — test structure, boundary collaboration, pre-commit suite scope, flaky-test prevention
- `project-conventions.md` — how the skills find the host repository's own conventions in its `CLAUDE.md` and `AGENTS.md`
