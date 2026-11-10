---
description: Creates the main specification and tracking draft PR for a multi-phase feature. Invoked when the user wants to create a spec PR, create the main tracking PR, set up a multi-phase feature, or runs /aido:multi-phase-spec-pr.
disable-model-invocation: false
---

# Create Multi-Phase Specification PR

**In Copilot CLI only:** before anything else, read `guidelines/copilot-cli.md` in the plugin root, two folders above this skill's base directory, and follow it. Read every guideline this skill names whole, with `view`, one file per call.

Create a draft PR that holds the main specification of a multi-phase feature and tracks its progress.

Resolve `SPEC.md` and `SPEC.md.draft` first, as "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`, `${CLAUDE_PLUGIN_ROOT}/guidelines/pr-roadmap.md`
and `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Purpose

- this PR stays a draft for the whole time the feature is built
- it keeps the feature's overall specification and its state in one place
- it is the one place to track progress across the phase PRs

## Prerequisites

### Review and Refine Feature Spec

The specification lives in `SPEC.md`, and its draft in `SPEC.md.draft`, as "The Specification
File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. On a leftover spec, stop
before anything below, as "A Leftover Spec" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
describes. Otherwise:

- **only `SPEC.md.draft` exists** → have the user approve it as "Approve the draft" in
  `${CLAUDE_PLUGIN_ROOT}/skills/1-plan/SKILL.md` describes. Then refine it as
  `${CLAUDE_PLUGIN_ROOT}/guidelines/refining-a-draft.md` describes, with numbered acceptance criteria
  for the whole feature, and don't ask about the enabling refactoring analysis. Then move it with
  `mv SPEC.md.draft SPEC.md`
- **neither exists** → ask the user to write `SPEC.md.draft`, then go on as above

**BEFORE creating the multi-phase PR, review and finish the `SPEC.md` file.**

Common refinements:
- **Documentation**: remove temporary analysis files that won't be committed
- **References**: keep only PRs and existing docs, and remove temporary files

### Get the GitHub Issue (Optional)

**Ask whether a GitHub issue tracks this feature, unless you already have it.** If there is one, it
is used for:
- Branch naming
- Feature spec header

### Review Feature Spec and Propose Implementation Plan

**BEFORE creating the branch, review `SPEC.md` and propose a realistic implementation plan.**

Steps:
1. read `SPEC.md` thoroughly
2. explore the codebase as far as you need to understand its structure and the relevant code
3. propose a plan in phases, with:
   - a short summary of the feature and its goals
   - the phases, one PR each, described as outcomes, not implementation details
   - the acceptance criteria each phase delivers, by ID. Every criterion is delivered by at least
     one phase
   - any risks, dependencies or open questions worth raising

**Wait for explicit approval of the plan before going on.** Once approved, write the phases into
`SPEC.md` as its `## Plan`, each naming the criteria it delivers, as "Plan Items" in "The
Specification Structure" describes. `/aido:1-plan` reads them to carry each phase's criteria into its
phase draft.

The user may ask for changes, such as merging, splitting or reordering phases. Repeat until it is
approved.

### Create Main Plan Branch

**AFTER the user approves the plan, make sure you are on a branch with the main plan name.**

Branch naming pattern: `issue-NUMBER-main-plan-FEATURE_NAME`, or `main-plan-FEATURE_NAME` when there
is no issue, as **Branch Naming** in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` describes.

### Add the GitHub Issue to Feature Spec

If there is a GitHub issue, add its `GitHub Issue:` line to `SPEC.md`, where "The Specification
Structure" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` shows it.

## Step 1: Commit the Feature Specification

Commit it as a `docs` commit with the exact message `docs: feature specification`, as
`git-workflow.md` describes.

## Step 2: Push Changes

Run `git push origin BRANCH_NAME`. The permission prompt asks for the user's approval, as "Pushing
Changes" in `git-workflow.md` describes.

- if the user declines, stop: the PR needs the branch on origin

## Step 3: Create Draft PR

Create a draft PR with these sections:

### Required Sections
Write each section as `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes.

- **Context**: the change we want to make, described at a high level, not in technical detail
- **This PR**: what this PR adds, described at a high level, not in technical detail
- **Roadmap**: every step the following PRs will build
  - every item starts unchecked (`- [ ]`), since no phase is built yet
  - keep items high-level, about outcomes
  - leave out implementation details, such as refactorings, backfills or specific classes
  - say what changes, not how
  - follow the format rules in `pr-roadmap.md`
  - Example: ✅ "Let tasks repeat daily, weekly or monthly"
  - Example: ❌ "Let tasks repeat daily, weekly or monthly, refactor TaskFinder to use a request object, and backfill a recurrence rule on existing tasks"
- **Link to `SPEC.md`**: a link to the feature specification at the top of the description

### PR Guidelines Checklist
- [ ] no reference to Claude
- [ ] no prefix in the title, such as an issue number or a semantic commit type
- [ ] a descriptive title instead
- [ ] created as a draft PR, not ready for review

Once the PR is created, or the skill stops early, end as "Ending a Skill" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, with the PR's URL in `Done`.

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
