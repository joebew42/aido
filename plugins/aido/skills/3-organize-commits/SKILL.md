---
description: Organizes the commit history into a clean, logical structure. Invoked when the user wants to organize commits, clean up commit history, reorder commits, or runs /aido:3-organize-commits.
disable-model-invocation: false
---

# Organize the Commits

**In Copilot CLI only:** before anything else, read `guidelines/copilot-cli.md` in the plugin root, two folders above this skill's base directory, and follow it. Read every guideline this skill names whole, with `view`, one file per call.

Turn the branch's commits into a clean, logical history that follows the project's conventions.

Resolve `SPEC.md` and `SPEC.draft.md` first, as "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Step 0: Load Guidelines

Before you touch any commit, load:

- `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`. Follow **every** commit convention in it
- `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`. Then gather the host repository's
  conventions as it describes. Step 1 needs them to place `SPEC.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`

Do NOT skip this step.

## Step 1: Decide What Happens to `SPEC.md`

Skip this step unless "When the Spec Is Settled" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
says to ask.

Before you propose the commit structure, settle the spec as "Closing the Specification" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes. Its commits close the structure
below, the outcome commit last.

## Commit Organization Rules

`git-workflow.md` defines every rule for organizing commits. This skill **applies** them to the
existing history. Its "Before Every Commit" gate applies to every commit made here, with the one
exception for this skill that it describes. The tests run once, at the end, as "Run the Tests Once"
describes. The very last commit is the outcome commit chosen in Step 1.

This skill owns **final history shaping**: the order, the splits and the outcome commit.
`/aido:2-implement` made the working commits, one per unit.

### Follow What Was Actually Built

"Shape by Mode" in `git-workflow.md` shapes each part by its mode. Take the mode from the first of
these that has one, reading the specification as "Reading the Approved Specification" in
`specification.md` describes:

1. `## Progress`: a mode change and the slices built, as "Modes and Slices in Progress" in
   `specification.md` describes
2. the plan: the mode the item names, and its slices
3. otherwise inside-out, for a branch with no plan, specification or mode

## History Management

- history that isn't pushed may be reset and reorganized. Once commits are pushed, add new ones, as
  "Special Cases" in `git-workflow.md` describes
- a push or force push follows "Pushing Changes" in `git-workflow.md`. Say first when the push would
  rewrite history

## Step 2: Propose Commit Structure Before Reorganizing

Before any rebase or history rewrite, read the current commits. Then show the proposed grouping with
`AskUserQuestion`:

> "Here's how I plan to reorganize the commits:
> 1. `docs: feature specification` (first)
> 2. `feat: ...` (grouped by class/module with tests)
> 3. for an outside-in part, each slice in turn: its commits inside-out, then its acceptance test
> 4. ...
> N. the outcome commit (last, as chosen in Step 1), after the distilled doc if the user chose one
>
> Is this grouping approved?"

Options: **Approve the grouping** / **Adjust it**. On **Adjust it**, ask what to change, update the
proposal, show what changed as "Showing What Changed" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, and ask again.

In the same `AskUserQuestion` call, offer the next step, as "Asking Questions" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes. The answer counts only when the grouping is
approved. "Hand Off" acts on it:

> "Once the commits are organized, should I open the pull request?"

Options: **Open the PR in a fresh context** (recommended) / **Open the PR** / **Stop here**.

Read `## Progress` first, as "Acceptance in Progress" in `specification.md` describes. The question
names each criterion recorded as `unchecked` or `deferred`, so the user notices it before going on.
Always mark **Open the PR in a fresh context** as recommended, whatever `## Progress` says. This skill
organizes the commits; whether the plan is finished is not its call.

When `/aido:resolve-migration-conflict` runs this skill, make no offer. Ask only about the grouping,
and return to its "Wrap Up" once the commits are organized.

**Wait for approval before the rebase.** A rebase is destructive and hard to undo.

## Run the Tests Once

Once the new history is settled, run the relevant tests on the final commit, as the exception in
"Before Every Commit" in `git-workflow.md` describes. That section also says which tests are
relevant. This is the only test run this skill makes.

When it passes, check the Final Checklist, then hand off as the user chose, with no further test run.

When it fails, fix the commit that broke it, so every commit stays sound, as "History Management"
allows:

- **the history is not pushed** → find the first commit where the run fails, fix it there, and
  rebuild the commits after it. To find it, run the same tests on earlier commits, for example with
  `git bisect run`, taking the default branch as passing. Each rebuilt commit keeps the gate above
- **the commits are already pushed** → add a fix commit instead of rewriting history. It goes before
  the outcome commit when that one isn't pushed yet

Then run the relevant tests again, once, on the final commit. When the same tests also fail on the
default branch, the failure isn't this branch's: fix nothing, and tell the user. When the run still
can't pass, stop. Tell the user which commit fails and why: the Final Checklist doesn't hold.

## Final Checklist

Once the commits are organized, check ALL of these:

- [ ] the docs commit message is EXACTLY "docs: feature specification" (if docs present)
- [ ] the last commit is the outcome commit chosen in Step 1, as "Closing the Specification" in
      `specification.md` names it (if Step 1 ran)
- [ ] no draft is left in the working tree, under either name: `SPEC.draft.md` or `SPEC.md.draft`
- [ ] the docs commit is the FIRST commit in history (if docs present)
- [ ] every commit message follows "Commit Message Format" in `git-workflow.md`
- [ ] the order and grouping follow "Commit Organization Strategy" in `git-workflow.md`, with each
      part shaped by the mode "Follow What Was Actually Built" gives it
- [ ] "Before Every Commit" in `git-workflow.md` holds for every commit, apart from its test run
- [ ] the relevant tests passed in the one run "Run the Tests Once" describes

## Hand Off

Go on as the user chose in Step 2, without asking again:

- **Open the PR** → once the Final Checklist holds, start `/aido:4-open-pr`, as **Hand-off
  Outcomes** in `git-workflow.md` describes. Its verification offer, the push approval and the review
  of the PR all still happen. If the checklist can't hold, tell the user why
- **Open the PR in a fresh context** → once the Final Checklist holds, act as **Hand-off Outcomes** in
  `git-workflow.md` describes. If the checklist can't hold, tell the user why
- **Stop here**, or no answer → as **Hand-off Outcomes** in `git-workflow.md` describes

Then end as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes. When
`/aido:resolve-migration-conflict` started this skill, add no block.
