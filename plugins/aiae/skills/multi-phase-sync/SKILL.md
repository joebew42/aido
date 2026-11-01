---
description: Syncs the main plan PR with current progress from phase PRs. Invoked when the user wants to sync the main plan, update the main plan PR, update the roadmap, or runs /aiae:multi-phase-sync.
disable-model-invocation: false
---

# Sync Multi-Phase Plan

Update the main plan PR based on the status of individual phase PRs.

## Process

1. switch to the branch with the main plan of the feature
2. rebase the main plan branch onto `origin/main`:
   - run `git fetch origin`
   - run `git rebase origin/main`
3. check the status of all phase PRs:
   - read the current main plan PR description with `gh pr view --json body`
   - extract all PR numbers already referenced in the roadmap (e.g. `(#41)`)
   - for each extracted PR number, fetch its latest state directly: `gh pr view <NUMBER> --json number,title,state,headRefName,mergedAt`
   - do NOT use `gh pr list --search` — it can return results from unrelated repositories
4. based on the status of phase PRs, update:
   - the main plan PR description with current roadmap status
   - the specification if needed based on learnings from completed phases
5. delete local branches for any phase PRs that have been merged:
   - use `gh pr view <PR_NUMBER> --json headRefName` to get the branch name for each merged PR
   - delete the local branch with `git branch -D <branch_name>` (skip if branch doesn't exist locally)
6. if all phases are merged and the specification is fully implemented:
   - close the main plan PR using `gh pr close <PR_NUMBER> --comment "All phases completed and merged."`
   - delete the local main plan branch with `git branch -D <main_plan_branch>`
7. if there are remaining phases, ask the user about possible changes or clarifications needed in the specification

## Step 2: Suggest Repository Conventions

After syncing the main plan, follow the process in `${CLAUDE_PLUGIN_ROOT}/guidelines/evolving-guidelines.md`. It only proposes additions to this repository's `CLAUDE.md` or `AGENTS.md`, chosen by the user through `AskUserQuestion`.

## Templates

When updating the roadmap, follow the format rules in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` (PR Roadmap Format section).
