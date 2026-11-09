# Handle review comments and design findings one at a time

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

GitHub Issue: https://github.com/joebew42/aido/#74

## Context

`/aido:5-handle-review` reads every review comment, proposes an approach for each, and asks once to
approve them all or pick some. The user approves the comments as a whole, instead of reasoning about
each one. The design steps do the same with their findings: planning offers its refactorings in a
list, and the final design review asks about all its findings together.

## Intent

The agent triages the review comments, then goes through them one at a time. For each, it shows a
short summary and asks whether to fix it, call it out of scope, or park it in a GitHub issue, and
recommends one. A comment that isn't fixed gets a short reply on the PR, posted only once the user
approves its text, and its thread is resolved. Design findings, in planning and in implementing, are
asked about one at a time too, with their existing choices and a recommended one.

## Out of scope

- replying to or resolving the threads of comments that are fixed
- applying each fix as soon as it is decided
- keeping the triage's state, so an interrupted session can resume it
- opening GitHub issues for design findings: they are still saved locally, as today
- changing how review comments are fetched

## Acceptance criteria

Review comments

- AC1: When `/aido:5-handle-review` starts, it triages every review comment before asking about any.
- AC2: When the triage is done, the agent asks about one comment at a time, showing a short summary.
- AC3: When asking about a comment, the options are Should fix, Out of scope and Park, with the
  triage's choice marked recommended.
- AC4: The Should fix option briefly describes the change the agent will make.
- AC5: When a comment asks for nothing, such as praise, the agent says so in one line and asks nothing.
- AC6: When comments are still undecided, no code is changed, no issue is opened and nothing is posted.
- AC7: When every comment is decided, each Should fix change is made and committed on its own.
- AC8: When a comment is Out of scope, the agent posts a short reply, then resolves its thread.
- AC9: When a comment is parked, the agent opens a GitHub issue, checking for duplicates first, then
  posts a reply linking it and resolves the thread.
- AC10: When a comment's options include a reply, its draft is shown, and choosing the option
  approves it. Nothing is posted until every comment is decided.
- AC15: When feedback marked Out of scope or Park has no thread, such as a review's summary, the
  reply is posted as a PR comment.

Design findings

- AC11: When the enabling refactoring analysis in `/aido:1-plan` returns findings, the agent asks
  about one finding at a time: Plan it first, Defer or No action, recommending one.
- AC12: When saved refactoring ideas fit a planned change, `/aido:1-plan` asks about one idea at a
  time, recommending whether to include it.
- AC13: When the design check in `/aido:2-implement` asks about a finding, it recommends one of its
  choices.
- AC14: When the final design review returns findings, the agent asks about one finding at a time,
  recommending a choice.
- AC16: When the analysis in `/aido:1-plan` classes a finding as no action, it is listed in one line,
  with no question.

## Plan

1. **refactor: let a skill open an issue for a point the user already chose** (enabling) — domain.
   In `github-issues.md`, "Pick the Issues" applies only when the skill hasn't already asked. Such a
   skill starts at "Check for Duplicates". `/aido:4-open-pr` Step 4.5 keeps its pick step.
2. **refactor: make "Writing a GitHub Body" cover comments and replies** (enabling) — domain.
   Widen its scope line in `github-issues.md`. The heading stays: `/aido:4-open-pr` refers to it.
3. **ask about one item at a time** (AC2, AC3, AC11, AC12, AC14) — inside-out: follows **Picking from
   a list** in "Asking Questions" in `language.md`. Touches domain.
   - a new heading there, so skills can refer to it: one question per item, naming the item, one
     option marked recommended with a short reason
   - it says this is the exception to "interrupted once per stage". Joined questions stay joined
4. **ask about a design finding** (AC11, AC12, AC13, AC14, AC16) — inside-out: follows **Showing a
   finding** and **Classify every finding** in `systemic-refactoring.md`. Touches domain.
   - a new `**Asking about a finding:**` label: one finding per question, shown as one line, with the
     options the skill names
   - the option matching the finding's class is recommended. A low-confidence finding recommends only
     Defer or No action
   - a saved idea recommends including it when it fits and still holds
   - findings classed no action are listed in one line, with no question
5. **reply to review feedback and resolve its thread** (AC8, AC9, AC15) — outside-in: the calls that
   find a thread's ID and resolve it are unconfirmed here. Touches infrastructure.
   - a new section next to "Reading a PR's Review Comments" in `git-workflow.md`
   - slice 1: reply to a line comment, then look up its thread and resolve it
   - slice 2: reply to feedback with no thread as a PR comment, quoting it
   - the reply follows "Writing a GitHub Body" in `github-issues.md`
6. **`/aido:5-handle-review` goes through the comments one at a time** (AC1–AC10, AC15) —
   inside-out: follows the per-item question in step 5 of `evolving-guidelines.md`, and how
   `/aido:4-open-pr` Step 4.5 hands points to `github-issues.md`. Touches application.
   - Step 0 loads `github-issues.md`
   - `## Process`: fetch, triage, then one question per comment. Should fix describes the change. Out
     of scope and Park show the draft reply. Feedback that asks for nothing gets one line
   - once all are decided: each fix in its own commit, then the issues from "Check for Duplicates",
     then the replies. A reply links the issue opened, or the existing one the duplicate check found
   - "do NOT comment on the PR" goes. The phrases and section order `tests/skills.sh` pins stay
   - the skill's `description` and the README's rows for it mention the replies and issues
7. **the design steps ask one finding at a time** (AC11, AC12, AC13, AC14, AC16) — inside-out:
   follows "The final design review" in `/aido:2-implement`, which already marks a recommended option.
   Touches application.
   - `/aido:1-plan`: a question after Step 5, before Step 6, with **Plan it first** / **Defer** /
     **No action**. Step 5.5 asks about one idea at a time, instead of picking from a list
   - `/aido:2-implement`: the design check recommends one option, and the final design review asks
     one finding at a time. The recommendation is a separate sentence, so the option lists
     `tests/skills.sh` pins stay
   - "Child Mode" returns which option is recommended, so loop mode keeps it
8. **free checks, evals and version** (AC2, AC3) — inside-out: follows the case
   `handle-review-suggests-nothing`. Touches infrastructure.
   - `tests/skills.sh` pins the skills' pointers to the new sections
   - the two handle-review eval prompts answer "fix every comment" instead of "approve all"
   - a new eval case: given three comments, the agent asks about them one at a time and recommends
     an option, with a row in `docs/evals.md`. The design-finding questions get no new case, and the
     PR says so
   - bump `version` in `plugin.json` to `5.10.0`

## Design notes

- **Where it belongs:** the review flow in `plugins/aido/skills/5-handle-review/SKILL.md` —
  `## Process`. Replying and resolving in `plugins/aido/guidelines/git-workflow.md`, next to "Reading
  a PR's Review Comments". Opening a parked comment's issue in
  `plugins/aido/guidelines/github-issues.md`. The one-at-a-time rule in "Asking Questions" in
  `plugins/aido/guidelines/language.md`. The rule for findings in
  `plugins/aido/guidelines/systemic-refactoring.md`, beside **Showing a finding**.
- **Existing behaviour and abstractions to reuse:**
  - `plugins/aido/guidelines/github-issues.md` — "Check for Duplicates", "Open the Issues", "Writing a
    GitHub Body"
  - `plugins/aido/guidelines/git-workflow.md` — "Reading a PR's Review Comments", "Special Cases"
  - `plugins/aido/guidelines/language.md` — "Asking Questions", **Picking from a list**
  - `plugins/aido/guidelines/systemic-refactoring.md` — **Showing a finding**, **Classify every
    finding**, **Parking an opportunity**
  - `plugins/aido/guidelines/evolving-guidelines.md` — step 5, one question per item
  - `plugins/aido/skills/2-implement/SKILL.md` — "The final design review", its recommended option
  - `plugins/aido/skills/4-open-pr/SKILL.md` — "Step 4.5: Offer Issues for Deferred Criteria"
- **Boundaries that must hold:**
  - guidelines refer to each other by file name, never into a skill (`tests/skills.sh` — "no
    guideline points into a skill for a rule")
  - a referenced name must be a heading or a `**Name:**` label (`tests/skills.sh` —
    `section_exists`). `**Picking from a list.**` can't be referenced, so the new rule gets a heading
  - only `git-workflow.md` quotes `--search` in backticks, and only `github-issues.md` says why bodies
    aren't hard-wrapped
  - the push hook asks only before `git push`. Posting, resolving and opening issues rely on the
    skill's own question
  - `AskUserQuestion` takes at most four options: a recommendation marks an existing option
  - design findings stay local, never GitHub issues
  - `5-handle-review` keeps its section order and the phrases `tests/skills.sh` and
    `tests/test_skills.py` pin
- **Other modules or consumers affected:**
  - `tests/skills.sh` — the option lists pinned for `2-implement`
  - `plugins/aido/evals/handle-review-suggests-nothing/prompt.md`,
    `plugins/aido/evals/handle-review-asks-about-a-convention-seen-once/prompt.md` — "approve all"
  - `plugins/aido/evals/implement-review-records-refactorings/prompt.md` — still reads correctly
  - `plugins/aido/skills/1-plan/SKILL.md` — "Small-Change Route" runs Step 5.5, so it asks the same way
  - `README.md` — the rows for `/aido:5-handle-review`
- **Enabling refactorings (planned):**
  - Let a skill open an issue for a point the user already chose, so a parked comment isn't asked
    about twice. Where: `plugins/aido/guidelines/github-issues.md` — "Pick the Issues",
    `plugins/aido/skills/4-open-pr/SKILL.md` — "Step 4.5". Confidence: high. Risk: `/aido:4-open-pr`
    must keep its pick step
  - Make "Writing a GitHub Body" cover comments and replies, so replies follow the same rules without
    repeating them. Where: `plugins/aido/guidelines/github-issues.md` — "Writing a GitHub Body".
    Confidence: high. Risk: none, the heading stays
- **Deferred:**
  - Make the free check for the final design review's options look at that section alone, since its
    phrase is the tail of the design check's and passes on it. Where: `tests/skills.sh` — the option
    lists pinned for `2-implement`. Confidence: high. Risk: a stricter phrase can fail on harmless
    rewording
- **Open questions:** none.

## Refactorings

### r1. Scope "Asking about a finding" to the skills that ask one at a time

- **Change:** Open **Asking about a finding** with its scope, as "One Item at a Time" does: "When a skill says to ask about findings one at a time…".
- **Why:** The label has no condition, but `/aido:assess-architecture` loads the same guideline and asks about its findings as one list. The two contradict each other, and the specification meant only planning and implementing.
- **Where:**
  - `plugins/aido/guidelines/systemic-refactoring.md` — **Asking about a finding:**
  - `plugins/aido/skills/assess-architecture/SKILL.md` — "Step 4: Park the Opportunities"
  - `plugins/aido/guidelines/language.md` — "One Item at a Time"
- **Confidence:** medium — an agent may already let the skill's explicit step win, so the conflict may never show.
- **Risk:** none for `/aido:1-plan` and `/aido:2-implement`. `tests/skills.sh` pins the label and two of its sentences.

### r2. Let each skill say which of its options matches each finding class

- **Change:** Each skill names which of its options matches each class. The guideline keeps only "the option matching the finding's class is recommended, and a low-confidence finding never recommends building or planning it".
- **Why:** In the design check, both **Refactor now** and **Plan it for later** match "the one that builds or plans it". The saved-idea question (**Include it** / **Leave it saved**) has no **Defer** or **No action**. The low-confidence sentence also restates **Classify every finding**.
- **Where:**
  - `plugins/aido/guidelines/systemic-refactoring.md` — **Asking about a finding:**, second and third bullets
  - `plugins/aido/guidelines/systemic-refactoring.md` — **Classify every finding:**
  - `plugins/aido/skills/2-implement/SKILL.md` — "The design check, during TDD", item 4
  - `plugins/aido/skills/1-plan/SKILL.md` — "Step 5.5: Pull In Parked Refactoring Opportunities"
- **Confidence:** medium — an agent can still infer a sensible option, so the gap may cost little.
- **Risk:** the pins for "A low-confidence finding recommends only **Defer** or **No action**" and "Recommend one, as **Asking about a finding**…" change with the text.

### r3. Confirm every finding planning asks about

- **Change:** In `/aido:1-plan` Step 5, confirm every finding that gets a question, or confirm one when the user chooses **Plan it first**.
- **Why:** Step 5 now confirms only findings classed enabling, then asks about enabling and defer findings alike. A deferred finding answered with **Plan it first** becomes a plan item without being checked against the code, which **Evidence before action** asks for.
- **Where:**
  - `plugins/aido/skills/1-plan/SKILL.md` — "Step 5: Look for Enabling Refactorings"
  - `plugins/aido/guidelines/systemic-refactoring.md` — **Evidence before action:**
- **Confidence:** medium — whether the narrower wording was intended isn't recorded.
- **Risk:** a little more reading during planning. No pin covers this sentence.

## Progress

- [x] 1. refactor: let a skill open an issue for a point the user already chose
  - "Pick the Issues" in `github-issues.md`: a skill that already asked starts at "Check for Duplicates"
- [x] 2. refactor: make "Writing a GitHub Body" cover comments and replies
- [x] 3. ask about one item at a time
  - "One Item at a Time" in `language.md`: one question per item, one option recommended with a reason
- [x] 4. ask about a design finding
  - **Asking about a finding:** in `systemic-refactoring.md`: one finding per question, the option matching its class recommended, no-action findings listed in one line
- [x] 5. reply to review feedback and resolve its thread
  - "Replying to Review Feedback" in `git-workflow.md`
  - Item 5 slices built: reply to a line comment, then find its thread and resolve it; reply to feedback with no thread as a PR comment, quoting it
  - the thread lookup was run read-only against a past PR. Posting a reply and resolving a thread were checked against the API schema only, as the user chose
- [x] 6. `/aido:5-handle-review` goes through the comments one at a time
  - `## Process`: fetch, triage, one question per comment, then fixes, issues and replies in that order
  - a thread of line comments counts as one comment
  - a parked comment's issue uses **Observation** and **Why it was parked**, like the deferred criteria in `/aido:4-open-pr`
- [x] 7. the design steps ask one finding at a time
  - `/aido:1-plan` Step 5 asks **Plan it first** / **Defer** / **No action** per finding; Step 5.5 asks **Include it** / **Leave it saved** per idea
  - `/aido:2-implement`: the design check recommends one option; the final design review asks per finding; a child returns its recommended option
- [x] 8. free checks, evals and version
  - `tests/skills.sh` pins each new section and the pointers to it, added before the text in each item
  - new eval case `handle-review-asks-one-comment-at-a-time`, with the shell check `changes-nothing`; the design-finding questions get no new case
  - version 5.10.0
- [x] r1. Scope "Asking about a finding" to the skills that ask one at a time
  - **Asking about a finding:** in `systemic-refactoring.md`: applies only when a skill asks one at a time; a skill that picks from a list keeps its list
- [x] r2. Let each skill say which of its options matches each finding class
  - **Asking about a finding:** in `systemic-refactoring.md`: the skill names the option matching each class; a low-confidence finding never recommends building or planning it
  - `/aido:1-plan` Steps 5 and 5.5, and both design steps in `/aido:2-implement`: each names its matching option
  - `/aido:1-plan` Step 5.5: recommends **Include it**, unless the idea is broader or riskier than the change
- [x] r3. Confirm every finding planning asks about
  - `/aido:1-plan` Step 5: confirms findings classed enabling or defer, not only enabling
- the README tagline now says "spec-first" instead of "spec-driven", at the user's request
- "One Item at a Time" in `language.md` also says what to do without the question tool: ask about the first undecided item only, as text, and stop. Added after the first eval run listed every comment at once
- one-run eval checks (nothing recorded): `handle-review-asks-one-comment-at-a-time` passed `changes-nothing` with aido. On the rerun after the fix, the agent asked about comment 1 of 3 with one option recommended, but the run was flagged invalid because its Bash calls exited with code 2. `handle-review-asks-about-a-convention-seen-once` failed `asks-to-accept-or-look` both on this branch and on `main`, so this branch didn't cause it. The next full round should look at it
- the Design notes' **Deferred** finding no longer holds: the pinned phrase starts with `options **Plan it for later**`, which only the final review's step has. Its parked file was removed
- the final design review ran and recorded r1, r2, r3

### Acceptance

- AC1: met — `tests/skills.sh` pins "triage every comment before asking about any"; the first eval run triaged all three comments before asking
- AC2: met — `tests/skills.sh` pins the "One Item at a Time" pointer and its no-tool rule; the eval rerun asked about comment 1 of 3 only (run flagged invalid)
- AC3: met — `tests/skills.sh` pins "options **Should fix** / **Out of scope** / **Park**, with the triage's choice recommended"
- AC4: met — the **Should fix** option's description says the change, in `5-handle-review` step 4, alongside the pinned option list
- AC5: met — `5-handle-review` step 3; the first eval run said the praise asked for nothing, in one line
- AC6: met — `tests/skills.sh` pins "Nothing is changed, opened or posted until every comment is decided"; eval check `changes-nothing` passed with aido
- AC7: met — `5-handle-review` step 6.1, one commit per **Should fix** change
- AC8: met — `tests/skills.sh` pins "Replying to Review Feedback" and `resolveReviewThread`; the thread lookup ran against a past PR, and posting and resolving were checked against the API schema only
- AC9: met — `tests/skills.sh` pins the "Check for Duplicates" pointer in `5-handle-review`; the reply links the issue opened or found
- AC10: met — `5-handle-review` step 4: the draft is in the option's preview, and choosing it approves it; the pin from AC6 covers posting
- AC11: met — `tests/skills.sh` pins "options **Plan it first** / **Defer** / **No action**" and the **Asking about a finding** pointer in `1-plan`
- AC12: met — `tests/skills.sh` pins "options **Include it** / **Leave it saved**"
- AC13: met — `tests/skills.sh` pins "Recommend one, as **Asking about a finding**…" in `2-implement`
- AC14: met — `tests/skills.sh` pins the one-finding-at-a-time pointer in the final design review
- AC15: met — `tests/skills.sh` pins `gh pr comment <NUMBER> --body-file <file>` in "Replying to Review Feedback"
- AC16: met — `tests/skills.sh` pins "a finding classed no action is listed in one line, with no question"; `1-plan` Step 5 says the same
