---
description: Opens or updates a pull request for the current feature. Invoked when the user wants to open a pull request, create a PR, update the draft PR, or runs /aido:4-open-pr.
disable-model-invocation: false
---

# Open a Pull Request

**In Copilot CLI only:** before anything else, read `guidelines/copilot-cli.md` in the plugin root, two folders above this skill's base directory, and follow it. Read every guideline this skill names whole, with `view`, one file per call.

Open or update a draft pull request for the current feature.

Resolve `SPEC.md` and `SPEC.md.draft` first, as "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Step 0: Load Guidelines

Load these:

- `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`. It owns the **pushing** and **branch** rules
  used below
- `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md`

Check the host repository's agent instruction files for PR conventions of their own, as
`project-conventions.md` describes.

### Read the specification

Read it as "Reading the Approved Specification" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes.

Check whether it has numbered acceptance criteria, as "The Specification Structure" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. With none, skip every
acceptance-criteria step below.

## Step 0.5: Offer Verification

Before anything leaves this machine, ask with `AskUserQuestion`:

> "Should I check the implementation against the specification before pushing? `/aido:verify` starts fresh and changes nothing."

Options:
- **Verify** — run `/aido:verify` on the current branch
- **Skip** — continue at Step 0.75

After **Verify**, once the report is shown, ask with `AskUserQuestion`:

> "How should I continue after this report?"

- **Proceed** — continue at Step 0.75. Every deviation the report lists, other than deferred criteria,
  counts as acknowledged. Keep them for the **Deviations** section of the description
- **Address findings** — stop here, before anything is pushed, so the user can make changes. They can
  run `/aido:4-open-pr` again when ready

## Step 0.75: Settle the Specification

A spec left on the branch would reach the default branch with the merge. Before anything is pushed,
settle it if "When the Spec Is Settled" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` says
to ask. Otherwise continue at Step 1.

To settle it, gather the host repository's conventions as
`${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` describes, then act as "Closing the
Specification" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. Its commits go on
top of the branch, the outcome commit last. When nobody answers, or the question can't be asked, push
nothing, and stop.

## Step 1: Push Changes

A PR needs the branch on origin first. Run `git push origin BRANCH_NAME`, naming origin and the branch.
The permission prompt asks for the user's approval, as "Pushing Changes" in `git-workflow.md`
describes.

- if the user declines, stop: the PR can't be opened until the branch is pushed

## Step 2: Write PR Title

**Title Checklist (MANDATORY):**
- [ ] a descriptive, readable title
- [ ] **NO prefixes** (no `feat:`, `Phase 1:`, `#123:`, etc.)
- [ ] **NO semantic commit syntax** in the title
- [ ] clear to reviewers

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

Look for a PR template where GitHub supports one. Match the file name in any case:
- `pull_request_template.md` in `.github/`, the project root, or `docs/`
- any `.md` file in `.github/PULL_REQUEST_TEMPLATE/`. A project can offer several

If there is none, use the **Default Sections** below.

If there are templates, ask with `AskUserQuestion` before using one:
- **one template**: "This project has a PR template at `<path>`. Use it for the description?" —
  options **Use template** / **Use default format**
- **several templates**: "Which PR template should I use?" — one option per template, plus **Use
  default format**

On **Use default format**, use the **Default Sections** below.

With a template chosen:
- follow its headings and order exactly. Leave out sections that end up empty
- fill in what the diff, the commits and `SPEC.md` answer
- for checklist items or sections they can't answer, such as whether something was tested by hand,
  ask the user. Don't guess
- the PR Description Checklist below still applies. Where the template explicitly asks for something
  the checklist forbids, such as a testing section, the template wins
- for a multi-phase feature, add the Roadmap section at the end if the template has no place for it

### Default Sections

**Context** - WHY this change is needed
- describe the problem or need
- **NO bullet lists unless absolutely necessary**
- write it as a paragraph

**This PR** - WHAT changes, at a high level
- describe the approach, not each commit
- **NO detailed list of commits or files changed**
- **NO detailed technical implementation**

**Pick the format that fits the change:**
- **Narrative (paragraph)** — for a small PR, a single change, or one with a clear story. 1–4
  sentences.
- **Bullet list** — when the PR really holds 3+ distinct changes, such as a refactor, a new service
  and an index migration. One short lead-in sentence, then bullets.

**Check a narrative before using it:** read it aloud. If it strings separate changes together with
"and", "a new X also", "as a small refactor along the way" or "additionally", those are bullets
written as prose. Use a bullet list.

### Optional Sections
- **Roadmap**: if this PR is part of a multi-phase feature (see the template below)
- **Database Migration**: if the PR includes database migrations. Show the output and timing of
  applying the migration and of rolling it back, with the project's migration tool. Ask the user to
  run the commands. Run them yourself only if the project documents them for a local database
- **API Examples**: if the PR changes a public API. Show a typical request and response. For a
  **breaking** change, such as a renamed or removed field, endpoint or type, changed nullability or a
  reshaped response, show the schema fragment and a typical request **before and after**, clearly
  labelled. Reviewers and client teams then see exactly what breaks
- **Usage Examples**: if the PR adds or changes a script, task or CLI command meant to be run by hand.
  Give the complete command for each case, each with a one-line description
- **Not Included**: if `## Progress` records an acceptance criterion as `deferred`. Name each one in
  plain words, with the reason, so reviewers know what the PR leaves out on purpose. With a project
  template, add it at the end if the template has no place for it
- **Deviations**: if the user proceeded past deviations in Step 0.5. Name each one in plain words, so
  reviewers know where the PR departs from what was agreed. With a project template, add it at the end
  if the template has no place for it

### PR Description Checklist (MANDATORY)

The format rules, narrative or bullets and the Context style, apply to the Default Sections. With a
project template, apply the rest of the checklist as **Project PR Template** describes.

- [ ] **NO reference to Claude Code, and NO hard-wrapped prose**, as "Writing a GitHub Body" in
      `${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md` describes
- [ ] **This PR** is a narrative for a small, focused change, and bullets for 3+ distinct changes.
      Never bullets run together into a paragraph
- [ ] **Context** stays a paragraph: it is about the *why*
- [ ] **NO detailed list of commits**
- [ ] **NO detailed list of files changed**
- [ ] **NO information about testing or tests**
- [ ] **Follow `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md`**, so a reader quickly gets the context
      and purpose of the PR
- [ ] a follow-up PR mentions the previous PR in the Context section
- [ ] a follow-up PR includes the updated Roadmap section
- [ ] if `## Progress` records a **deferred acceptance criterion**, a **Not Included** section names
      it
- [ ] if the user **acknowledged deviations** in Step 0.5, a **Deviations** section names each one
- [ ] if `SPEC.md` has a **GitHub Issue ID**, add `Closes #NUMBER` at the bottom of the description.
      Merging into the default branch then closes the issue

## PR Templates

### Roadmap Section (Multi-Phase Features Only)

For a PR that is part of a multi-phase feature, follow `${CLAUDE_PLUGIN_ROOT}/guidelines/pr-roadmap.md`:
its rule for the Context section, and the format of the Roadmap section.

**Process:**
1. take the phase descriptions from the main feature specification or tracking PR
2. copy or adapt them, so they match the main plan
3. use technical, specific words that tell reviewers what will actually be built

## Step 3.5: Review PR Before Opening

Before opening the PR, show the draft title and description with `AskUserQuestion`:

> "Here's the PR I'm about to open:
>
> **Title:** [proposed title]
>
> **Description:**
> [proposed description]
>
> Should I change anything before opening it, and should it be a **draft** or **ready for review**?"

When the user asks for changes, show what changed, as "Showing What Changed" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, and ask again.

**Wait for the answer before opening the PR.**

## Step 4: Assign PR

After opening the PR:

- [ ] assign its author: `gh pr edit --add-assignee "@me"`
- [ ] if the host repository's agent instruction files ask for specific labels or reviewers, apply
      them as they describe. Otherwise add none

## Step 4.5: Offer Issues for Deferred Criteria

Offer to turn the deferred acceptance criteria worth keeping into issues, so they outlive the
specification. These are the criteria `## Progress` records as `deferred`.

Don't offer deferred refactorings. A refactoring is made as part of a working feature, so they were
parked as refactoring opportunities for a later plan to pull in.

With no deferred criteria, also when the specification has no numbered criteria, skip this step and
ask nothing.

Otherwise, get the PR's URL with `gh pr view --json url --jq .url`, show the criteria, and follow
`${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md` with:

- **title:** a plain-language title with no prefix
- **body:** **Observation**, holding the criterion's wording, and **Why it was deferred**, ending with
  one line linking to the PR
- **issues that do not count as a match:** the issue in the PR's `Closes #NUMBER`, if any. Merging the
  PR would close it, and the deferred criterion with it

Report each issue opened or commented on with its URL, and each skipped criterion with the reason.
Criteria not picked stay where they were recorded. Neither the specification nor the PR description
changes.

## STOP — Skill Complete

End as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, with the PR's URL
in `Done`. If the skill stops early, such as when the push is declined, end the same way.
