# Check specifications against the repository and verify implementations against specifications

GitHub Issue: https://github.com/joebew42/aido/#16

## Context

aido is built around "AI does, you decide", with one specification at the center of every stage.
Two gaps weaken that today.

Nothing explicitly checks a specification against the host repository. `/aido:1-plan` Step 3 looks
for contradictions with how the code works, but it only fixes them or asks like any other
refinement. It has no notion of a misalignment serious enough to stop for, and the small-change
route skips Step 3 altogether. Once a specification is approved, nothing notices when the default
branch moves away from it before or during implementation.

Nothing independently checks the result against the specification either. `/aido:2-implement` checks
the acceptance criteria itself, so the agent that built the change also judges it. The only other
check is an adaptation inside `/aido:4-create-pr` Step 3.7, which runs `/aido:pr-review` and adds
acceptance criteria to it. It needs that flow to run, it comes after the branch was pushed, and it
is mostly a general review, which `/code-review` in Claude Code already does for defects.

`/aido:pr-review` itself mixes the two questions, "did we build what was agreed?" and "is the code
any good?". aido should answer the first and leave the second to `/code-review`.

## Intent

- A specification that significantly conflicts with the host repository does not move forward unless
  the engineer knowingly decides it should. Intentional architectural changes stay possible.
- Implementation does not start from a specification the repository has since moved away from,
  and the check costs next to nothing when nothing relevant changed.
- A new skill, `/aido:verify`, answers one question for the current branch or any PR: does the
  implementation faithfully satisfy what was agreed? It answers with evidence, from a fresh context,
  and leaves every decision to the engineer.
- `/aido:verify` replaces `/aido:pr-review` and complements `/code-review`: "that we built what we
  agreed to build" belongs to aido, and defect discovery belongs to `/code-review`.
- Every existing human approval stays as it is.

## Out of scope

- general-purpose defect discovery in `/aido:verify`, and any change to `/code-review`
- keeping the reviewer's brief from `/aido:pr-review`: its summary, "what to review carefully"
  cards, merge recommendation and suggested inline comments go away with it
- posting anything to a PR from `/aido:verify`
- running `/aido:verify` without the engineer asking or agreeing
- changing the Acceptance Criteria Check or the Systemic Design Checkpoint in `/aido:2-implement`;
  `/aido:verify` is an independent second look, not their replacement
- an alignment check when `/aido:1-plan` enters with an already approved specification; the check
  before implementation covers that case

## Acceptance criteria

Alignment while specifying

- AC1 (manual): `/aido:1-plan` checks the draft against the host repository before asking for its
  approval as a specification: architecture and design principles, conventions and patterns,
  existing behaviour and domain assumptions, constraints and dependencies, and conflicts with
  existing functionality.
- AC2 (manual): the check applies on the full route and to a phase of a multi-phase project, and
  through `/aido:1-plan` Step 3 also in `/aido:stabilize` and `/aido:multi-phase-spec-pr`. It also
  applies on the small-change route, where a significant misalignment counts as an open decision
  and moves the change to the full route.
- AC3 (manual): a misalignment is significant when the draft contradicts the repository's agent
  instruction files, crosses an architectural boundary, or changes behaviour other code relies on.
  A lesser mismatch is handled as ordinary refinement and does not stop the flow.
- AC4 (manual): for a significant misalignment, the skill explains each conflict and its
  implications, cites the files that show it, recommends rejecting or revising the specification,
  and asks. Revising is the default, and the flow goes no further without an explicit choice.
- AC5 (manual): when the engineer chooses to proceed despite a misalignment, the decision and its
  reason are recorded in the specification, and later checks do not raise it again.

Alignment before implementation

- AC6 (manual): at the start of every `/aido:2-implement` session, before scope is confirmed, the
  skill compares what changed in the repository since the specification was approved with what the
  specification and its plan rely on. A specification from before this feature is compared in the
  same way.
- AC7 (manual): when nothing relevant changed, the check reports that in one line, without a
  subagent or a wider read of the code.
- AC8 (manual): when it finds a significant misalignment (AC3), including a constraint planning
  missed, implementation pauses and the skill behaves as AC4 describes, with the same recording as
  AC5 if the engineer proceeds. Any change to the specification needs the engineer's agreement.

The `/aido:verify` skill

- AC9 (manual): `/aido:verify` runs on the current branch, or on a PR given by number or link. No
  PR needs to exist. On a PR it checks out the branch, asking first if uncommitted changes are in
  the way. On the current branch, the report names any uncommitted changes as not verified.
- AC10 (manual): it verifies against the approved specification wherever that now is: in the
  working tree, moved into the docs, or reverted and only in the branch history. A specification
  without numbered acceptance criteria is verified by its plan, as "Specifications Without
  Acceptance Criteria" describes.
- AC11 (manual): on a PR with no specification, it verifies against the linked issue and the PR
  description, and the report says that is what it used and that it is weaker than an approved
  specification. When neither states an intent, or the current branch has no specification, it says
  there is nothing to verify against and produces no report.
- AC12 (manual): it evaluates specification compliance, implementation completeness including
  relevant edge cases, test evidence, repository alignment (the Design notes and any recorded
  misalignment decisions), and deviations from the specification.
- AC13 (manual): the report sorts every requirement as exactly one of **verified**, **insufficient
  evidence** or **unmet**, and lists **deviations** needing human attention separately: undocumented
  changes, and departures from the agreed scope or constraints. Each finding names its evidence.
- AC14 (manual): an automatable requirement is verified only by a named test that covers it and
  passed during this verification. A test that could not be run means insufficient evidence, and
  claims in `## Progress` are not evidence. A `(manual)` requirement counts as verified only when
  `## Progress` records the user's confirmation, which the report cites.
- AC15 (manual): a criterion recorded as `deferred` is listed as a deviation already decided, not as
  unmet; a `changed` criterion is checked against its current wording; a recorded misalignment
  decision is not reported as a deviation.
- AC16 (manual): verification runs in a fresh-context subagent, wherever it was started from. Where
  no subagent is available it runs in the session, and the report says it was not independent.
- AC17 (manual): `/aido:verify` changes nothing: it edits no files, makes no commits, pushes
  nothing and posts nothing. Checking out a PR's branch (AC9) is the one exception.
- AC18 (manual): `/aido:verify` reports no general code defects, and its report points to
  `/code-review` for them.

The pull request

- AC19 (manual): `/aido:4-create-pr` offers verification through `/aido:verify` before pushing the
  branch, in place of the pre-flight review. Declining continues as if nothing was offered.
- AC20 (manual): after the report, the engineer chooses to proceed or to address the findings;
  addressing them stops the skill before anything is pushed.
- AC21 (manual): each deviation the engineer acknowledges by proceeding is named in the PR
  description.

Preserved and removed

- AC22 (manual): every human approval the skills ask for today is still asked for, and no new step
  takes a decision without the engineer.
- AC23: `plugins/aido/skills/pr-review/` no longer exists, and neither the plugin nor the README
  mentions `pr-review`.
- AC24 (manual): the README and its diagrams describe the alignment checks and `/aido:verify`, and
  no longer describe a pre-flight review.
- AC25: `version` in `plugins/aido/.claude-plugin/plugin.json` is `3.0.0`, since removing a skill is
  a breaking change, and `claude plugin validate .` and `claude plugin validate ./plugins/aido`
  both pass.

## Plan

This repository is markdown, so the layers map as: guidelines hold the shared rules (domain), skills
apply them (application), and the README, diagrams and manifest face the outside (infrastructure).

1. **refactor: guideline — move reading the approved specification into `specification.md`**
   (enabling). Move the working-tree / moved / reverted lookup from `4-create-pr` Step 0 "Read the
   specification" into a subsection next to "The Specification File", and have `4-create-pr` refer
   to it. Behaviour does not change.
2. **guideline — define the alignment check** (AC3, AC4, AC5). A new `repository-alignment.md` holds
   what the check looks at, what counts as significant (pointing to "The Dependency Rule" in
   `code-standards.md` and the agent instruction files in `project-conventions.md`), and how to stop:
   explain, cite, recommend revising, ask. `specification.md` adds an optional
   `## Alignment decisions` section to "The Specification Structure", after the acceptance criteria:
   one line per decision, with the conflict and the reason.
3. **skill — check alignment in `/aido:1-plan`** (AC1, AC2, AC4, AC5, AC22). Add the check inside
   Step 3, where contradictions with the code are already looked for, before the specification is
   approved. On the small-change route, run it when choosing the route and on the rewritten draft;
   a significant misalignment goes through the existing "Moving to the full route". `/aido:stabilize`
   and `/aido:multi-phase-spec-pr` refine "as Step 3 does", so each gets one line naming the new
   guideline, because they do not load `/aido:1-plan`.
4. **skill — check alignment in `/aido:2-implement`** (AC6, AC7, AC8, AC22). Add a step between
   Step 0 and Step 1: run `git fetch origin`, then list the commits on the default branch that the
   branch does not have. Relevant means they touch files named in the specification, or an agent
   instruction file. With none, report one line and go on; with some, read those changes against
   the specification and follow the guideline. If the fetch fails, say the check could not run and
   go on.
5. **skill — add `/aido:verify`** (AC9, AC10, AC11, AC12, AC13, AC14, AC15, AC16, AC17, AC18). New
   `skills/verify/SKILL.md`: resolve the target and what to verify against, gather the diff, then
   launch one `Agent` with `model: "fable"` and a brief holding the evidence rules and the report
   format. If `fable` is unavailable or denied, use the session's model in a subagent. If no subagent
   can run, verify in the session and say it was not independent.
6. **skill — offer verification in `/aido:4-create-pr`** (AC19, AC20, AC21, AC22). Replace Step 3.7
   with an offer placed before "Step 1: Push Changes", keeping its **Proceed** / **Address findings**
   choice. Add an optional **Deviations** section and a checklist item for acknowledged deviations.
   **Not Included** keeps listing deferred criteria only.
7. **skill — remove `/aido:pr-review`** (AC23). Delete the directory; item 6 removes its only skill
   consumer.
8. **infrastructure — update the README and diagrams** (AC23, AC24). Update "Acceptance criteria are
   checked at every stage", the Utilities table, the Guidelines table and the workflow descriptions;
   change "run a pre-flight review" in `docs/human-in-the-loop.svg`, and its alt text if needed; and
   show `/aido:verify` reading the specification in `docs/spec-at-the-center.svg`.
9. **infrastructure — update the manifest** (AC25). Set `version` to `3.0.0`, reword "open and review
   PRs" in the description to match the skills, and run both validations.

AC23 and AC25 are checked by commands (`grep -rn pr-review plugins README.md`, reading `version`, and
the two validations) rather than committed tests. `tests/` covers the hook scripts only, and a test
pinning a version number would fail at the next bump.

## Design notes

- **Where it belongs:** the alignment check goes inside `/aido:1-plan` "Step 3: Refine the Draft",
  which already owns contradictions with the code, and between Step 0 and Step 1 of
  `/aido:2-implement`. What three skills share goes in guidelines, the repository's only shared
  layer. The new skill is `plugins/aido/skills/verify/SKILL.md`.
- **Existing behaviour and abstractions to reuse:**
  - `plugins/aido/skills/4-create-pr/SKILL.md` — "Read the specification", "Step 3.7" (its
    **Proceed** / **Address findings** choice, and "Judge from the diff and the tests in it, not from
    what `## Progress` claims")
  - `plugins/aido/guidelines/specification.md` — "The Specification File", "Acceptance in Progress",
    "Specifications Without Acceptance Criteria"
  - `plugins/aido/skills/2-implement/SKILL.md` — "Acceptance Criteria Check", for "name the green
    test that covers it"
  - `plugins/aido/skills/1-plan/SKILL.md` — "Moving to the full route"; "Step 5", for the `fable`
    subagent idiom and its fallback
  - `plugins/aido/skills/assess-architecture/SKILL.md` — the opening "reads the repository and never
    edits it" sentence, for AC17
  - `plugins/aido/skills/pr-review/SKILL.md` — Steps 1 and 2, for the `gh pr view`, `gh pr diff` and
    `gh pr checkout` commands and the uncommitted-changes warning
- **Boundaries that must hold:** guidelines never depend on skills; skills refer to guideline
  headings and other skills' steps by name; `${CLAUDE_PLUGIN_ROOT}` appears only inside a `SKILL.md`;
  every existing `AskUserQuestion` approval stays; the Acceptance Criteria Check and the Systemic
  Design Checkpoint do not change.
- **Other modules or consumers affected:** `4-create-pr` Step 3.7 is the only skill using
  `/aido:pr-review`; `README.md` lines 108 and 147 and `docs/human-in-the-loop.svg` line 66 also
  mention it or the pre-flight review. `stabilize` and `multi-phase-spec-pr` gain the check. Hooks and
  `tests/hooks.sh` are unaffected.
- **Enabling refactorings (planned):** item 1. Without it, `/aido:verify` would need a second copy of
  a lookup tied to the commit messages in `git-workflow.md`.
- **Deferred:** the `fable` subagent idiom is repeated in `1-plan` Step 5, `2-implement` "Before
  completion", `assess-architecture` Step 2 and `map-architecture` 2a, and `/aido:verify` makes five.
  Each is a few lines inside a different brief, so extracting it now would be abstraction over
  superficial duplication.
- **Open questions:** none block implementation. These were settled while planning:
  - **Baseline for AC6:** commits on the default branch that the branch does not have. After a rebase
    the check therefore only sees what landed since the rebase; the engineer took those changes in
    deliberately.
  - **`verified` and `met`:** both stay. `verified` is a verdict in a report, and `met` is a record
    in `## Progress`.

## Progress

- [x] 1. move reading the approved specification into `specification.md`
- [x] 2. define the alignment check
- [x] 3. check alignment in `/aido:1-plan`
- [x] 4. check alignment in `/aido:2-implement`
- [x] 5. add `/aido:verify`
- [x] 6. offer verification in `/aido:4-create-pr`
- [x] 7. remove `/aido:pr-review`
- [x] 8. update the README and diagrams
- [x] 9. update the manifest

Acceptance criteria. "Confirmed" means the user read the skill text; none of the new steps has run in
a real session yet.

- AC1–AC5: met — confirmed by the user: `repository-alignment.md`, `1-plan` Step 3 and the
  small-change route, the lines in `stabilize` and `multi-phase-spec-pr`, `specification.md`
- AC6–AC8: met — confirmed by the user: `2-implement` Step 0.5
- AC9–AC18: met — confirmed by the user: `verify/SKILL.md`
- AC19–AC22: met — confirmed by the user: `4-create-pr` Step 0.5, the Deviations section and checklist
  item
- AC23: met — `ls -d plugins/aido/skills/pr-review` fails, and
  `grep -rn pr-review plugins README.md docs` finds nothing (a command, not a committed test, as the
  plan says)
- AC24: met — confirmed by the user: `README.md` and both diagrams, rendered with headless Chromium
- AC25: met — `version` is `3.0.0`, and both `claude plugin validate` commands pass

Key decisions:

- `/aido:verify` reads linked issues from the PR description (`Closes #N`), because `gh` 2.46 rejects
  `closingIssuesReferences`; an issue linked only in GitHub's sidebar is not found
- `/aido:4-create-pr` treats **Proceed** as acknowledging every listed deviation, with no question for
  each one
- the alignment stop offers **Reject it** as a third option next to **Revise** and **Proceed anyway**
- the Verification Brief says "agreed constraints" where AC12 says "repository alignment", so that
  "alignment" keeps one meaning: a specification against the repository
- added beyond the plan: a README section on reviewing someone else's PR, the `code-review` keyword
  replaced by `verification`, and a "decide on misalignments" row in two diagram columns

The final Systemic Design Checkpoint ran; its three bounded findings were applied.

Deferred refactorings:

- the evidence standard for a criterion is stated in `plugins/aido/skills/2-implement/SKILL.md` —
  "Acceptance Criteria Check" and `plugins/aido/skills/verify/SKILL.md` — "The Verification Brief".
  Deferred because that check is out of scope here and the two serve different moments; a paragraph
  under "Acceptance in Progress" in `specification.md` could hold it when the check is next touched
- the `fable` subagent idiom is repeated in five skills (see Design notes), and
  `plugins/aido/skills/verify/SKILL.md` — "Step 3" now differs, with a third tier for when no subagent
  can run, which AC16 needs. Deferred as abstraction over superficial duplication
