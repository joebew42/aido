# Evolving Guidelines

After handling a PR's review, look in its review comments for conventions worth writing down in
the host repository's own agent instruction files — its `CLAUDE.md` or `AGENTS.md`. These are the
**only** targets: the plugin's guidelines are not edited from a host repository, and the installed
plugin copy is replaced on every update.

**Proposing nothing is the normal outcome.** Most work — even large, interesting, well-executed
work — produces no new convention. A convention is a rule that will change how *future, unrelated*
work in this repository is done; a fact about the code you just wrote is not one, however
hard-won it felt. Agent instruction files are read before every task, so each addition costs
attention forever: a weak rule does not merely sit there, it dilutes the strong ones around it.
Treat "nothing to add" as success and say so in one line, rather than reaching for something to
fill a quota.

**Do not use auto-memory for this.** Any insight worth preserving belongs in the host repository's `CLAUDE.md` or `AGENTS.md` — propose it through the process below.

## Process

1. **Analyze the review comments and the fixes they led to:**
   - look for coding patterns, naming conventions, architectural decisions, or workflow improvements
     specific to this repository
   - identify practices that could benefit future work here

2. **Check what is already written down — discard anything covered:**
   - the host repository's `CLAUDE.md` and `AGENTS.md`, including nested ones
   - the plugin's guidelines in this `guidelines/` directory — the workflow already applies them in
     every repository, so restating one adds nothing
   - a rule already there in different words counts as covered — a near-duplicate is worse than
     nothing, because two phrasings of one rule invite drift between them

3. **Apply the generality test — discard anything that fails:**

   A candidate must pass **every** check below. One failure discards it; do not soften the
   wording to squeeze it through, since a rule vague enough to pass is too vague to follow.

   - **It is a rule, not a fact about the code just written.** *"Prefer an existing helper over a
     hand-rolled equivalent"* is a rule. *"`TaskService` should use `DueDateFormatter`"* is a
     fact about one file, and belongs in that code or its review, not the instruction file.
   - **It applies to a future change in a different file and a different feature.** Imagine the
     next three unrelated tasks in this repository — if it would not fire in any of them, it is not
     a convention.
   - **It is actionable by someone who never saw this PR.** If understanding it requires the
     context of this ticket, it will be unreadable in three months.
   - **It reflects a recurring pattern, not a one-off decision.** One occurrence is an anecdote,
     and a decision made once is better recorded in the code or the PR description. A candidate
     that passes every other check, but that only this PR's review shows, is not discarded: the
     user decides on it in step 5.
   - **Following it would have changed an outcome.** A rule that merely describes what you
     already did, correctly and by instinct, adds reading cost and changes nothing.

   State the result of this test honestly. If nothing passes, report that and stop — that is the
   expected result, not a failure to find something.

4. **Choose the target file for each surviving candidate:**
   - the nearest `CLAUDE.md` or `AGENTS.md` that covers the files the rule is about — a nested file
     for a rule about one subtree, the root file otherwise
   - when both exist, the one that already holds related rules
   - when neither exists, the candidate proposes creating the file the repository is more likely to
     want — `AGENTS.md` if other agent tools are used here, `CLAUDE.md` otherwise

5. **Ask about each candidate seen only in this PR**, one `AskUserQuestion` for each, at most 2:
   name the rule and its target file, with the exact text to add in the preview. Say that only this
   PR's review shows it, and ask whether to add it or look for the same point in earlier PRs —
   options **Accept it** / **Look in earlier PRs**:
   - **Accept it** → add it and commit it as step 7 describes, with no further question
   - **Look in earlier PRs** → ask how many recently merged PRs to read, with `AskUserQuestion` —
     options **5** / **10** / **20**. List them by recency with
     `gh pr list --state merged --limit <n> --json number,title`, never with `--search`, which can
     return PRs from other repositories. Read each one's review comments as "Reading a PR's Review
     Comments" below describes, and no other PR's
   - **an earlier PR makes the same point** → the candidate joins the question in step 6, and its
     description cites that PR
   - **no earlier PR makes the same point** → say so, and ask with `AskUserQuestion` — options
     **Add it anyway** / **Drop it**. Adding it commits it as step 7 describes

6. **Ask with `AskUserQuestion`:** "Which of these conventions should I add to this repository's agent instruction files?" — multi-select, one option per candidate:
   - present **at most 2**, and only those that cleared the test — zero is a valid and common
     answer; never pad to reach a number, and with zero, skip the question
   - each option names the target file, and its preview shows the exact text to add
   - each description names the check it most strongly passes

7. **Add the chosen ones:**
   - add only what the user picked, with clear, concise language and an example where helpful
   - commit each target file's change on the current branch as `docs: <what the rule covers>`,
     per `git-workflow.md`
   - never push without asking, per `git-workflow.md`

**Skip this step if:**
- the work was trivial or routine
- no new patterns or conventions emerged
- no candidate survives step 2 and the generality test in step 3

## Reading a PR's Review Comments

Read one PR's review comments with these two calls:

- `gh pr view <NUMBER> --json number,title,url,reviews,comments` — each review's summary and the
  conversation
- `gh api repos/{owner}/{repo}/pulls/<NUMBER>/comments` — the comments on lines of code. `gh`
  fills in `{owner}` and `{repo}` from the current repository
