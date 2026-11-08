---
description: Handles PR review feedback by planning and implementing changes. Invoked when the user wants to handle PR review, address review comments, implement review feedback, or runs /aido:5-handle-review.
disable-model-invocation: false
---

# Handle PR Review

Plan and implement changes based on PR review and comments.

`SPEC.md` and `SPEC.md.draft` stand for the spec file and its draft: resolve them first, per "The
Specification File" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Step 0: Load Context

Before any implementation work:

- load the global guideline files once:
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md`
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/testing-principles.md`, if testing patterns are relevant
- load the host repository's conventions as described in `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`
  — its agent instruction files (`CLAUDE.md` and `AGENTS.md`) are authoritative on the topics
  they cover, and they tell you how to test, lint and structure code in this stack
- do NOT re-read guideline files during implementation — they are already loaded

## Process

1. fetch the reviews and comments from the PR, as "Reading a PR's Review Comments" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/evolving-guidelines.md` describes
2. do an analysis of all comments and present a proposed approach for each one
3. **use `AskUserQuestion` to confirm before implementing anything** — wait for explicit approval
   - Question: "Which review feedback should I implement?"
   - Options: **Approve all** / **Pick specific items** / **Cancel**
4. implement each approved change, run quality checks, then commit separately
5. do NOT add comments to the PR - the user will handle communication with reviewers

## Quality Checks

Apply "Before Every Commit" in `git-workflow.md` before every commit.

## Important Conventions

- **DO NOT** modify `SPEC.md` during review (spec is already approved)
- **DO NOT** reorganize/rebase/squash commits (branch is already pushed)
- **Only append new commits** - let review changes be visible for transparency
- Only rewrite history if explicitly requested by user
- **Create one commit per change** - each review feedback item should result in a separate commit
- Follow git commit conventions from the loaded `git-workflow.md`

## Suggest Repository Conventions

Once the approved changes are committed, and before the push, follow the process in `${CLAUDE_PLUGIN_ROOT}/guidelines/evolving-guidelines.md`. It only proposes additions to this repository's `CLAUDE.md` or `AGENTS.md`, chosen by the user through `AskUserQuestion`. A convention it adds is committed then, so the push carries it with the review fixes.

Review comments can reveal conventions the codebase holds but hasn't written down. They can also be one reviewer's take on one file — the two look alike at the moment you read them, so run every candidate through the **generality test** in that process before presenting anything. Most review feedback is about *this* code and produces no convention; expect to propose nothing.

Worth examining:
- a codebase-specific helper or idiom the reviewer pointed to (e.g. a preferred method over a manual equivalent)
- architectural or design feedback that reveals an undocumented convention
- testing feedback that refines the testing strategy

Not worth examining — these fail the test by construction:
- a correction that applies only to the file under review
- a stylistic preference stated once, by one reviewer, without a codebase-wide rationale
- anything already covered by the repository's `CLAUDE.md` or `AGENTS.md`, or by a loaded guideline, however differently the reviewer phrased it

## Push and End

- show a summary of the changes made, with any convention added, then push; per "Pushing Changes"
  in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`, the permission prompt asks for the user's
  approval
- then end as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes
- if the user declines the push, they may want to make more changes. End the same way, and list in
  `Needs you` every commit left unpushed, a convention's included
