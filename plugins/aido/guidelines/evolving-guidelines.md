# Evolving Guidelines

After handling a PR's review, look in its review comments for conventions worth writing down in the
host repository's own `CLAUDE.md` or `AGENTS.md`. These are the **only** targets: the plugin's
guidelines are not edited from a host repository, and the installed plugin copy is replaced on every
update.

**Proposing nothing is the normal outcome.** Most work, even large and well-done work, produces no
new convention. A convention is a rule that changes how *future, unrelated* work in this repository
is done. A fact about the code you just wrote is not one, however hard-won it felt. Agent instruction
files are read before every task, so each addition costs attention forever: a weak rule dilutes the
strong ones around it. Treat "nothing to add" as success, and say so in one line.

**Don't use auto-memory for this.** An insight worth keeping belongs in the host repository's
`CLAUDE.md` or `AGENTS.md`, proposed through the process below.

## Process

1. **Analyze the review comments and the fixes they led to.** Look for coding patterns, naming
   conventions, architectural decisions or workflow improvements specific to this repository, which
   could help future work here.

2. **Discard anything already written down:**
   - in the host repository's `CLAUDE.md` and `AGENTS.md`, nested ones included
   - in the plugin's guidelines in this `guidelines/` directory. The workflow already applies them in
     every repository, so restating one adds nothing
   - a rule already there in different words counts as covered. A near-duplicate is worse than
     nothing, because two phrasings of one rule drift apart

3. **Apply the generality test, and discard anything that fails.**

   A candidate must pass **every** check below. One failure discards it. Don't soften the wording to
   squeeze it through: a rule vague enough to pass is too vague to follow.

   - **It is a rule, not a fact about the code just written.** *"Prefer an existing helper over a
     hand-rolled equivalent"* is a rule. *"`TaskService` should use `DueDateFormatter`"* is a fact
     about one file, and belongs in that code or its review.
   - **It applies to a future change in a different file and a different feature.** Picture the next
     three unrelated tasks in this repository. If it wouldn't fire in any of them, it isn't a
     convention.
   - **Someone who never saw this PR can act on it.** If it needs this ticket's context, it will be
     unreadable in three months.
   - **It reflects a recurring pattern, not a one-off decision.** One occurrence is an anecdote, and
     a decision made once is better recorded in the code or the PR description. A candidate that
     passes every other check, but that only this PR's review shows, is not discarded: the user
     decides on it in step 5.
   - **Following it would have changed an outcome.** A rule that describes what you already did, by
     instinct, adds reading cost and changes nothing.

   Report the result honestly. If nothing passes, say so and stop: that is the expected result.

4. **Choose the target file for each candidate left:**
   - the nearest `CLAUDE.md` or `AGENTS.md` that covers the files the rule is about: a nested file
     for a rule about one subtree, the root file otherwise
   - when both exist, the one that already holds related rules
   - when neither exists, propose creating the one the repository more likely wants: `AGENTS.md` if
     other agent tools are used here, `CLAUDE.md` otherwise

5. **Ask about each candidate seen only in this PR**, one `AskUserQuestion` for each, at most 2.
   Name the rule and its target file, with the exact text to add in the preview. Say that only this
   PR's review shows it, and ask whether to add it or look for the same point in earlier PRs —
   options **Accept it** / **Look in earlier PRs**:
   - **Accept it** → add it and commit it as step 7 describes, with no further question
   - **Look in earlier PRs** → ask how many recently merged PRs to read, with `AskUserQuestion` —
     options **5** / **10** / **20**. List them by recency with
     `gh pr list --state merged --limit <n> --json number,title`, as "Using GitHub CLI" in
     `git-workflow.md` says. Read each one's review comments as "Reading a PR's Review Comments" in
     `git-workflow.md` describes, and no other PR's
   - **an earlier PR makes the same point** → the candidate joins the question in step 6, and its
     description cites that PR
   - **no earlier PR makes the same point** → say so, and ask with `AskUserQuestion` — options
     **Add it anyway** / **Drop it**. Adding it commits it as step 7 describes

6. **Ask with `AskUserQuestion`:** "Which of these conventions should I add to this repository's
   agent instruction files?" — multi-select, one option per candidate:
   - offer **at most 2**, and only those that passed the test. Zero is a valid and common answer:
     never pad, and with zero, skip the question
   - each option names the target file, and its preview shows the exact text to add
   - each description names the check it most strongly passes

7. **Add the chosen ones:**
   - add only what the user picked, in clear, short words, with an example where it helps
   - commit each target file's change on the current branch as `docs: <what the rule covers>`, per
     `git-workflow.md`
   - don't push: the skill that runs this process pushes afterwards, per `git-workflow.md`

**Skip this step if:**

- the work was trivial or routine
- no new patterns or conventions emerged
- no candidate survives step 2 and the generality test in step 3
