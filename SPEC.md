# Offer to open issues for deferred points when creating a PR

GitHub Issue: https://github.com/joebew42/aido/issues/21

## Context

A feature's specification records points the work deliberately leaves for later: `/aido:2-implement`
records deferred refactorings and deferred acceptance criteria in `## Progress`, and `/aido:1-plan`
lists findings it deferred under `Deferred` in `## Design notes`. `/aido:3-organize-commits` reverts
`SPEC.md` by default, so those points end up visible only in the branch history, and people lose
track of improvements they meant to come back to. A deferred criterion is also named under **Not
Included** in the PR, but that disappears from view once the PR is merged.

## Intent

When a feature has deferred points, `/aido:4-create-pr` offers to turn the ones worth keeping into
GitHub issues, so they outlive the specification. The engineer chooses which ones, because not every
point deserves an issue, and nothing is created without being asked.

The offer comes after the PR is created, rather than at the end of `/aido:2-implement`. Before then, a
later session or the verification could still change the list, and an abandoned branch would leave
orphan issues.

## Out of scope

- offering this anywhere other than `/aido:4-create-pr`, such as `/aido:2-implement` or
  `/aido:5-handle-review`
- recording the issues back: `## Progress`, the specification and the PR description stay as they
  are. Points the engineer does not pick stay where they were recorded
- changing how points are deferred or recorded, and the **Not Included** section of the PR
- changing what `/aido:assess-architecture` does for its users
- searching closed issues for duplicates

## Acceptance criteria

Offering the points

- AC1 (manual): after creating the PR, `/aido:4-create-pr` asks which deferred points should become
  issues. The deferred points are the deferred refactorings and deferred acceptance criteria in
  `## Progress`, and the `Deferred` list in `## Design notes`.
- AC2 (manual): the specification is read wherever it now is, so the offer works when
  `/aido:3-organize-commits` has reverted the specification or moved it into the docs.
- AC3 (manual): a point recorded in both `## Progress` and `## Design notes` is offered once.
- AC4 (manual): every deferred point can be chosen, however many there are, including when there are
  more than fit as options of one question.
- AC5 (manual): when there are no deferred points, nothing is asked. That includes a specification
  with no `## Progress` or `## Design notes`.

Opening the issues

- AC6 (manual): an issue is opened only for a point the engineer chose. Choosing none, or declining,
  opens nothing and leaves everything as it is today.
- AC7 (manual): an issue for a deferred refactoring holds the observation, its evidence
  (`path` — `Symbol`), why it was deferred, and a link to the PR.
- AC8 (manual): an issue for a deferred acceptance criterion holds the criterion's wording as the
  observation, why it was deferred, and a link to the PR. It needs no evidence.
- AC9 (manual): issue bodies follow the rules for GitHub bodies in `/aido:4-create-pr`: plain, concise
  language, no hard-wrapped prose and no reference to Claude Code.

Avoiding duplicates

- AC10 (manual): each chosen point is checked against open issues first. When one looks like the same
  problem, it is shown and the engineer chooses **Skip**, **Comment on it** or **Open a new issue
  anyway**, as in `/aido:assess-architecture`. Nothing is opened for a match unless the engineer
  chooses to.
- AC11 (manual): an issue the PR closes does not count as a match, because merging the PR would close
  it and the deferred point with it.

Keeping one approach

- AC12 (manual): `/aido:4-create-pr` and `/aido:assess-architecture` follow one shared description of
  how picked points become issues, rather than two separate ones. `/aido:assess-architecture` behaves
  as it does today.

Documentation and release

- AC13 (manual): the README says that `/aido:4-create-pr` offers to open issues for deferred points.
- AC14: `version` in `plugins/aido/.claude-plugin/plugin.json` is `3.1.0`, and
  `claude plugin validate .` and `claude plugin validate ./plugins/aido` pass.

## Plan

Everything here is skill and guideline text, so the layers read as: guideline (what skills share),
skill (what calls it), then documentation and manifest.

1. **guideline — refactor: move picking and opening issues out of `/aido:assess-architecture`**
   (enabling; also AC12). Add `plugins/aido/guidelines/github-issues.md`, holding what
   `/aido:assess-architecture` Steps 4 to 6 do today: the pick (multi-select for 4 or fewer; **All** /
   **None** / **By number** above that; stop on none), the duplicate check against open issues, and
   opening with a body file in the scratchpad, following the rules for GitHub bodies in
   `/aido:4-create-pr`. The caller supplies the points, each with its title and body sections, the
   label to look for, if any, and the issues that do not count as a match. The comment option becomes
   **Comment on #<n>**, carrying the evidence when the point has some. `/aido:assess-architecture`
   loads it in Step 0 and keeps only its own parts: body sections, closing line, the `refactor` label
   and its report. It behaves as it does today.
2. **skill — offer issues for deferred points in `/aido:4-create-pr`** (AC1, AC2, AC3, AC4, AC5, AC6,
   AC7, AC8, AC9, AC10, AC11). Add `## Step 4.5: Offer Issues for Deferred Points`, between assigning
   the PR and "Suggest Repository Conventions", so no step is renumbered. Step 0 loads
   `github-issues.md`. The step:
   - collects the deferred points from the specification already read in Step 0: deferred
     refactorings and deferred criteria in `## Progress`, and `Deferred` in `## Design notes`. The
     two refactoring lists are free-form, so it reads them leniently and treats findings with the same
     `path` — `Symbol` evidence as one point. With no points, it asks nothing
   - hands them to `github-issues.md`, with the body each kind needs (AC7, AC8) and the PR's URL from
     `gh pr view --json url`
   - looks for the `refactor` label on deferred refactorings only; deferred criteria get no label
   - excludes the issue from the PR's `Closes #NUMBER` from matching
3. **documentation — describe the offer and the guideline** (AC13). In `README.md`, extend the
   `/aido:4-create-pr` sentences in the workflow overview and the line saying a deferred criterion is
   named in the pull request description, and add `github-issues.md` to the Guidelines table.
4. **manifest — release it** (AC14). Set `version` to `3.1.0`, then run both validations.

AC14 is checked by commands: reading `version` and running the two validations. The other criteria
are `(manual)`, because `tests/` covers the hook scripts only, so `/aido:2-implement` confirms them
with the user by showing the skill and guideline text.

## Design notes

- **Where it belongs:** the offer is a new step in `plugins/aido/skills/4-create-pr/SKILL.md`, after
  `Step 4: Assign PR`. What the two skills share goes in a new guideline, because guidelines are the
  only shared layer (`CLAUDE.md`). `git-workflow.md` "Using GitHub CLI" is two generic lines and is
  not loaded by `/aido:assess-architecture`; `systemic-refactoring.md` covers finding refactorings,
  not filing them.
- **Existing behaviour and abstractions to reuse:**
  - `plugins/aido/skills/assess-architecture/SKILL.md` — `Step 4: Pick the Issues`,
    `Step 5: Check for Duplicates`, `Step 6: Open the Issues`: moved, not copied
  - `plugins/aido/skills/4-create-pr/SKILL.md` — `Read the specification` (AC2), `Not Included` (reads
    deferred criteria), and the `PR Description Checklist` lines already worded for "PR/issue bodies"
    (AC9)
  - `plugins/aido/guidelines/specification.md` — `Reading the Approved Specification`,
    `Acceptance in Progress` (`AC4: deferred — <why>`)
  - `plugins/aido/skills/2-implement/SKILL.md` — `STOP — Skill Complete` (**Deferred refactorings**);
    `plugins/aido/skills/1-plan/SKILL.md` — the `Design notes` template (`Deferred`)
- **Boundaries that must hold:** `/aido:assess-architecture` keeps its questions, labels, body
  sections and closing line, and still never edits the repository. Nothing about how points are
  recorded changes, and nothing is written back to the specification or the PR. Skills refer to the
  guideline as `${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md`, and guidelines refer to each other
  by file name.
- **Other modules or consumers affected:** `README.md`. No hook, test or other skill mentions
  `gh issue create` or `gh label list`. `/aido:stabilize` and `/aido:multi-phase-spec-pr` write no
  `## Design notes`, which AC5 already covers.
- **Enabling refactorings (planned):** plan item 1.
- **Deferred:**
  - Moving the rules for GitHub bodies out of the `PR Description Checklist` in
    `plugins/aido/skills/4-create-pr/SKILL.md` into the new guideline. The PR-only checklist items are
    entangled with them, and AC9 names `/aido:4-create-pr` as their home
  - Giving deferred refactorings a regular format in `plugins/aido/skills/2-implement/SKILL.md`
    (`STOP — Skill Complete`) and `plugins/aido/skills/1-plan/SKILL.md` (`Design notes`). Out of scope
    here, so points are read leniently
- **Open questions:** none that block implementation.

## Progress

- [x] refactor: move picking and opening issues into `guidelines/github-issues.md`
- [x] `Step 4.5: Offer Issues for Deferred Points` in `/aido:4-create-pr`
- [x] README: the offer and the new guideline
- [x] version `3.1.0`

Acceptance criteria:

- AC1: met — confirmed by the user: `Step 4.5` in `skills/4-create-pr/SKILL.md`
- AC2: met — confirmed by the user: `Step 4.5` uses the specification read in Step 0
- AC3: met — confirmed by the user: findings with the same evidence are offered as one point
- AC4: met — confirmed by the user: `Pick the Issues` in `guidelines/github-issues.md`
- AC5: met — confirmed by the user: `Step 4.5` skips without asking
- AC6: met — confirmed by the user: `Pick the Issues`, "On none, stop"
- AC7: met — confirmed by the user: the refactoring body in `Step 4.5`
- AC8: met — confirmed by the user: the criterion body in `Step 4.5`
- AC9: met — confirmed by the user: `Open the Issues` in `guidelines/github-issues.md`
- AC10: met — confirmed by the user: `Check for Duplicates` in `guidelines/github-issues.md`
- AC11: met — confirmed by the user: the issues that do not count as a match in `Step 4.5`
- AC12: met — confirmed by the user: `Step 4: Open the Issues` in
  `skills/assess-architecture/SKILL.md` follows the guideline
- AC13: met — confirmed by the user: the workflow overview and Guidelines table in `README.md`
- AC14: met — `version` is `3.1.0`, and both validations pass

Decisions:

- the comment option is now **Comment on #<n>** in both skills, because a deferred criterion has no
  evidence to post. Agreed with the plan
- the new step was confirmed by reading its text. It has not been run against a real PR

Deferred refactorings:

- Moving the rules for GitHub bodies into the guideline. `guidelines/github-issues.md` —
  `Open the Issues` points back at `skills/4-create-pr/SKILL.md` — `PR Description Checklist`, the only
  guideline that takes its rules from a skill. Deferred because the PR-only checklist items are
  entangled with them, and AC9 names `/aido:4-create-pr` as their home
- Giving deferred refactorings a regular format, in `guidelines/specification.md` next to
  `Acceptance in Progress`. `skills/2-implement/SKILL.md` — `STOP — Skill Complete` and
  `skills/1-plan/SKILL.md` — `Design notes` are the only definitions. Deferred because the
  specification puts changing how points are recorded out of scope
