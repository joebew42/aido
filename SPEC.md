# Make systemic refactoring findings argue against themselves

## Context

A systemic design check can find many possible improvements, and not all of them are worth making.
The difficult question is often whether the diagnosis is right, not which solution is best.

`guidelines/systemic-refactoring.md` already says that similar-looking code is not proof and that
"nothing to refactor" is a valid outcome. But a finding is not asked to show that it considered
another explanation or leaving the code alone, to separate what it saw from what it assumed, or to
say how sure it is. An engineer deciding on a finding cannot tell a well-tested diagnosis from a
plausible first guess.

`/aido:1-plan` and `/aido:2-implement` open the cited files and confirm a subagent's findings before
relying on them. `/aido:assess-architecture` presents them unconfirmed, and the engineer picks from
them which issues to open.

Custom plugin subagents were considered as the way to deliver this, and rejected. The skills already
run these checks in subagents with inline briefs, separate from the session doing the work. The
checks need `Bash` for the diff and code history, so a tool allowlist cannot make them read-only, and
plugin agents ignore `permissionMode`. The rules already live in one guideline, so a custom agent
would add a new plugin concept for little gain.

## Intent

Every systemic refactoring finding shows the reasoning behind it, so the engineer can judge how far
to trust it and decide whether to act, including deciding to leave the code alone. Findings from
`/aido:assess-architecture` are confirmed against the code before the engineer sees them. The
engineer still makes the decisions.

## Out of scope

- custom plugin subagents: the plugin gains no `agents/` directory, and the existing inline briefs
  stay inline
- a dedicated decision model, or any integration with one
- numeric scores, weightings or probabilities on findings
- new or changed classifications: fix now, refactor now, defer, no action and enabling stay as they
  are
- a fresh-context critique of specifications in `/aido:1-plan`
- changes to `/aido:verify`, `/aido:5-handle-review` or `/aido:map-architecture`
- measuring whether decisions improve: no evaluation or before-and-after comparison is built

## Acceptance criteria

The decision protocol

- AC1 (manual): `systemic-refactoring.md` requires every finding to state the competing explanations
  it considered, always including that no change is needed
- AC2 (manual): it requires every finding to separate what was observed in the code from what is
  assumed
- AC3 (manual): it requires every finding to state its confidence as high, medium or low, defines
  each level by the strength of the evidence, and requires naming the evidence that would change the
  conclusion
- AC4 (manual): it forbids numeric scores and probabilities on findings
- AC5 (manual): it says a low-confidence finding is classified only as defer or no action, and names
  the evidence still missing
- AC6 (manual): it says the on-evidence check during TDD writes this reasoning out only for a finding
  shown to the engineer or recorded as deferred, so routine cycles stay light

Where findings carry it

- AC7 (manual): the briefs in `/aido:assess-architecture`, the enabling refactoring analysis of
  `/aido:1-plan` and the final Systemic Design Checkpoint of `/aido:2-implement` each ask for this
  reasoning in what the subagent returns
- AC8 (manual): the issue body that `/aido:assess-architecture` opens includes the competing
  explanations, the confidence and the evidence that would change the conclusion

Confirming assessment findings

- AC9 (manual): `/aido:assess-architecture` opens the cited files and confirms each finding before
  presenting it
- AC10 (manual): a finding that does not survive confirmation is not offered as an issue, and the
  presentation lists it with the reason it was dropped

The plugin stays valid

- AC11: `claude plugin validate .` and `claude plugin validate ./plugins/aido` pass
- AC12: `plugins/aido/skills` and `plugins/aido/guidelines` name no third-party decision model

## Plan

The plugin has no code layers as such, so the guideline is treated as the domain (the rules), the
skills as the application (the workflow that applies them), and the manifest as infrastructure.

1. **`refactor:` domain — define what a finding states in one place** (enabling)
   Add a short block to `systemic-refactoring.md` holding the fields both briefs restate today:
   **Observation**, **Evidence** (`path` — `Symbol`), **Recommendation** and **Risk**. The briefs in
   `/aido:assess-architecture` and `/aido:2-implement` refer to it and keep only their own extras:
   Category, Size and Impact, and Classification. What a subagent receives does not change, because
   each brief already copies the guideline.
2. **domain — add the decision protocol to the guideline** (AC1, AC2, AC3, AC4, AC5, AC6)
   Extend that block with **Competing explanations**, always including that no change is needed,
   **Assumptions**, **Confidence** and **What would change it**. Define high, medium and low in terms
   of the existing evidence rule, so there is no second standard of evidence. Forbid numeric scores
   and probabilities, limit a low-confidence finding to defer or no action, naming the evidence still
   missing, and say when the on-evidence check writes the reasoning out.
3. **application — have the three briefs return the reasoning** (AC6, AC7)
   - `/aido:assess-architecture` Step 2 and the `/aido:2-implement` final checkpoint return findings
     as the guideline defines them
   - `/aido:1-plan` Step 5 gains the same request; it has no shape for findings today
   - in `/aido:2-implement`, update the list of what the guideline holds, and add the reasoning to
     what the on-evidence check shows the engineer and to **Deferred refactorings** in the `## Progress`
     handoff
4. **application — carry the reasoning into assessment issues** (AC8)
   Add **Competing explanations**, **Confidence** and **What would change it** to the body list in
   `/aido:assess-architecture` Step 4. `github-issues.md` takes any title and body, so it does not
   change.
5. **application — confirm assessment findings before presenting them** (AC9, AC10)
   In `/aido:assess-architecture` Step 3, open the cited files and confirm each finding first. Show
   findings that fail as dropped, with the reason, outside the numbered list offered as issues, and
   include them in the Step 5 report.
6. **infrastructure — release and validate** (AC11, AC12)
   Bump `version` in `plugin.json` to `3.2.0`, run both validators, and search the skills and
   guidelines for the name of any third-party decision model.

## Design notes

- **Where it belongs:** `plugins/aido/guidelines/systemic-refactoring.md`, next to **Evidence before
  action** and **Classify every finding**. It already defines what a finding must rest on, and it is
  the one guideline `/aido:2-implement` may read during implementation
  (`skills/2-implement/SKILL.md`, "Systemic Design Checkpoint"), so the protocol cannot live in a new
  guideline. Confirmation belongs in `skills/assess-architecture/SKILL.md` Step 3.
- **Existing behaviour and abstractions to reuse:**
  - `guidelines/systemic-refactoring.md` — **Evidence before action**, **Classify every finding**,
    **Stop searching** ("what uncertainty could still change the design")
  - `skills/assess-architecture/SKILL.md` — Step 2 return format, which gains the new fields
  - `skills/2-implement/SKILL.md` — "open the cited files and confirm each finding before acting on
    it", the wording to mirror for AC9
  - the existing terms finding, evidence, Observation, Recommendation and Risk. "Confidence" is new:
    the verified and insufficient evidence of `/aido:verify` judge requirements, not diagnoses
- **Boundaries that must hold:**
  - subagents do not load guidelines, so everything they need stays in the copied
    `systemic-refactoring.md` or in the brief
  - skills name bundled files through `${CLAUDE_PLUGIN_ROOT}`, and guidelines name each other by file
    name
  - the classifications stay frozen, there is no `agents/` directory, and the content stays
    stack-agnostic
- **Other modules or consumers affected:**
  - `skills/4-create-pr/SKILL.md` Step 4.5 reads **Deferred refactorings** leniently, so the extra
    reasoning does not break it, and **Observation** keeps its name in its issue bodies
  - `guidelines/github-issues.md`, `/aido:verify`, `/aido:5-handle-review`, `/aido:stabilize` and
    `/aido:map-architecture` do not restate these fields and do not change
- **Design decisions taken while planning:**
  - **Observation** keeps its name and holds what the code shows, and **Assumptions** sits beside it,
    so `/aido:4-create-pr` is not touched
  - the per-area "hypotheses checked and rejected" line in `/aido:assess-architecture` stays: it
    covers hypotheses that never became findings, which per-finding explanations and the AC10 dropped
    list do not
  - `/aido:1-plan` keeps its lighter confirmation, limited to findings that would add a plan item
- **Enabling refactorings (planned):** plan item 1.
- **Deferred:**
  - unify the three wordings of "confirm a subagent's findings"
    (`skills/2-implement/SKILL.md`, `skills/1-plan/SKILL.md` Step 5, and the new one in
    `skills/assess-architecture/SKILL.md`). Their scopes differ on purpose, and merging them would
    change `/aido:1-plan`'s behaviour
  - carry the reasoning into the issue bodies of `skills/4-create-pr/SKILL.md` Step 4.5, which would
    otherwise drop it for deferred refactorings
  - post the reasoning, not only the evidence, when `guidelines/github-issues.md` comments on an
    existing issue
- **Open questions:** none.

## Progress

Implemented:

- [x] 1. define what a finding states in one place
- [x] 2. add the decision protocol to the guideline
- [x] 3. have the three briefs return the reasoning
- [x] 4. carry the reasoning into assessment issues
- [x] 5. confirm assessment findings before presenting them
- [x] 6. release as `3.2.0` and validate

Acceptance criteria:

- AC1: met — confirmed by the user: `systemic-refactoring.md`, **Competing explanations**
- AC2: met — confirmed by the user: `systemic-refactoring.md`, **Observation** and **Assumptions**
- AC3: met — confirmed by the user: `systemic-refactoring.md`, the **Confidence** levels and **What
  would change it**
- AC4: met — confirmed by the user: `systemic-refactoring.md`, "no numeric scores, weightings or
  probabilities"
- AC5: met — confirmed by the user: `systemic-refactoring.md`, the low-confidence rule after
  **Classify every finding**
- AC6: met — confirmed by the user: the on-evidence rule in `systemic-refactoring.md`, and steps 4
  and 5 of the on-evidence check in `/aido:2-implement`
- AC7: met — confirmed by the user: `/aido:assess-architecture` Step 2, `/aido:1-plan` Step 5 and the
  `/aido:2-implement` final checkpoint
- AC8: met — confirmed by the user: `/aido:assess-architecture` Step 4 body
- AC9: met — confirmed by the user: `/aido:assess-architecture` Step 3
- AC10: met — confirmed by the user: `/aido:assess-architecture` Steps 3 and 5
- AC11: met — `claude plugin validate .` and `claude plugin validate ./plugins/aido` passed. There is
  no committed test: the validators are the check
- AC12: met — a case-insensitive search of `plugins/aido/skills` and `plugins/aido/guidelines` found
  no match. There is no committed test, because one would have to name the model

Key decisions:

- **Assumptions** stays out of the `/aido:assess-architecture` issue body, as AC8 lists it. The user
  decided this twice, the second time after the final checkpoint argued for adding it
- `/aido:assess-architecture` findings have no classification, so a low-confidence finding that
  passes confirmation can still be offered as an issue, with its confidence shown. The user accepted
  this when confirming AC9 and AC10
- beyond the plan, from the final checkpoint and with the user's agreement: `/aido:1-plan` Step 6 now
  records each deferred finding with every field, so it agrees with `/aido:2-implement`. The entries
  under **Deferred** above predate this rule and were not rewritten
- the Step 2 return format in `/aido:assess-architecture` points at the guideline's fields rather
  than listing them, a different mechanism from the Design notes' wording, with the same outcome

Final Systemic Design Checkpoint: ran. Two findings were accepted or decided as above, and two were
no action. No Design note is contradicted by what was built.

Deferred refactorings: the three under **Deferred** in `## Design notes`, with their evidence and
reasons there.
