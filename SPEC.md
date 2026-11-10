# Suggesting a change in the host repository's AGENTS.md should give more options

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

GitHub Issue: https://github.com/joebew42/aido/issues/97

## Context

After handling a PR's review, `/aido:5-handle-review` may suggest adding a convention to the host
repository's `CLAUDE.md` or `AGENTS.md`. When only this PR's review shows the convention, the
question offers just **Accept it** or **Look in earlier PRs**. The user has no direct way to decline
it, or to keep it for later.

## Intent

The question about a convention seen only in this PR's review also offers **Ignore it** and **Park
it**. Ignoring leaves the file unchanged. Parking opens a GitHub issue with the proposed change, the
way `/aido:5-handle-review` already parks review comments. Declining reads the same everywhere: the
follow-up's **Drop it** becomes **Ignore it**.

## Out of scope

- adding Park to the follow-up after an earlier-PR search finds nothing
- adding Park to the question about conventions seen in several PRs
- remembering an ignored convention, so it isn't suggested again

## Acceptance criteria

- AC1: When a convention is seen only in this PR's review, its question offers Accept it, Look in
  earlier PRs, Ignore it and Park it.
- AC2: When the user picks Ignore it, nothing is added to the instruction file, and nothing more is
  asked about that convention.
- AC3: When the user picks Park it, a GitHub issue is opened, after the usual duplicate check, and
  nothing is added to the instruction file.
- AC4: A parked convention's issue holds the exact text to add, its target file, the PR whose review
  showed it, and why it was parked.
- AC5: When an earlier-PR search finds nothing, the follow-up offers Add it anyway and Ignore it.
- AC6: The end-of-review summary lists each issue opened for a parked convention.

## Plan

1. **refactor: state once that the issue a PR closes is never a duplicate** (enabling) — guidelines,
   skills
   - `github-issues.md` says it: when the points come from a PR, the issue in its `Closes #NUMBER`
     never counts as a match, because merging the PR closes it
   - `/aido:4-open-pr` Step 4.5 and `/aido:5-handle-review` step 6.2 drop their own copy of the rule
2. **Ignore it and Park it for a convention seen in one PR** (AC1, AC2, AC3, AC4, AC5) — inside-out:
   follows how `/aido:5-handle-review` step 6.2 parks a comment through "Check for Duplicates" in
   `github-issues.md`. Touches `evolving-guidelines.md` step 5
   - the question offers **Accept it** / **Look in earlier PRs** / **Ignore it** / **Park it**, with
     none recommended, as today
   - **Ignore it** adds nothing and asks nothing more
   - **Park it** gets the PR's URL with `gh pr view --json url --jq .url`, then starts at "Check for
     Duplicates" in `github-issues.md`, with a plain title naming the rule, and a body holding the
     exact text, the target file, why it was parked (only this PR's review shows it, so it is kept
     for later) and a last line linking to the PR. No label. The issue is opened at once
   - the follow-up's **Drop it** becomes **Ignore it**
3. **list parked conventions in the end summary** (AC6) — inside-out: follows "Report each issue
   opened or commented on" in `/aido:5-handle-review` step 6. Touches `5-handle-review/SKILL.md`
   `## Push and End`
4. **check the four options in the eval** (AC1) — inside-out: follows
   `handle-review-asks-about-a-convention-seen-once/graders/asks-to-accept-or-look.md`. Touches the
   grader, the case's description and its row in `docs/evals.md`. Park itself isn't covered: the
   fixture has no GitHub access. The PR says so

## Design notes

- **Where it belongs:** `plugins/aido/guidelines/evolving-guidelines.md` — `## Process` step 5 owns
  the question and its options. `plugins/aido/skills/5-handle-review/SKILL.md` — `## Push and End`
  owns the summary.
- **Existing behaviour and abstractions to reuse:** `plugins/aido/guidelines/github-issues.md` —
  "Check for Duplicates", "Open the Issues", "Writing a GitHub Body". `5-handle-review/SKILL.md` Step
  0 already loads it, and is the only skill that runs `evolving-guidelines.md`.
  `plugins/aido/skills/4-open-pr/SKILL.md` — Step 4.5 shows how to get the PR's URL.
- **Boundaries that must hold:** a guideline never points into a skill, and every
  `"Section" in `file.md`` reference must exist (`tests/skills.sh`). No bullet in the body template
  may start `- **Observation` or `- **Why it matters` (`tests/skills.sh` — `old_fields`). The host's
  `CLAUDE.md` and `AGENTS.md` stay the only files the process edits: parking commits nothing. Four
  options is the most `AskUserQuestion` takes. Bump `version` in
  `plugins/aido/.claude-plugin/plugin.json` from `5.10.0` to `5.11.0`, run `tests/all.sh`, and show
  the question and the issue body before and after in the PR description.
- **Other modules or consumers affected:** `/aido:4-open-pr` Step 4.5, by item 1.
  `plugins/aido/evals/handle-review-checks.sh` — `commits_no_convention` still holds.
- **Enabling refactorings (planned):** item 1.
  - **Change:** move the rule that the issue in the PR's `Closes #NUMBER` never counts as a match
    into `github-issues.md`. The callers stop restating it.
  - **Why:** two skills state it today, and only one gives the reason. Parking a convention would be
    a third copy, so a change to the rule would touch three files.
  - **Where:** `plugins/aido/guidelines/github-issues.md` — the intro list and "Check for
    Duplicates"; `plugins/aido/skills/5-handle-review/SKILL.md` — `## Process` step 6.2;
    `plugins/aido/skills/4-open-pr/SKILL.md` — Step 4.5
  - **Confidence:** medium. `github-issues.md` takes this list from its caller, so the repetition
    may have been on purpose.
  - **Risk:** it changes `/aido:4-open-pr`, which this feature doesn't otherwise touch. A caller
    with no PR must still work.
- **Deferred:** none.
- **Open questions:** none. Behaviour change: propose one run of the `handle-review-*` eval cases,
  and ask first.

## Refactorings

### r1. Say once that the result of the duplicate check is reported

- **Change:** move "report each issue opened or commented on, with its URL" into `github-issues.md`,
  under "Open the Issues". The callers keep only what they add, such as the skipped criteria in
  `/aido:4-open-pr`. The summary in "Push and End" then covers a parked convention whose issue was
  commented on or skipped, not only opened.
- **Why:** `/aido:4-open-pr` and `/aido:5-handle-review` each state the rule, and Park it in
  `evolving-guidelines.md` doesn't. When a parked convention's duplicate check ends in a comment or a
  skip, nothing reports it.
- **Where:**
  - `plugins/aido/guidelines/github-issues.md` — "Open the Issues"
  - `plugins/aido/guidelines/evolving-guidelines.md` — `## Process` step 5, **Park it**
  - `plugins/aido/skills/5-handle-review/SKILL.md` — `## Process` step 6 and `## Push and End`
  - `plugins/aido/skills/4-open-pr/SKILL.md` — Step 4.5
  - `tests/skills.sh` — the phrase `the issues opened, each issue opened for a parked convention`
- **Confidence:** medium. AC6 asks only for issues opened, so leaving out a comment or a skip may be
  on purpose.
- **Risk:** it touches `/aido:4-open-pr` again, and the pinned phrase in `tests/skills.sh` changes
  with the summary line.

## Progress

- [x] 1. refactor: state once that the issue a PR closes is never a duplicate
  - `github-issues.md` "Check for Duplicates" holds the rule. `/aido:4-open-pr` Step 4.5 and
    `/aido:5-handle-review` step 6.2 no longer pass it
  - `tests/skills.sh` checks that only `github-issues.md` says which issues don't count as a match
- [x] 2. Ignore it and Park it for a convention seen in one PR
  - `evolving-guidelines.md` step 5 offers the four options, none recommended. Parking opens the issue
    at once, through "Check for Duplicates" in `github-issues.md`, with no label
  - the follow-up after an empty earlier-PR search offers **Add it anyway** / **Ignore it**
  - `tests/skills.sh` checks each option's wording, the issue body, and that **Drop it** is gone
- [x] 3. list parked conventions in the end summary
  - `/aido:5-handle-review` "Push and End" lists each issue opened for a parked convention
- [x] 4. check the four options in the eval
  - the grader is now `asks-to-accept-look-ignore-or-park.md`. The case's description and its row in
    `docs/evals.md` name the four options. Parking itself isn't covered by an eval: the fixture has
    no GitHub access
- Decided: the plugin goes to `5.12.0`, since `main` already took `5.11.0`
- AC1 needed one more change: in the evals, the question was never asked properly when the question
  tool was missing. Step 5 now says to ask it as text, with the four options, and push nothing until
  the user answers
- Item 4: the 3-run comparison against `main` is recorded in `docs/evals.md`
- the final design review ran and recorded r1
- [x] r1. Say once that the result of the duplicate check is reported
  - `github-issues.md` has a new last step, "Report the Result": each issue opened or commented on,
    with its URL, and each point skipped, with the issue it duplicates. It is its own section, not
    part of "Open the Issues", because a skipped point never reaches that section
  - `/aido:4-open-pr` Step 4.5 and `/aido:5-handle-review` step 6 point to it. The review summary
    names the issue opened, commented on or skipped for each parked comment and convention
  - `evolving-guidelines.md` is unchanged: **Park it** already goes through `github-issues.md`
  - `tests/skills.sh` checks that only `github-issues.md` states the rule

### Acceptance

- AC1: met — `evolving-guidelines.md keeps: options **Accept it** / **Look in earlier PRs** / **Ignore it** / **Park it**, with none recommended` in `tests/skills.sh`. In the eval, the one run that proposed the convention asked with all four options. The other two discarded it earlier, at step 2, as `main` does
- AC2: met — `evolving-guidelines.md keeps: **Ignore it** → add nothing, and ask nothing more about it`
- AC3: met — `evolving-guidelines.md keeps: **Park it** → open an issue for it at once, and add nothing`, and the check that it starts at "Check for Duplicates"
- AC4: met — `evolving-guidelines.md keeps: **body:** the target file, the exact text to add, and **Why it was parked** … End with one line linking to the PR`
- AC5: met — `evolving-guidelines.md keeps: options **Add it anyway** / **Ignore it**`, and `declining a convention reads Ignore it everywhere`
- AC6: met — `5-handle-review/SKILL.md keeps: the replies posted, the issue opened, commented on or skipped for each parked comment and each parked convention, any convention added`
