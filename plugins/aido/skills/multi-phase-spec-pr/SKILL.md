---
description: Creates the main specification and tracking draft PR for a multi-phase feature. Invoked when the user wants to create a spec PR, create the main tracking PR, set up a multi-phase feature, or runs /aiae:multi-phase-spec-pr.
disable-model-invocation: false
---

# Create Multi-Phase Specification PR

Create a draft PR that serves as the main specification and tracking document for a multi-phase feature.

`SPEC.md` and `SPEC.md.draft` stand for the spec file and its draft: resolve them first, per "The
Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`, `${CLAUDE_PLUGIN_ROOT}/guidelines/pr-roadmap.md` and `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`.

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
  (**Approve the draft**) and Step 3 do — rewriting it into "The Specification Structure" in
  `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`, with numbered acceptance criteria for
  the whole feature — then move it with `mv SPEC.md.draft SPEC.md`
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
   - The acceptance criteria each phase delivers, by ID — every criterion is delivered by at least one phase
   - Any risks, dependencies, or open questions worth flagging

**Wait for explicit user approval of the plan before proceeding.** Once approved, write the phases
into `SPEC.md` as its `## Plan`, each naming the criteria it delivers (see "Plan Items" in "The
Specification Structure") — `/aiae:1-plan` reads them to carry each phase's criteria into its
phase draft.

The user may request changes to the plan (e.g., merge phases, split a phase, reorder). Iterate until approved.

### Create Main Plan Branch

**AFTER the user approves the implementation plan, ensure you're on a branch with the main plan identifier.**

Branch naming pattern: `issue-NUMBER-main-plan-FEATURE_NAME`, or `main-plan-FEATURE_NAME` when there is no issue (see **Branch Naming** in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`)

### Add the GitHub Issue to Feature Spec

If there is a GitHub issue, add it at the top of `SPEC.md`:

```markdown
# <descriptive title>

GitHub Issue: [github repository link]/#42

## Context
...
```

## Step 1: Commit the Feature Specification

Commit it as a `docs` commit with the exact message `docs: feature specification`, per
`git-workflow.md`.

## Step 2: Push Changes

Per `git-workflow.md`, confirm with `AskUserQuestion`: "Ready to push `BRANCH_NAME` to origin so I can open the PR?" — options **Push** / **Cancel**.

- on **Push**: run `git push origin BRANCH_NAME`
- on **Cancel**: stop — the PR needs the branch on origin

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
  - Follow the format rules in `pr-roadmap.md`
  - Example: ✅ "Let tasks repeat daily, weekly or monthly"
  - Example: ❌ "Let tasks repeat daily, weekly or monthly, refactor TaskFinder to use a request object, and backfill a recurrence rule on existing tasks"
- **Link to `SPEC.md`**: add a link to the feature specification file at the top of the PR description

### PR Guidelines Checklist
- [ ] do not add any reference to Claude
- [ ] do not use any prefix in the title (e.g., no issue number or semantic commit)
- [ ] use a descriptive title instead
- [ ] create as draft PR (not ready for review)

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

