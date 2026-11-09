---
description: Switches to the main plan branch for a multi-phase feature. Invoked when the user wants to switch to the main plan branch, go to the plan branch, or runs /aido:multi-phase-switch.
disable-model-invocation: false
---

# Switch to Main Plan Branch

**In Copilot CLI only:** before anything else, read `guidelines/copilot-cli.md` in the plugin root, two folders above this skill's base directory, and follow it.

Switch to the main plan branch of a multi-phase feature.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Process

1. **Find the main plan branch:**
   - list every local and remote branch with `git branch -a`
   - look for names that contain `main-plan-`, such as `issue-42-main-plan-*` or `main-plan-*`

2. **No main plan branch:**
   - tell the user none was found
   - ask with `AskUserQuestion`: "No main plan branch exists. Should I create one?" — options:
     - **Yes — run `/aido:multi-phase-spec-pr`**
     - **No — stop**
   - stop after the answer

3. **Exactly one:**
   - switch to it: `git checkout <branch-name>`
   - tell the user

4. **Several:**
   - ask with `AskUserQuestion`: "Several main plan branches exist. Which one should I switch to?" —
     one option per branch, labelled with its name
   - switch to the chosen branch: `git checkout <branch-name>`
   - tell the user

Whenever this skill ends, also on **No — stop**, end as "Ending a Skill" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes.
