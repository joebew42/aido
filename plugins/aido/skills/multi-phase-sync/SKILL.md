---
description: Syncs the main plan PR with current progress from phase PRs. Invoked when the user wants to sync the main plan, update the main plan PR, update the roadmap, or runs /aido:multi-phase-sync.
disable-model-invocation: false
---

# Sync Multi-Phase Plan

In Copilot CLI, **before any other action**, resolve `${CLAUDE_PLUGIN_ROOT}` as two directories above
the skill base directory, then load `${CLAUDE_PLUGIN_ROOT}/guidelines/copilot-cli.md` and follow it.

Update the main plan PR from the state of each phase PR.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Process

1. switch to the feature's main plan branch
2. rebase it onto `origin/<default-branch>`:
   - run `git fetch origin`
   - run `git rebase origin/<default-branch>`
3. check the state of every phase PR:
   - read the main plan PR's description with `gh pr view --json body`
   - take every PR number the roadmap already names, such as `(#41)`
   - fetch each one's latest state directly:
     `gh pr view <NUMBER> --json number,title,state,headRefName,mergedAt`
   - find no PR by searching, as "Using GitHub CLI" in `git-workflow.md` says
4. from those states, update:
   - the main plan PR's description, with the roadmap's current state
   - the specification, if the finished phases taught something it needs
5. delete the local branch of each merged phase PR:
   - get its name with `gh pr view <PR_NUMBER> --json headRefName`
   - delete it with `git branch -D <branch_name>`. Skip it if it doesn't exist locally
6. when every phase is merged and the specification is fully built:
   - close the main plan PR with `gh pr close <PR_NUMBER> --comment "All phases completed and merged."`
   - delete the local main plan branch with `git branch -D <main_plan_branch>`
7. when phases remain, ask the user whether the specification needs changes or clarifications
8. end as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes.

## Templates

When updating the roadmap, follow the format rules in `${CLAUDE_PLUGIN_ROOT}/guidelines/pr-roadmap.md`.
