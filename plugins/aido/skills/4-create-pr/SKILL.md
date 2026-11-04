---
description: Creates or updates a pull request for the current feature. Invoked when the user wants to create a pull request, open a PR, update the draft PR, or runs /aido:4-create-pr.
disable-model-invocation: false
---

# Create a Pull Request

Create or update a draft pull request for the current feature.

`SPEC.md` and `SPEC.md.draft` stand for the spec file and its draft: resolve them first, per "The
Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`.

## Step 0: Load Guidelines

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` — the source of truth for the **pushing** and **branch** conventions used below — `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` and `${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md`, and check the host repository's agent instruction files (see `project-conventions.md`) for any PR conventions of its own.

### Read the specification

Read it as "Reading the Approved Specification" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes: `/aido:3-organize-commits` may
already have reverted it or moved it into the docs.

Note whether it has numbered acceptance criteria (see "The Specification Structure" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`). Without them, skip every
acceptance-criteria step below.

## Step 0.5: Offer Verification

Before anything leaves this machine, use `AskUserQuestion` to ask:

> "Would you like to verify the implementation against the specification before pushing? `/aido:verify` runs from a fresh context and changes nothing."

Options:
- **Verify** — run `/aido:verify` on the current branch
- **Skip** — continue at Step 1

After **Verify**, once the report is shown, use `AskUserQuestion` to ask:

> "Based on this report, how would you like to proceed?"

- **Proceed** — continue at Step 1. Every item the report lists under its deviations, other than deferred criteria, counts as acknowledged: keep them for the **Deviations** section of the description
- **Address findings** — stop here, before anything is pushed, and let the user make changes (they can re-run `/aido:4-create-pr` when ready)

## Step 1: Push Changes

A PR needs the branch on origin first. Per `git-workflow.md`, **never push automatically** — confirm with `AskUserQuestion`:

> "Ready to push `BRANCH_NAME` to origin so I can open the PR?"
>
> Options: **Push** / **Cancel**

- on **Push**: run `git push origin BRANCH_NAME` (set origin and branch explicitly)
- on **Cancel**: stop — the PR can't be created until the branch is pushed

## Step 2: Write PR Title

**Title Checklist (MANDATORY):**
- [ ] use a descriptive, readable title
- [ ] **NO prefixes** (no `feat:`, `Phase 1:`, `#123:`, etc.)
- [ ] **NO semantic commit syntax** in title
- [ ] keep it clear and understandable for reviewers

**Correct titles:**
```
Let users share a TODO list
Support filtering tasks by due date
Improve performance of task search
```

**INCORRECT titles (DO NOT DO THIS):**
```
feat: Let users share a TODO list      ← Wrong: semantic prefix
Phase 1: Shared lists                  ← Wrong: phase prefix
#123: Let users share a TODO list      ← Wrong: issue prefix
issue-123-feat-shared-lists           ← Wrong: branch name as title
```

## Step 3: Write PR Description

### Project PR Template

Look for a PR template in the locations GitHub supports, matching the file name case-insensitively:
- `pull_request_template.md` in `.github/`, the project root, or `docs/`
- any `.md` file in `.github/PULL_REQUEST_TEMPLATE/` (a project can offer several)

If none is found, use the **Default Sections** below.

If templates are found, ask with `AskUserQuestion` before using one:
- **one template**: "This project has a PR template at `<path>`. Use it for the description?" — options **Use template** / **Use default format**
- **several templates**: "Which PR template should I use?" — one option per template, plus **Use default format**

On **Use default format**, use the **Default Sections** below.

When a template is chosen:
- follow its headings and order exactly, and omit sections that end up empty
- fill in what the diff, the commits and `SPEC.md` answer
- for checklist items or sections those can't answer (e.g. whether something was tested manually), ask the user rather than guessing
- the PR Description Checklist below still applies, except where the template explicitly asks for something it forbids (e.g. a testing section) — then the template wins
- for a multi-phase feature, add the Roadmap section at the end if the template has no place for it

### Default Sections

**Context** - high-level description of WHY this change is needed
- keep it descriptive and concise
- focus on the problem or need being addressed
- **NO bullet lists unless absolutely necessary**
- use narrative/paragraph style

**This PR** - high-level description of WHAT changes are introduced
- keep it descriptive and concise
- focus on the solution approach, not commit-by-commit details
- **NO detailed list of commits or files changed**
- **NO detailed technical implementation**

**Pick the format that fits the change:**
- **Narrative (paragraph)** — preferred when the PR is small, focused on a single change, or has a clear story to tell. 1–4 sentences flowing together.
- **Bullet list** — preferred when the PR genuinely contains 3+ distinct changes (e.g. a refactor + a new service + an index migration). Use a brief lead-in sentence, then bullets.

**Smell test before committing to narrative:** read it aloud. If the prose strings independent changes with "and", "a new X also", "as a small refactor along the way", or "additionally" — that's inlined bullets. Switch to a bullet list.

### Optional Sections
- **Roadmap**: if this PR is part of a multi-phase feature (see template below)
- **Database Migration**: if the PR includes database migrations — the output and timing of applying the migration and of rolling it back, using the project's migration tool. Ask the user to run the commands, or run them yourself only if the project documents them for a local database
- **API Examples**: if the PR changes a public API — a representative request and response. For a **breaking** change (renamed or removed field, endpoint or type, changed nullability, reshaped response), show the schema fragment and a representative request **before and after**, clearly labelled, so reviewers and client teams can see exactly what breaks
- **Usage Examples**: if the PR adds or changes a script, task or CLI command meant to be run by hand — the complete command for each case, each with a one-line description
- **Not Included**: if `## Progress` records an acceptance criterion as `deferred` — each deferred criterion in plain words, with the reason, so reviewers know what the PR deliberately leaves out. With a project template, add it at the end if the template has no place for it
- **Deviations**: if the user proceeded past deviations in Step 0.5 — each one in plain words, so reviewers know where the PR departs from what was agreed. With a project template, add it at the end if the template has no place for it

### PR Description Checklist (MANDATORY)

The format rules (narrative vs. bullets, Context style) apply to the Default Sections. With a project template, apply the rest of the checklist as described in **Project PR Template**.

- [ ] **NO reference to Claude Code**
- [ ] **This PR** uses narrative for small/focused changes; bullets when there are 3+ distinct changes — never inline bullets as a run-on paragraph
- [ ] **Context** stays in narrative/paragraph style (it's about the *why*)
- [ ] **NO detailed list of commits**
- [ ] **NO detailed list of files changed**
- [ ] **NO information about testing or tests**
- [ ] **DO NOT hard-wrap prose** — in PR/issue bodies GitHub renders a single newline as a line break, so fixed-column wrapping makes the rendered text choppy and stops it reflowing. One line per paragraph. (Code blocks and lists exempt.)
- [ ] **Use less verbose and less convoluted language** — a reader should get the context and the purpose of the PR quickly, without unpacking long or complicated sentences
- [ ] keep tone descriptive and concise
- [ ] if follow-up PR: mention previous PR in Context section
- [ ] if follow-up PR: include updated Roadmap section
- [ ] if `## Progress` records a **deferred acceptance criterion**: it is named in a **Not Included** section
- [ ] if the user **acknowledged deviations** in Step 0.5: each is named in a **Deviations** section
- [ ] if a **GitHub Issue ID** is present in `SPEC.md`: add `Closes #NUMBER` at the bottom of the PR description to auto-close the issue when merged into the default branch

## PR Templates

### Roadmap Section (Multi-Phase Features Only)

For a PR that is part of a multi-phase feature, follow `${CLAUDE_PLUGIN_ROOT}/guidelines/pr-roadmap.md`: its rule for the Context section, and the format of the Roadmap section.

**Process:**
1. Reference the main feature specification or tracking PR for phase descriptions
2. Copy or adapt phase descriptions from the main plan to ensure consistency
3. Use technical, specific language that tells reviewers what will actually be implemented

## Step 3.5: Review PR Before Creating

Before creating the PR, use `AskUserQuestion` to present the draft title and description to the user:

> "Here's the PR I'm about to create:
>
> **Title:** [proposed title]
>
> **Description:**
> [proposed description]
>
> Would you like to adjust anything before I create it? Also, should this be a **draft** or **ready for review**?"

**Wait for the user's response before creating the PR.**

## Step 4: Assign PR

After creating the PR:

- [ ] assign the PR author to the PR: `gh pr edit --add-assignee "@me"`
- [ ] if the host repository's agent instruction files ask for specific labels or reviewers, apply them as they describe; otherwise add none

## Step 4.5: Offer Issues for Deferred Criteria

Offer to turn the deferred acceptance criteria worth keeping into issues, so they outlive the specification. These are the criteria `## Progress` records as `deferred`.

Deferred refactorings are not offered: a refactoring is made as part of a working feature, so they were parked as refactoring opportunities for a later plan to pull in.

With no deferred criteria, including when the specification has no numbered criteria, skip this step without asking anything.

Otherwise, get the PR's URL with `gh pr view --json url --jq .url`, show the criteria, and follow `${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md` with:

- **title:** a plain-language title with no prefix
- **body:** **Observation**, holding the criterion's wording, and **Why it was deferred**, ending with one line linking to the PR
- **issues that do not count as a match:** the issue in the PR's `Closes #NUMBER`, if any, because merging the PR would close it and the deferred criterion with it

Report each issue opened or commented on with its URL, and each skipped criterion with the reason. Criteria not picked stay where they were recorded, and neither the specification nor the PR description changes.

## Step 5: Suggest Repository Conventions

After creating the PR, follow the process in `${CLAUDE_PLUGIN_ROOT}/guidelines/evolving-guidelines.md`. It only proposes additions to this repository's `CLAUDE.md` or `AGENTS.md`, chosen by the user through `AskUserQuestion`.
