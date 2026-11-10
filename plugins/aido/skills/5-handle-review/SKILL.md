---
description: Handles PR review feedback one comment at a time — fixes the comments the user chooses, replies on the PR to the rest and parks some in GitHub issues. Invoked when the user wants to handle PR review, address review comments, implement review feedback, or runs /aido:5-handle-review.
disable-model-invocation: false
---

# Handle PR Review

**In Copilot CLI only:** before anything else, read `guidelines/copilot-cli.md` in the plugin root, two folders above this skill's base directory, and follow it. Read every guideline this skill names whole, with `view`, one file per call.

Go through a PR's review feedback one comment at a time. Fix it, answer that it is out of scope, or
park it in a GitHub issue.

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
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`, to settle the spec before the push
  - `${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md`, to park comments in issues and write replies
- load the host repository's conventions as `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`
  describes. Its agent instruction files (`CLAUDE.md` and `AGENTS.md`) win on the topics they cover,
  and say how to test, lint and structure code in this stack
- do NOT read the guidelines again while you work: they are loaded

## Process

1. fetch the PR's reviews and comments, as "Reading a PR's Review Comments" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` describes. A thread of line comments counts as
   one comment: the one that starts it, with the replies after it
2. **triage every comment before asking about any.** Read each one with the code it points to, and
   choose what it needs:
   - **Should fix** — it asks for a change that belongs in this PR. Note the change in a line
   - **Out of scope** — what it asks for doesn't belong in this PR, or the code already answers it.
     Draft a short reply that says why
   - **Park** — worth doing, but not in this PR. Draft the issue's title, and a short reply saying it
     is tracked in an issue
   - **nothing asked** — such as praise or a thank-you

   Replies follow "Writing a GitHub Body" in `${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md`.
3. say in one line each which comments ask for nothing. They get no question
4. **ask about one comment at a time**, as "One Item at a Time" in
   `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes. The question names the comment's author
   and where it is, such as the file and line or the review's summary, and sums it up in a sentence.
   Ask with options **Should fix** / **Out of scope** / **Park**, with the triage's choice
   recommended:
   - **Should fix** — its description says briefly what you will change
   - **Out of scope** — its preview shows the draft reply
   - **Park** — its preview shows the issue's title and the draft reply

   Choosing **Out of scope** or **Park** approves the reply shown. When the user types their own
   answer, such as a different reply, take it as that comment's decision.
5. **Nothing is changed, opened or posted until every comment is decided.** When nobody answers, or a
   question can't be asked, stop there. Change, open and post nothing, and end as "Push and End"
   describes, with nothing to push
6. once every comment is decided, act on the decisions in this order:
   1. make each **Should fix** change, run the quality checks, then commit it on its own
   2. open an issue for each parked comment. Get the comment's URL, then start at "Check for
      Duplicates" in `${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md`, with:
      - **title:** the title the user saw, with no prefix
      - **body:** **Observation**, holding the comment's point, and **Why it was parked**, ending
        with one line linking to the comment
      - **issues that do not count as a match:** the issue in the PR's `Closes #NUMBER`, if any
   3. post the reply for each **Out of scope** and **Park** comment, as "Replying to Review Feedback"
      in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` describes. A parked comment's reply links
      the issue opened, or the existing issue the duplicate check found

   A comment you fix gets no reply: the user talks to the reviewer about it. Report each issue opened
   or commented on, and each reply posted, with its URL.

## Quality Checks

Apply "Before Every Commit" in `git-workflow.md` before every commit.

## Important Conventions

- **DO NOT** change what the spec says during review: it is already approved. Settling it, below,
  is the only change to the file
- the branch is already pushed. Add new commits, as "Special Cases" in `git-workflow.md` describes, so
  the review changes stay visible. Rewrite history only when the user asks
- **one commit per change**: each review item gets its own commit

## Suggest Repository Conventions

Once the fixes are committed, and before the push, follow the process in
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

## Settle the Specification

Once the review commits and any convention are committed, and before the push, settle the spec if
"When the Spec Is Settled" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` says to ask.

To settle it, act as "Closing the Specification" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. Its commits go on top of the review
commits, the outcome commit last. When nobody answers, or the question can't be asked, push nothing,
and end as below, listing the unpushed commits.

## Push and End

- show a summary of the changes, with the replies posted, the issues opened, any convention added
  and how the spec was settled, then push. The permission prompt asks for the user's approval,
  as "Pushing Changes" in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md` describes
- then end as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes
- if the user declines the push, they may want more changes. End the same way, and list in
  `Needs you` every commit left unpushed, a convention's included
