---
description: Switches to the main plan branch for a multi-phase feature. Invoked when the user wants to switch to the main plan branch, go to the plan branch, or runs /aido:multi-phase-switch.
disable-model-invocation: false
---

# Switch to Main Plan Branch

Switch to the main plan branch for a multi-phase feature.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Process

1. **Find the main plan branch:**
   - run `git branch -a` to list all local and remote branches
   - look for branches whose name contains `main-plan-` (e.g. `issue-42-main-plan-*` or `main-plan-*`)

2. **If no main plan branch is found:**
   - inform the user that no main plan branch was detected
   - use `AskUserQuestion` with question: "No main plan branch exists. Should I create one?" and options:
     - **Yes — run `/aido:multi-phase-spec-pr`**
     - **No — stop**
   - stop after the user responds

3. **If exactly one main plan branch is found:**
   - switch to it: `git checkout <branch-name>`
   - confirm the switch to the user

4. **If multiple main plan branches are found:**
   - use `AskUserQuestion` with question: "Several main plan branches exist. Which one should I switch to?" and one option per branch (label = branch name)
   - switch to the chosen branch: `git checkout <branch-name>`
   - confirm the switch to the user
