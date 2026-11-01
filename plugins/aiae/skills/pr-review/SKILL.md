---
description: Reviews a pull request from a reviewer's perspective, providing a summary, highlighting important changes, flagging concerns, and assessing safety. Invoked when the user wants to review a PR, understand what a PR changes, or runs /aiae:pr-review.
disable-model-invocation: false
---

# PR Review

Produce a structured review brief to help a reviewer quickly understand, focus, and assess a pull request.

## Step 1: Fetch PR Data

Given the PR URL or number, fetch using `gh`:

```
gh pr view <number> --json title,body,commits,files,additions,deletions,baseRefName,headRefName
gh pr diff <number>
```

Also fetch the commit list with messages:
```
gh pr view <number> --json commits --jq '.commits[].messageHeadline'
```

## Step 2: Switch to the PR Branch Locally

Check out the PR branch locally so the reviewer can navigate the code in their editor:

```
gh pr checkout <number>
```

This fetches the remote branch and switches to it. If there are uncommitted local changes that would conflict, warn the user before proceeding.

## Step 3: Load Context

Load the global guideline files:

- `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/testing-principles.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`
- `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`

Then gather the host repository's conventions as `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md` describes — its agent instruction files (`CLAUDE.md` and `AGENTS.md`), including nested ones in the directories the PR touches. Review the PR against both; where they disagree, the repository wins.

Read every file listed above. Do NOT skip any, and do NOT re-read them later in the process.

## Step 4: Produce the Review Brief

The brief has **four required sections** plus optional one-liners. Keep it tight — the whole brief should fit on one screen if possible. Avoid restating the same concern in multiple sections; each point belongs in one place.

Output sections in this order:

1. **Summary** (required)
2. **What to review carefully** (required)
3. **Recommendation** (required)
4. **[Pause]** — ask the reviewer how deep they want suggested comments to go (see "Ask comment depth" below). Do not draft comments before this question is answered.
5. **Suggested comments** (required, but may be empty), scoped to the chosen depth.

Optional one-liners that go between Summary and What to review, only if relevant:

- **Commit note** — one line, only if the commit history is messy (mixed concerns, vague messages, out-of-order). Skip otherwise.
- **Test gap** — one line, only if test coverage has a real gap that affects review. Skip otherwise.

---

### Summary

Write an **outcome-focused** summary, not a technical change log. The goal is to help the reviewer understand *why this PR exists and what it changes for users / the product*, before diving into the code.

Structure:

1. **Lead with the user or product motivation** (1–2 sentences). What problem is this solving for end users, customers or internal teams? Why does this matter? Use plain language — name concrete examples ("tasks like 'Pay rent' or 'Renew passport' that are due today") instead of abstract terminology.
2. **Describe what this PR does to move toward that outcome** (2–4 short bullets or sentences). Frame each piece by *what it accomplishes*, not by which files or classes change. For example: "Reminds users of tasks due today" rather than "Adds `ReminderScheduler.enqueue` to `Task.save`".
3. **End with caveats that affect how to read the PR** (1–3 bullets). Things like: follow-up work the author has signalled, limits of the rollout, operational risks worth confirming, scope that was deliberately deferred.

Keep it skimmable — short paragraphs and bullets, not a wall of text. Avoid heavy jargon (class names, method names, database column names) in this section; that detail belongs in **What to review carefully** below. The reviewer should be able to read just this section and explain to a teammate why the PR exists.

---

### What to review carefully

List the focus areas that genuinely need careful attention — no numeric cap. Each focus area is a standalone block (not a nested list item): the file path as a bold line, then a 4-item sub-list with the labels *Flow / Change / Check / Risk*. Separate cards with a blank line so the markdown renders real padding between them.

**Triage rule:** before adding a focus area, ask whether a reviewer could verify it in ~30 seconds by reading the diff alone. If yes, drop it — there's nothing for them to focus on here, and a card would just be noise. A focus area earns its place only when the change has non-local consequences, hidden risk, or surrounding context the diff doesn't reveal. Bias toward fewer cards; if you can't articulate a concrete *Check* and *Risk*, the area doesn't belong here.

**Verify each card before listing it.** Every claim in *Flow / Change / Check / Risk* must be grounded in the actual code, not inferred from the diff or guessed from file names. For each candidate card:

1. **Read the actual source file** at the referenced lines (the branch is already checked out from Step 2), and read surrounding code needed to understand the flow.
2. **Confirm the *Flow* description matches reality** — that the callers, data path, and downstream consumers you describe actually exist. If you can't locate them, either fix the description or drop the card.
3. **Confirm the *Change* is part of this PR's diff** — not pre-existing code shown only as context.
4. **Confirm the *Check* is actionable on the current code** — the method, field, configuration, or invariant the reviewer is asked to inspect must actually exist in the branch.
5. **Confirm the *Risk* is real** — trace at least one concrete path by which the described failure could occur. If the risk is purely hypothetical or contradicted by the code (e.g., a guard already exists, the call site is gone), drop or rewrite the card.

Discard any card that fails verification. Do not list speculative concerns. If verification reveals a different, real concern in the same area, rewrite the card around that concern instead of the original guess.

Format (note the blank line between cards — this is what gives the visual breathing room):

```
**`path/to/file.ext`** (line range if relevant)
- *Flow:* What this code does in the larger picture — who calls it, what it produces, where the data lives.
- *Change:* What this PR does to that flow (1 sentence, do not restate the whole diff).
- *Check:* The specific things the reviewer should verify (the actual review work).
- *Risk:* Blast radius / downstream impact / why this focus area made the list.

**`path/to/other_file.ext`**
- *Flow:* …
- *Change:* …
- *Check:* …
- *Risk:* …
```

Rules for keeping cards scannable:

- Each sub-bullet is one sentence — short, factual, no filler. If a bullet wants two sentences, cut to one.
- Always render all four sub-bullets in the same order (Flow, Change, Check, Risk), even when a row is one short phrase.
- Use backtick-quoted identifiers for class/method/file/field names so they stand out.
- Don't add extra sub-bullets beyond the four (no "Context", "Notes", "Background", "Tests").
- Each card is a top-level block — do not nest cards inside an outer `- ` bullet, because markdown collapses spacing inside a list.
- One blank line between cards. No horizontal rules or extra separators.

Skip boilerplate, generated files, trivial column-add migrations, and changes already obvious from the diff. This is the only "where to look" section — do not repeat focus areas elsewhere. If a concern is small enough to fit inside a suggested comment, prefer the comment.

Example:

**`src/tasks/task_serializer.ext:42–58`**
- *Flow:* Turns each task into the payload the web and mobile apps sync to show a user's TODO list.
- *Change:* `due_at` is now sent as a date only, and the separate `due_time` field is removed.
- *Check:* Whether released mobile versions still read `due_time`, and the rollout order between the API and the apps.
- *Risk:* Largest risk in the PR — older apps would drop the due time of every task until users update.

**`src/tasks/reminders.ext:10–25`**
- *Flow:* …
- *Change:* …
- *Check:* …
- *Risk:* …

---

### Recommendation

One verdict, one sentence on why, one sentence on what to verify (omit the "verify" sentence if the verdict is "Safe to merge without review").

Pick exactly one:

- **Safe to merge without review** — mechanical, low-blast-radius, or fully covered by tests/types. Examples: dependency bumps, copy-only changes, generated files, isolated internal refactors with green CI and no behavior change.
- **Quick review** — small surface, low risk, but worth a second pair of eyes. Examples: small feature additions behind a flag, isolated bugfixes with a regression test, narrow refactors that touch one call site.
- **Careful review** — touches shared code paths or modifies existing behavior in non-trivial ways. Default for most feature work.
- **Block until concerns resolved** — has open questions, missing rollout plan, or operational risks the reviewer should answer before merging. Examples: schema changes without a migration plan, API or wire-format changes without backward-compat handling, anything touching auth/permissions/billing without explicit confirmation.

**Bias toward asking for review when uncertain.** "Safe to merge without review" is a strong claim — only use it when the change is genuinely low-stakes and self-evidently correct. When in doubt, downgrade to "Quick review."

Format:

> **Recommendation: \<verdict\>** — \<one sentence on why\>. \<one sentence on what to verify, if applicable\>.

---

### Ask comment depth

After printing Summary, any optional one-liners, What to review carefully, and Recommendation — and **before drafting any suggested comments** — call `AskUserQuestion` to let the reviewer pick how deep the comments should go. This way the brief's high-level picture informs their choice, and you scope the drafting effort to what they actually want.

Use these three options (in this order; mark the second as Recommended):

- **Critical only** — only things that could cause real issues if merged: potential bugs, missing tests for non-trivial paths, performance regressions, breaking changes, security concerns, operational/rollout risks.
- **Critical + standards** (Recommended) — the above, plus convention violations, structural concerns (including Dependency Rule violations and domain logic living in infrastructure — see "Architecture" in `code-standards.md`), dead/unused code, and inconsistencies that will cause confusion later.
- **Everything** — also includes style nitpicks: naming, comment quality, formatting suggestions, micro-refactors.

Include every verified finding that fits the chosen category — no numeric cap. The category itself is the filter; do not pad to a target count, and do not drop a legitimate finding because there are "already enough" comments.

Use `header: "Comment depth"` on the question. Wait for the answer before drafting.

---

### Suggested comments

Draft candidate inline comments at the depth the reviewer chose. If "Critical only", omit anything that is purely a convention/style/dead-code concern. If "Critical + standards", include those but still omit nitpicks. If "Everything", include all verified findings.

For each candidate:
- quote the relevant file and line range
- write the comment as if the reviewer is writing it (first person, constructive tone)
- focus on things that matter at the chosen depth

**Formatting by chosen depth:**

- **Critical only** — list comments without category headers; they're all the same priority.
- **Critical + standards** — group comments under two headers:
  - `**🔴 Critical** — could cause real issues if merged`
  - `**🟡 Standards** — convention violations, structural concerns, latent inconsistencies`
  - Omit a header if its group is empty.
- **Everything** — group comments under three headers:
  - `**🔴 Critical** — could cause real issues if merged`
  - `**🟡 Standards** — convention violations, structural concerns, latent inconsistencies`
  - `**🟢 Style** — nitpicks`
  - Omit a header if its group is empty.

Within each group, comments use the same `> **\`path\` (line N)**` block format. Do not add per-comment priority labels — the group header is the label.

**Before presenting any comment, verify it.** For each candidate comment:

1. **Read the actual source file** at the referenced lines (the branch is already checked out from Step 2).
2. **Confirm the issue exists in the current code** — if the code doesn't match what you assumed from the diff, discard the comment.
3. **Confirm the issue is part of the diff** — only comment on lines that were added or modified in this PR, not on pre-existing code that was merely included as diff context.
4. **Confirm the suggestion is a valid improvement** — verify the suggested change would actually work (e.g., the method/class/variable you reference exists, the alternative approach is compatible with the surrounding code).

Discard any comment that fails verification. Do not mention discarded comments to the user.

Format each verified comment as:

> **`path/to/file.ext` (line N)**
> Your comment text here.

Present all verified comments, then ask the user:

> These are suggested comments only. Which ones (if any) would you like to post? You can also edit them before posting.

**Wait for the user's response before posting anything.** Do not post comments automatically.

If the user approves comments (all or a subset), post them as **inline comments** using the GitHub REST API:

```
gh api repos/<owner>/<repo>/pulls/<number>/comments \
  --method POST \
  --field commit_id="<head-sha>" \
  --field path="<file-path>" \
  --field position=<diff-position> \
  --field body="<comment-text>"
```

To find the correct `position` for each comment, parse the PR diff (from `gh pr diff`) and count lines from the start of each file's diff hunk — position 1 is the first `@@` line, and increments by 1 for every line after that (including context lines, added lines, and removed lines, but not the `diff --git`, `---`, or `+++` header lines). The `commit_id` is the PR's head SHA (from `gh api repos/<owner>/<repo>/pulls/<number> --jq '.head.sha'`).

Never use `gh pr review --comment` for suggested review comments — that posts to the general PR comment thread, not inline on the code.

---

## Output Format

Present the brief as clean markdown with section headers. Keep each section concise — the goal is to save the reviewer time, not to exhaustively describe every line. Use bullet points where a list reads more clearly than prose.

After the full brief, present the suggested comments and wait for the user to decide what to post.
