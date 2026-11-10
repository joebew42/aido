# `/aido:deliberate` for multi-agent design deliberation

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

GitHub Issue: https://github.com/joebew42/aido/issues/88

## Context

`/aido:1-plan` designs a change in a single line of thought, so it can settle on the first plausible
design without weighing alternatives. That can add complexity nobody needed, or miss existing code
that could be reused. Exploring alternatives today depends on the developer asking for it, so it is
neither repeatable nor visible. A design approved before a multi-phase feature never reaches the
phase plans, because each phase draft copies only its own part of the specification.

## Intent

An optional `/aido:deliberate` skill explores competing designs before planning. Two agents propose a
design independently, one aiming for the best design and one for the simplest. A third compares them
and recommends one, a justified hybrid, or asks for clarification. The developer approves the
decision, which is saved in `SPEC.md.draft` as a `## Design decision` section that `/aido:1-plan`
keeps and plans from. Planning without deliberation works as it does today.
`/aido:multi-phase-plan` replaces `/aido:multi-phase-spec-pr`. It plans like `/aido:1-plan` but
splits the work into phases, so either planner can take the draft `/aido:deliberate` writes, and each
phase follows the approved design.

## Out of scope

- checking the requirements for gaps or conflicts with the repository: `/aido:1-plan` keeps doing that
- `/aido:1-plan` suggesting deliberation when the design is unclear
- an eval case, and the comparison of standard planning against deliberation
- reusable agent definitions in the plugin
- implementing the chosen design
- deliberating after the specification is approved

## Acceptance criteria

Starting

- AC1: When `/aido:deliberate` is given a feature request, a GitHub issue, or nothing while `SPEC.md.draft` exists, it deliberates on those requirements.
- AC2: When `SPEC.md` already exists, `/aido:deliberate` says the specification is already approved, and stops without deliberating.

Proposals

- AC3: Two design agents, one aiming for the best design and one for the simplest, get the same requirements and repository.
- AC4: Neither design agent sees the other's proposal.
- AC5: Each proposal states its approach, rationale, assumptions, risks, the repository constraints it rests on, and its implementation impact.

Recommendation

- AC6: A third agent compares both proposals and recommends one unchanged, a justified hybrid, or asks for clarification.
- AC7: The recommendation explains why, and names the trade-offs between the proposals.
- AC8: When the recommendation asks for clarification, the developer's answer becomes a constraint, and a new round of proposals starts.

Approval

- AC9: The developer sees both proposals and the recommendation, then accepts it, picks either proposal, or asks for another round with new constraints.
- AC10: Nothing is saved until the developer approves a decision. With no answer, nothing is saved.

The decision

- AC11: On approval, `SPEC.md.draft` gets a `## Design decision` section: alternatives, chosen approach and why, accepted trade-offs and risks, and when to revisit.
- AC12: When there is no `SPEC.md.draft`, the approved decision creates it, holding the requirements deliberated on.
- AC13: When `SPEC.md.draft` already has a `## Design decision`, the approved decision replaces it.

Planning

- AC14: When `/aido:1-plan` refines a draft with a `## Design decision`, the section stays unchanged in `SPEC.md`.
- AC15: When `SPEC.md` has a `## Design decision`, the plan follows the chosen approach.
- AC16: When a specification with a `## Design decision` is distilled, the distilled doc includes the decision.

Limits and ending

- AC18: When no subagent can run, `/aido:deliberate` says deliberation needs independent agents, saves nothing, and stops.
- AC19: When a request is given while `SPEC.md.draft` exists, `/aido:deliberate` asks whether to deliberate on the draft or replace it.
- AC20: Once the decision is saved, `/aido:deliberate` ends by pointing to `/aido:1-plan`, asking nothing more.

Documentation

- AC17 (manual): The README presents `/aido:deliberate` as an optional step before `/aido:1-plan`.

Multi-phase planning

- AC21: `/aido:multi-phase-plan` replaces `/aido:multi-phase-spec-pr`, and every skill, guideline and the README names the new command.
- AC22: When `/aido:multi-phase-plan` is given a draft, it refines it as `/aido:1-plan` does, then plans it as phases, each naming the criteria it delivers.
- AC23: When the draft has a `## Design decision`, `/aido:multi-phase-plan` keeps it unchanged, and the phases follow its chosen approach.
- AC24: When a phase draft is written from a main specification with a `## Design decision`, it carries the part of the decision that phase builds.
- AC25: Once the phases are approved, `/aido:multi-phase-plan` commits the main specification and opens the tracking draft PR with its roadmap, as today.
- AC26 (manual): The README presents `/aido:deliberate` as an optional step before `/aido:1-plan` or `/aido:multi-phase-plan`.

## Plan

1. **the design decision in the specification structure** (AC11, AC16) — inside-out: follows
   `## Alignment decisions` and its "Alignment Decisions" subsection in `specification.md`. Touches
   `specification.md`
   - the template gets `## Design decision` after `## Alignment decisions` and before `## Plan`
   - a new "Design Decision" subsection gives its format: the alternatives considered, the chosen
     approach and why, the accepted trade-offs and risks, and when to revisit it
   - "The specification states what and why, never how" names the design decision as the one
     approved how
   - "The distilled text" includes the design decision
2. **start `/aido:deliberate` on the right requirements** (AC1, AC2, AC19, AC20) — inside-out:
   follows `verify/SKILL.md`, the spec resolution line in `stabilize/SKILL.md`, and the issue reading
   in `1-plan/SKILL.md` "Standalone Project Flow". Touches a new `skills/deliberate/SKILL.md`
   - front matter, title, the Copilot CLI line, the spec resolution and language lines
   - `SPEC.md` exists → say it is approved, and stop. A draft found next to it is deleted, as
     "The Specification File" says. A leftover spec stops it, as for any skill about to write a spec
   - an issue is read with `gh issue view`, a request is taken as given, and with no argument the
     draft is used. With neither, ask for the request in free text
   - a request given while a draft exists → ask **Use the draft** / **Replace it with the request**
   - the ending block, with `Needs you: run /aido:1-plan`, and no question
3. **two independent proposals** (AC3, AC4, AC5, AC18) — inside-out: follows `assess-architecture`
   Step 2 for parallel `fable` agents, and `verify/SKILL.md` Step 3 and "The Verification Brief" for
   a brief that holds nothing else from the session. Touches `skills/deliberate/SKILL.md`
   - two `Agent` calls with `model: "fable"`, in one message, each briefed with "The Shared Brief"
     in `subagents.md`, the requirements, the repository's agent instruction files, the rules in
     `code-standards.md`, and "Reading the Index" when an index exists
   - "The Proposal Brief" in the skill, with each agent's objective, and the fields every proposal
     returns
   - fallback to the session's model as "When the Model Is Unavailable" says. When no subagent can
     run, stop and save nothing
4. **the recommendation and the developer's choice** (AC6, AC7, AC8, AC9, AC10) — inside-out:
   follows `verify/SKILL.md` Step 3 for a fresh agent, and "Asking Questions" in `language.md`.
   Touches `skills/deliberate/SKILL.md`
   - a third `fable` agent gets the requirements and both proposals, with "The Comparison Brief": pick
     one unchanged, a justified hybrid, or ask for clarification. Never force a compromise. Name the
     trade-offs
   - a clarification is asked in free text. The answer joins the constraints, and a new round starts
     from fresh agents, with no earlier proposal
   - show both proposals and the recommendation, then ask **Accept the recommendation** / **Use the
     best design** / **Use the simplest design** / **Another round**, which asks for the new
     constraints
   - with no answer, save nothing
5. **save the approved decision** (AC11, AC12, AC13) — inside-out: follows item 1's format, and the
   draft `1-plan/SKILL.md` writes from an issue. Touches `skills/deliberate/SKILL.md`
   - with no draft, write `SPEC.md.draft` with the requirements, and the `GitHub Issue:` line for an
     issue
   - add `## Design decision` at the end of the draft, or replace the one there
6. **`/aido:1-plan` keeps the decision and plans from it** (AC14, AC15) — inside-out: follows how
   "Rewrite it into the specification structure" keeps the required sections. Touches
   `1-plan/SKILL.md`
   - the rewrite and the "Small-Change Route" keep `## Design decision` unchanged, in its place, and
     never ask whether to move or drop it
   - Step 5's brief says the decision is approved, so findings work within it
   - Step 6's plan follows the chosen approach. A plan that can't is raised with the user
7. **present it in the README, and release it** (AC17) — inside-out: follows the `/aido:verify`
   rows and "What planning looks like" in `README.md`. Touches `README.md`, `plugin.json`
   - a row in the Utilities table, and a short paragraph saying it is an optional step before planning
   - `version` goes to `5.13.0`
8. **refactor: move the refining steps into a guideline** (enabling) — guidelines, skills
   - a new `guidelines/refining-a-draft.md` holds `1-plan/SKILL.md` Step 3's "Load the context",
     "Analyse, refine and reword", "Rewrite it into the specification structure" and "Check the
     alignment with the repository", word for word except where they point into the skill
   - 1-plan Step 3 loads it and keeps "Approve the specification". "Approve the draft and choose the
     route" and the "Small-Change Route" point to it instead of to Step 3
   - `stabilize/SKILL.md` Step 5 points to it instead of to `/aido:1-plan` Step 3
   - the pins in `tests/skills.sh` move with the text. Behaviour is unchanged: propose one run of the
     `plan-*` eval cases, and ask first
9. **refactor: point the multi-phase skill at the refining guideline** (enabling) — skills
   - "Review and Refine Feature Spec" in `multi-phase-spec-pr/SKILL.md` drops its summary of Step 3,
     and points to "Approve the draft" in `${CLAUDE_PLUGIN_ROOT}/skills/1-plan/SKILL.md` and to the
     guideline by path, so the rule that keeps `## Design decision` is read
10. **refactor: let the multi-phase skill rely on the spec structure for the issue line** (enabling)
    — skills, tests
    - "Add the GitHub Issue to Feature Spec" adds the `GitHub Issue:` line as "The Specification
      Structure" in `specification.md` shows it, instead of copying the template
    - the skill leaves the marker-line loop in `tests/skills.sh`
11. **rename the skill to `/aido:multi-phase-plan`** (AC21) — inside-out: follows how a skill folder
    is named and referenced, checked by the skill-name check in `tests/skills.sh`. Touches skills,
    guidelines, README, tests
    - `git mv` the folder to `skills/multi-phase-plan/`, with a new description and title
    - every reference names the new command: "Plan Items" in `specification.md`, step 2 of
      `multi-phase-switch/SKILL.md`, and the README's multi-phase table and "Plan a multi-phase
      feature"
    - the paths in `tests/skills.sh` follow the rename
12. **refine and plan the phases as `/aido:1-plan` does** (AC22, AC23, AC25) — inside-out: follows
    `1-plan/SKILL.md` Step 1, "Standalone Project Flow" and Step 6, and the guideline from item 8.
    Touches skills, tests
    - `SPEC.md` exists → it is approved: delete any draft, and go to proposing the phases
    - only a draft → approve and refine it as item 9 points, without the analysis question, then move
      it to `SPEC.md`
    - neither → offer the sources of "Standalone Project Flow" in
      `${CLAUDE_PLUGIN_ROOT}/skills/1-plan/SKILL.md`: an issue, writing it, or a conversation
    - with a `## Design decision`, the phases follow its chosen approach. When they can't, it is raised
      with the user, as 1-plan Step 6 does
    - committing the main spec and opening the tracking draft PR with its roadmap stay as today
    - `tests/skills.sh` pins the new wording
13. **carry the phase's part of the decision into its draft** (AC24) — inside-out: follows how a
    phase carries only its own criteria, in "Acceptance Criteria" in `specification.md` and
    "Multi-Phase Project Flow" step 4 in `1-plan/SKILL.md`. Touches guidelines, skills, tests
    - "Design Decision" in `specification.md`: a phase draft keeps the four fields, each cut to what
      the phase builds. When the decision can't be split, it is copied whole
    - step 4 of "Multi-Phase Project Flow" gets a bullet that carries it so
    - `tests/skills.sh` pins both
14. **present both planners, and release it** (AC21, AC26) — inside-out: follows the
    `/aido:deliberate` paragraph and rows in `README.md`, and the ending in
    `deliberate/SKILL.md`. Touches skills, README, `plugin.json`
    - `/aido:deliberate`'s description, introduction and ending name `/aido:1-plan`, or
      `/aido:multi-phase-plan` for a feature built in phases. The pinned `Needs you: run
      /aido:1-plan` stays
    - the README paragraph under "What planning looks like", the Utilities row, and "Plan a
      multi-phase feature" present `/aido:deliberate` as optional before either planner
    - `version` goes to `6.0.0`, since the old command is removed

## Design notes

- **Where it belongs:** `plugins/aido/skills/deliberate/SKILL.md`, unnumbered like `verify`, because
  it is optional. Its two briefs are sections in the skill, copied in full into each brief, as
  `verify/SKILL.md` does with "The Verification Brief". The format of `## Design decision`, and the
  rule that distilling keeps it, belong in `plugins/aido/guidelines/specification.md` — "The
  Specification Structure" and "Settling It". Keeping it and planning from it belong in
  `plugins/aido/skills/1-plan/SKILL.md` — "Rewrite it into the specification structure",
  "Small-Change Route", Step 5 and Step 6.
- **Existing behaviour and abstractions to reuse:**
  - `plugins/aido/guidelines/subagents.md` — "The Shared Brief", "When the Model Is Unavailable"
  - `plugins/aido/skills/assess-architecture/SKILL.md` — Step 2, several `fable` agents in parallel
  - `plugins/aido/skills/verify/SKILL.md` — Step 3: "nothing else from this session". The same line
    keeps each design agent from seeing the other's proposal
  - `plugins/aido/skills/2-implement/SKILL.md` — "Only the orchestrator writes `SPEC.md`": here only
    the session writes `SPEC.md.draft`
  - `plugins/aido/guidelines/specification.md` — "The Specification File", "A Leftover Spec"
  - `plugins/aido/skills/1-plan/SKILL.md` — "Standalone Project Flow" for reading an issue, and
    Step 1, which already offers a lone draft as **Resume refining it**. A deliberated draft enters
    planning there with no new step
  - `plugins/aido/guidelines/architecture-index.md` — "Reading the Index", copied into a brief when
    an index exists. Offering to build the index stays with planning
  - `plugins/aido/guidelines/copilot-cli.md` — "Tools" maps `Agent` to Copilot's own, on the
    session's model
- **Boundaries that must hold:**
  - `tests/skills.sh`: every `SKILL.md` has the Copilot CLI line first after the title, the language
    line, and "Ending a Skill". A quoted or bold phrase followed by "in `<file>.md`" must be a
    heading or bold label in that file. Only `subagents.md` says "the rules it points to in
    `code-standards.md`". No guideline points into a skill. Every `/aido:<name>` names a skill folder,
    so the README mentions the skill only once the folder exists
  - `specification.md`: the draft is never committed, and never sits next to `SPEC.md`. The required
    sections keep their names and order
  - planning a draft without `## Design decision` reads exactly as today
  - `AGENTS.md`: TODO-app examples, `${CLAUDE_PLUGIN_ROOT}` paths in the skill, a version bump,
    `tests/all.sh` after every change, and a before-and-after example of the spec structure in the PR
- **Other modules or consumers affected:**
  - `multi-phase-spec-pr` and `stabilize` refine as `/aido:1-plan` Step 3 does, and inherit the kept
    section with no edit. `stabilize` stops when a draft exists, so never meets a deliberated one
  - `2-implement` and `verify` name `## Design notes` as the agreed design. They are unchanged: the
    plan follows the decision, and verification reads the whole spec
  - `3-organize-commits`, `4-open-pr` and `5-handle-review` settle the spec through
    `specification.md` alone, so AC16 needs no edit there
  - `tests/skills.sh` and `tests/test_skills.py` pin the new wording
- **Enabling refactorings (planned):** none.
- **Deferred:** none.
- **Open questions:** none. Settled while planning: with no subagents it stops (AC18); a request and
  a draft together are asked about (AC19); it ends by pointing to `/aido:1-plan` (AC20); a new round
  carries only the constraints; a decision in a multi-phase main spec doesn't reach the phase drafts.
  The change alters how `/aido:1-plan` behaves, so propose one run of the `plan-*` eval cases, and
  ask first. The PR says `/aido:deliberate` itself isn't covered by evals.

The notes above were written for items 1–7. Items 8–14, for AC21–AC26, replace the lines about
`multi-phase-spec-pr` and about a decision not reaching the phase drafts:

- **Where it belongs:** `plugins/aido/skills/multi-phase-plan/SKILL.md`, renamed from
  `multi-phase-spec-pr` with `git mv`. AC22, AC23 and AC25 are its "Review and Refine Feature Spec"
  and "Review Feature Spec and Propose Implementation Plan", with branch, commit, push and PR steps
  kept. AC24 belongs in `plugins/aido/guidelines/specification.md` — "Design Decision", and in
  `plugins/aido/skills/1-plan/SKILL.md` — "Multi-Phase Project Flow" step 4. The refining steps move
  to a new `plugins/aido/guidelines/refining-a-draft.md`.
- **Existing behaviour and abstractions to reuse:**
  - `plugins/aido/skills/1-plan/SKILL.md` — "Approve the draft", "Standalone Project Flow", Step 3,
    Step 6 ("the plan follows its chosen approach")
  - `plugins/aido/skills/1-plan/SKILL.md` — "Multi-Phase Project Flow" step 3 already reads the whole
    main spec, so the decision is in hand at step 4
  - `plugins/aido/guidelines/specification.md` — "Plan Items", "Acceptance Criteria" ("a phase carries
    only the criteria it delivers"), "The Specification Structure", "Design Decision"
  - `plugins/aido/guidelines/pr-roadmap.md` — the tracking PR's roadmap
  - `plugins/aido/skills/verify/SKILL.md` — "The Verification Brief" and
    `plugins/aido/skills/2-implement/SKILL.md` — "The final design review" already check a
    `## Design decision`, so a phase spec that carries one needs no edit there
- **Boundaries that must hold:**
  - `tests/skills.sh`: every `/aido:<name>` names a skill folder, so all four references outside the
    skill change with the rename. The "A Leftover Spec" pin and the marker-line loop name the old
    path. No guideline points into a skill, so `refining-a-draft.md` names no skill step. The Copilot
    CLI line, the language line and "Ending a Skill" in the renamed skill
  - `deliberate/SKILL.md` keeps the pinned `Needs you: run /aido:1-plan`
  - a draft or main spec without `## Design decision` is planned exactly as today, by both planners
  - `AGENTS.md`: the PR shows a phase draft before and after, says the old command is gone, and says
    `/aido:multi-phase-plan` has no eval case. `tests/all.sh` after every change
- **Other modules or consumers affected:**
  - `stabilize/SKILL.md` Step 5, through item 8
  - `multi-phase-switch/SKILL.md` step 2 names the new command
  - `multi-phase-sync/SKILL.md` and `4-open-pr/SKILL.md` "Roadmap Section" are unchanged
  - the architecture index names the old command: run `/aido:map-architecture` in update mode after
    merging
  - users of `/aido:multi-phase-spec-pr`: the command stops working, so the PR says what replaces it
- **Enabling refactorings (planned):** items 8, 9 and 10.
- **Deferred:** none.
- **Open questions:** none. Settled while planning: a phase draft trims the decision to its phase,
  or copies it whole when it can't be split; `/aido:deliberate` names both planners; with no draft,
  `/aido:multi-phase-plan` offers an issue, writing it, or a conversation; with an approved `SPEC.md`
  it goes straight to the phases. Phases still get no refactoring analysis: each phase's own
  `/aido:1-plan` run does it.

## Refactorings

### r1. Call the person "the user", not "the developer"

- **Change:** Say "the user" wherever the branch says "the developer", and change the pinned lines in
  `tests/skills.sh` in the same commit.
- **Why:** On the default branch no skill or guideline says "developer"; they say "the user" about
  175 times. The branch adds "the developer" 10 times, so a reader meets several names for one person.
- **Where:**
  - `plugins/aido/guidelines/specification.md` — the `## Design decision` template line, "The
    specification states what and why, never how", "Design Decision"
  - `plugins/aido/skills/1-plan/SKILL.md` — "Rewrite it into the specification structure", Step 5
  - `plugins/aido/skills/deliberate/SKILL.md` — the description, the introduction, "Step 4: The
    Developer Decides", Step 5
  - `tests/skills.sh` — the four pinned lines that hold "the developer"
- **Confidence:** medium — the word comes from the issue and the criteria, so it may be deliberate.
- **Risk:** the pinned lines fail until they change with the text; the Step 4 heading changes name.

### r2. Let verification and the final review name the design decision

- **Change:** In "The Verification Brief", add `## Design decision` to the agreed constraints and to
  the departures under deviations, next to `## Design notes`. Name it in `/aido:2-implement`'s final
  design review brief too.
- **Why:** The brief lists every spec section that changes how a build is judged, but not the one
  approved how. A build that leaves the chosen approach is reported only when it also leaves the plan.
- **Where:**
  - `plugins/aido/skills/verify/SKILL.md` — "The Verification Brief"
  - `plugins/aido/skills/2-implement/SKILL.md` — "The final design review"
- **Confidence:** medium — whether a verifier misses such a departure in practice is assumed.
- **Risk:** changes what `/aido:verify` reports; its eval cases and pinned lines are affected.

### r3. Settle what a design decision means for a multi-phase feature

- **Change:** Either have `/aido:deliberate` say it serves a single feature or phase, or have the
  multi-phase plan follow the decision and the phase draft carry it.
- **Why:** `/aido:multi-phase-spec-pr` keeps the section but its phase plan never mentions it, and
  the phase draft takes only the phase's part, so an approved design can sit unused.
- **Where:**
  - `plugins/aido/skills/multi-phase-spec-pr/SKILL.md` — "Review and Refine Feature Spec", "Review
    Feature Spec and Propose Implementation Plan"
  - `plugins/aido/skills/1-plan/SKILL.md` — "Multi-Phase Project Flow" step 4, Step 6
  - `plugins/aido/guidelines/specification.md` — "The specification states what and why, never how"
- **Confidence:** medium — it assumes someone deliberates before a multi-phase feature.
- **Risk:** changes two skills' behaviour across skills; probably needs an eval run.

## Progress

- [x] 1. the design decision in the specification structure
  - the template, a "Design Decision" subsection with an example, the "one exception" to "never
    how", and the distilled text
- [x] 2. start `/aido:deliberate` on the right requirements
  - a new `skills/deliberate/SKILL.md`: Step 0 stops on an approved spec or a leftover, Step 1 picks
    the requirements, and the ending points to `/aido:1-plan`
- [x] 3. two independent proposals
  - Step 2 launches both `fable` agents in one message with "The Proposal Brief", and stops when no
    subagent can run
  - the proposal's assumptions field is `**Assumes:**`: `tests/skills.sh` rejects
    `**Assumptions:**` as an old finding field
- [x] 4. the recommendation and the developer's choice
  - Step 3 briefs a third `fable` agent with "The Comparison Brief". Step 4 shows everything, asks a
    clarification in free text, and otherwise asks which design to save
- [x] 5. save the approved decision
  - Step 5 writes a new draft with the marker line when none is used, then adds or replaces
    `## Design decision` at its end
- [x] 6. `/aido:1-plan` keeps the decision and plans from it
  - the full and small-change rewrites keep the section after the criteria; Step 5's brief and
    Step 6's plan work within the chosen approach. Every new line applies only when the section
    exists
- [x] 7. present it in the README, and release it
  - a paragraph under "What planning looks like", a row in the Utilities table, and `version`
    5.13.0
- [x] r1. Call the person "the user", not "the developer"
  - the skills, `specification.md` and the four pins in `tests/skills.sh`. The criteria keep their
    wording
- [x] r2. Let verification and the final review name the design decision
  - "The Verification Brief" checks `## Design decision` as an agreed constraint and a source of
    deviations; the final design review says where the build departs from the chosen approach
- [x] r3. Settle what a design decision means for a multi-phase feature — replaced by AC21–AC26
  - the user chose to replace `/aido:multi-phase-spec-pr` with `/aido:multi-phase-plan` on this
    branch, and to remove the old command, so the version goes to 6.0.0. The new items need planning
- [x] 8. refactor: move the refining steps into a guideline
  - `guidelines/refining-a-draft.md` holds the four refining steps; 1-plan Step 3, its two
    "Load the context" pointers, the small-change rewrite and stabilize Step 5 point to it
- [x] 9. refactor: point the multi-phase skill at the refining guideline
  - "Review and Refine Feature Spec" approves the draft as 1-plan's "Approve the draft", then refines
    it by the guideline
- [x] 10. refactor: let the multi-phase skill rely on the spec structure for the issue line
  - "Add the GitHub Issue to Feature Spec" points to "The Specification Structure"; the marker-line
    loop no longer names the skill
- [x] 11. rename the skill to `/aido:multi-phase-plan`
  - the folder, its description and title, `specification.md`, `multi-phase-switch` and the README;
    `tests/skills.sh` checks that nothing names the old command
- [x] 12. refine and plan the phases as `/aido:1-plan` does
  - "Review and Refine Feature Spec" takes an approved `SPEC.md`, a draft, or 1-plan's three sources;
    the phase proposal follows any `## Design decision`, or asks the user
  - an approved `SPEC.md` goes on at "Get the GitHub Issue", not straight to the phases, so the
    branch can still be named after its issue
- [x] 13. carry the phase's part of the decision into its draft
  - "Design Decision" says a phase draft keeps the four fields cut to its phase, or the whole
    decision when it can't be split; 1-plan "Multi-Phase Project Flow" step 4 carries it so
- [x] 14. present both planners, and release it
  - `/aido:deliberate`'s description, introduction and ending name both planners; the README
    paragraph, the Utilities row and "Plan a multi-phase feature"; `version` 6.0.0
- Key decisions: the remaining wording got its own pins in a `test:` commit, once the acceptance
  check showed AC1, AC6, AC7, AC9 and AC10 were only partly pinned. The README warns that
  `/aido:deliberate` runs on an expensive model, at the user's request
- One run of the `plan-*` eval cases passed with aido (not recorded)
- After items 8–14, one more run of the `plan-*` eval cases passed with aido (not recorded)
- Key decisions for items 8–14: an approved `SPEC.md` goes through "Get the GitHub Issue" before the
  phases; a `test:` commit pins the tracking PR as a draft, for AC25
- the final design review ran and recorded r1, r2, r3
- Design notes that no longer hold: only `tests/skills.sh` pins the wording, not
  `tests/test_skills.py`; the code-standards rules are copied whole into the proposal brief; and
  `/aido:1-plan` Step 1 still calls a deliberated draft "left from an earlier session", and
  **Start over** deletes its decision without saying so

### Acceptance

- AC1: met — `tests/skills.sh` pins Step 1: an issue, a request, and the draft with no argument
- AC2: met — `tests/skills.sh` pins "`SPEC.md` exists → say the specification is already approved,
  and stop without deliberating"
- AC3: met — `tests/skills.sh` pins the two `fable` agents, their objectives, and "the same
  requirements, word for word, and the same repository"
- AC4: met — `tests/skills.sh` pins "nothing else from this session, and never the other agent's
  proposal"
- AC5: met — `tests/skills.sh` pins the six proposal fields
- AC6: met — `tests/skills.sh` pins the third agent and "recommend one proposal unchanged, a
  justified hybrid, or ask for clarification"
- AC7: met — `tests/skills.sh` pins the recommendation's `Why` and `Trade-offs`
- AC8: met — `tests/skills.sh` pins the clarification that joins the constraints and starts a new
  round
- AC9: met — `tests/skills.sh` pins showing both proposals and the recommendation, and the four
  options
- AC10: met — `tests/skills.sh` pins "only once the developer approves a design" and "With no
  answer, save nothing"
- AC11: met — `tests/skills.sh` pins the "Design Decision" fields in `specification.md` and Step 5's
  reference to them
- AC12: met — `tests/skills.sh` pins writing a new draft with the requirements deliberated on
- AC13: met — `tests/skills.sh` pins replacing an existing `## Design decision`
- AC14: met — `tests/skills.sh` pins keeping the section unchanged in `/aido:1-plan`'s two rewrites
- AC15: met — `tests/skills.sh` pins "the plan follows its chosen approach"
- AC16: met — `tests/skills.sh` pins the design decision in "The distilled text"
- AC17: met — confirmed by the user: the README paragraph under "What planning looks like", with
  the cost warning, and the Utilities row
- AC18: met — `tests/skills.sh` pins "say that deliberation needs independent agents, save nothing,
  and stop"
- AC19: met — `tests/skills.sh` pins **Use the draft** / **Replace it with the request**
- AC20: met — `tests/skills.sh` pins `Needs you: run /aido:1-plan` and "Ask nothing more"
- AC21: met — `tests/skills.sh` checks that nothing names `/aido:multi-phase-spec-pr`, and that every
  `/aido:<name>` names a skill folder
- AC22: met — `tests/skills.sh` pins the draft approved as 1-plan's "Approve the draft", refined by
  `refining-a-draft.md`, and "the acceptance criteria each phase delivers, by ID"
- AC23: met — `tests/skills.sh` pins the kept `## Design decision` in `refining-a-draft.md`, and "the
  phases follow its chosen approach"
- AC24: met — `tests/skills.sh` pins the phase rule in "Design Decision" and the bullet in 1-plan
  "Multi-Phase Project Flow" step 4
- AC25: met — `tests/skills.sh` pins the `docs: feature specification` commit, the unchecked roadmap and
  the draft PR
- AC26: met — confirmed by the user: the README paragraph under "What planning looks like", the
  Utilities row and "Plan a multi-phase feature"
