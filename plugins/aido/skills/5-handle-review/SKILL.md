---
description: Handles PR review feedback by planning and implementing changes. Invoked when the user wants to handle PR review, address review comments, implement review feedback, or runs /aido:5-handle-review.
disable-model-invocation: false
---

# Handle PR Review

In Copilot CLI, resolve `${CLAUDE_PLUGIN_ROOT}` as two directories above the skill base directory,
then load `${CLAUDE_PLUGIN_ROOT}/guidelines/copilot-cli.md`.

Plan and make the changes a PR's review and comments ask for.

Resolve `SPEC.md` and `SPEC.md.draft` first, as "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Step 0: Load Context

Before any change:

- load these guidelines once:
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/tdd.md`
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/testing-principles.md`, if testing patterns matter here
- load the host repository's conventions as `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`
  describes. Its agent instruction files (`CLAUDE.md` and `AGENTS.md`) win on the topics they cover,
  and say how to test, lint and structure code in this stack
- do NOT read the guidelines again while you work: they are loaded

## Process

1. fetch the PR's reviews and comments, as "Reading a PR's Review Comments" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` describes
2. read every comment, and propose an approach for each one
3. **confirm with `AskUserQuestion` before changing anything**, and wait for explicit approval
   - Question: "Which review feedback should I implement?"
   - Options: **Approve all** / **Pick specific items** / **Cancel**
4. make each approved change, run the quality checks, then commit it on its own
5. do NOT comment on the PR. The user talks to the reviewers

## Quality Checks

Apply "Before Every Commit" in `git-workflow.md` before every commit.

## Important Conventions

- **DO NOT** change `SPEC.md` during review: it is already approved
- the branch is already pushed. Add new commits, as "Special Cases" in `git-workflow.md` describes, so
  the review changes stay visible. Rewrite history only when the user asks
- **one commit per change**: each review item gets its own commit

## Suggest Repository Conventions

Once the approved changes are committed, and before the push, follow the process in
`${CLAUDE_PLUGIN_ROOT}/guidelines/evolving-guidelines.md`. It only proposes additions to this
repository's `CLAUDE.md` or `AGENTS.md`, and the user picks them through `AskUserQuestion`. A
convention it adds is committed then, so the push carries it with the review fixes.

A review comment can show a convention the codebase follows but hasn't written down. It can also be
one reviewer's view of one file. The two look alike when you read them, so run every candidate through
the **generality test** in that process before showing anything. Most review feedback is about *this*
code and gives no convention. Expect to propose nothing.

Worth examining:
- a helper or idiom of this codebase the reviewer pointed to, such as a preferred method over a
  hand-written equivalent
- design feedback that shows an unwritten convention
- testing feedback that refines the testing strategy

Not worth examining, because it always fails the test:
- a correction that applies only to the file under review

The process decides the rest: what is already written down, and what to do with a point only this
PR's review makes.

## Push and End

- show a summary of the changes, with any convention added, then push. The permission prompt asks for
  the user's approval, as "Pushing Changes" in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`
  describes
- then end as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes
- if the user declines the push, they may want more changes. End the same way, and list in
  `Needs you` every commit left unpushed, a convention's included
