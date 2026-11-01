---
description: Creates or updates a pull request for the current feature. Invoked when the user wants to create a pull request, open a PR, update the draft PR, or runs /aiae:4-create-pr.
disable-model-invocation: false
---

# Create a Pull Request

Create or update a draft pull request for the current feature.

`SPEC.md` and `SPEC.md.draft` stand for the spec file and its draft, resolved as "The
Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes —
resolve it before reading or writing either.

## Step 0: Load Guidelines

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` — the source of truth for the **pushing** and **branch** conventions used below — and check the host repository's agent instruction files (see `project-conventions.md`) for any PR conventions of its own.

### Read the specification

`/aiae:3-organize-commits` may already have reverted `SPEC.md` or moved it into the docs, so read
it from wherever it is now:

- the spec file in the working tree, or the path it was moved to (the
  `docs: move feature specification to <path>` commit)
- otherwise, from the branch history: the content just before the
  `revert: docs: feature specification` commit — `git show <revert-sha>^:<spec-file>`

Note whether it has numbered acceptance criteria (see "The Specification Structure" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`). Without them, skip every
acceptance-criteria step below.

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
- [ ] use paragraph/narrative style, not bullet lists
- [ ] if follow-up PR: mention previous PR in Context section
- [ ] if follow-up PR: include updated Roadmap section
- [ ] if `## Progress` records a **deferred acceptance criterion**: it is named in a **Not Included** section
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

## Step 3.7: Pre-Flight Review (Optional)

Before creating the PR, use `AskUserQuestion` to ask:

> "Would you like me to run a pre-flight review on the changes before creating the PR?"

Options:
- **Yes** — run `/aiae:pr-review` on the current branch changes to flag concerns before the PR is created
- **No** — skip and proceed to create the PR

If the user says **yes**:

1. Run the `/aiae:pr-review` skill against the current branch changes
   - **Adaptation**: since no PR exists yet, use `git diff <base-branch>...HEAD` and `git log <base-branch>..HEAD` instead of `gh pr` commands for Step 1 of `/aiae:pr-review`. Skip Step 2 (already on the branch). Run all other steps as normal.
   - **Acceptance criteria**: when the specification has numbered acceptance criteria, also check the diff against each one that `## Progress` does not record as deferred. Add an **Acceptance criteria** section to the review brief listing every criterion the change does not appear to meet, with what is missing and where you looked — or one line saying all appear met. Judge from the diff and the tests in it, not from what `## Progress` claims
2. After the review brief is presented, use `AskUserQuestion` to ask:
   > "Based on this review, how would you like to proceed?"
   - **Proceed** — create the PR as-is
   - **Address findings** — stop here and let the user make changes (they can re-run `/aiae:4-create-pr` when ready)

## Step 4: Assign PR

After creating the PR:

- [ ] assign the PR author to the PR: `gh pr edit --add-assignee "@me"`
- [ ] if the host repository's agent instruction files ask for specific labels or reviewers, apply them as they describe; otherwise add none

## Step 5: Suggest Repository Conventions

After creating the PR, follow the process in `${CLAUDE_PLUGIN_ROOT}/guidelines/evolving-guidelines.md`. It only proposes additions to this repository's `CLAUDE.md` or `AGENTS.md`, chosen by the user through `AskUserQuestion`.
