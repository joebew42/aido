---
description: Creates the main specification and tracking draft PR for a multi-phase feature. Invoked when the user wants to create a spec PR, create the main tracking PR, set up a multi-phase feature, or runs /aiae:multi-phase-spec-pr.
disable-model-invocation: false
---

# Create Multi-Phase Specification PR

Create a draft PR that serves as the main specification and tracking document for a multi-phase feature.

`SPEC.md` and `SPEC.md.draft` stand for the spec file and its draft, resolved as "The
Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` describes —
resolve it before reading or writing either.

## Purpose

- this PR remains in draft throughout the entire implementation of the feature
- this PR serves to keep the context of the overall feature specification and its status
- it provides a single source of truth for tracking progress across multiple implementation PRs

## Prerequisites

### Review and Refine Feature Spec

The specification lives in `SPEC.md`; its working draft is `SPEC.md.draft`, which is never
committed. The two never exist together:

- **both exist** → delete `SPEC.md.draft` and tell the user
- **only `SPEC.md.draft` exists** → approve and refine it with the user as `/aiae:1-plan` Step 2
  (**Approve the draft**) and Step 3 do, then move it with `mv SPEC.md.draft SPEC.md`
- **neither exists** → ask the user to write `SPEC.md.draft`, then continue as above

**BEFORE creating the multi-phase PR, review and finalize the `SPEC.md` file.**

Common refinements to consider:
- **Documentation**: Remove temporary analysis files that won't be committed
- **References**: Keep only PRs and existing docs, remove temp files

### Get the GitHub Issue (Optional)

**Ask whether a GitHub issue tracks this feature, if not already provided.** When there is one, it is used for:
- Branch naming
- Feature spec header

### Review Feature Spec and Propose Implementation Plan

**BEFORE creating the branch, review the `SPEC.md` file and propose a realistic implementation plan.**

Steps:
1. Read the `SPEC.md` file thoroughly
2. Explore the codebase as needed to understand the existing structure and relevant code
3. Propose a phased implementation plan that includes:
   - A brief summary of the feature and its goals
   - A breakdown of the phases (each phase = one PR), described as high-level outcomes (not implementation details)
   - Any risks, dependencies, or open questions worth flagging

**Wait for explicit user approval of the plan before proceeding.**

The user may request changes to the plan (e.g., merge phases, split a phase, reorder). Iterate until approved.

### Create Main Plan Branch

**AFTER the user approves the implementation plan, ensure you're on a branch with the main plan identifier.**

Branch naming pattern: `issue-NUMBER-main-plan-FEATURE_NAME`, or `main-plan-FEATURE_NAME` when there is no issue (see **Branch Naming** in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`)

**Examples:**
```
issue-42-main-plan-recurring-tasks
main-plan-shared-todo-lists
main-plan-task-reminders
```

This naming convention helps distinguish the main specification PR from individual phase implementation PRs.

### Add the GitHub Issue to Feature Spec

If there is a GitHub issue, add it at the top of `SPEC.md`:

```markdown
# Feature: [Feature Name]

**GitHub Issue**: [github repository link]/#42

## Context
...
```

## Step 1: Commit the Feature Specification

**BEFORE creating the PR, commit the `SPEC.md` file with proper conventions.**

### Commit Checklist (MANDATORY)
- [ ] commit the `SPEC.md` file as a `docs` commit
- [ ] use exact commit message: `docs: feature specification`
- [ ] subject line only (no body)
- [ ] **NEVER include Claude Code references**
- [ ] **NEVER include phrases like "Generated with Claude Code" or "Co-Authored-By: Claude"**

**Correct commit:**
```
docs: feature specification
```

**INCORRECT commits (DO NOT DO THIS):**
```
docs: Feature Specification         ← Wrong: not lowercase
docs: add feature specification     ← Wrong: different wording
Docs: feature specification         ← Wrong: not lowercase
docs: feature specification

🤖 Generated with Claude Code        ← NEVER DO THIS
Co-Authored-By: Claude <...>         ← NEVER DO THIS
```

## Step 2: Push Changes

**Checklist:**
- [ ] push changes to remote
- [ ] explicitly set origin and branch name: `git push origin BRANCH_NAME`

## Step 3: Create Draft PR

Create a draft PR with these sections:

### Required Sections
- **Context**: highlights the change we want to introduce, keeping a high-level description (not too detailed or technical)
- **This PR**: describes the introduced changes, keeping a high-level description (not too detailed or technical)
- **Roadmap**: outlines all the steps required to be implemented in the following PRs
  - All items start unchecked (`- [ ]`) since no phases have been implemented yet
  - Keep items high-level and outcome-focused
  - Avoid implementation details (refactoring, backfilling, specific classes)
  - Focus on what changes, not how it changes
  - Follow roadmap format rules in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` (PR Roadmap Format section)
  - Example: ✅ "Let tasks repeat daily, weekly or monthly"
  - Example: ❌ "Let tasks repeat daily, weekly or monthly, refactor TaskFinder to use a request object, and backfill a recurrence rule on existing tasks"
- **Link to `SPEC.md`**: add a link to the feature specification file at the end of the PR description

### PR Guidelines Checklist
- [ ] do not add any reference to Claude
- [ ] do not use any prefix in the title (e.g., no issue number or semantic commit)
- [ ] use a descriptive title instead
- [ ] create as draft PR (not ready for review)
- [ ] **MUST include link to `SPEC.md` file in PR description**

## Templates

### Complete PR Description Template

```markdown
**Specification**: [`SPEC.md`](link-to-file-in-repo)

## Context

[High-level description of the change we want to introduce]

## This PR

[High-level description of the introduced changes]

## Roadmap

- [ ] <name of the next pr/phase>
- [ ] <name of the next pr/phase>
- [ ] <name of the next pr/phase>
```

