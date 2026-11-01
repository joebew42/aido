# Add a small-change path and starting from a conversation to /aiae:1-plan

GitHub Issue: https://github.com/joebew42/ai-augmented-engineer/#9

## Context

A comparison with widely adopted agentic workflows found two practices worth adopting in
`/aiae:1-plan`. They follow the work on making the skills and guidelines more concise, so they are
added to a smaller workflow.

`/aiae:1-plan` has one full route for a change of any size: the draft, the specification and the
plan are each approved separately, and the enabling refactoring analysis is offered along the way.
BMAD sends clear changes directly to implementation, and Superpowers agrees small changes in chat
rather than in a written design document.

`/aiae:1-plan` also needs a GitHub issue or a draft the user has already written. Superpowers,
mattpocock/skills and OpenSpec can start from a conversation that clarifies the intent.

Sources: [BMAD](https://github.com/bmad-code-org/BMAD-METHOD),
[Superpowers](https://github.com/obra/superpowers),
[mattpocock/skills](https://github.com/mattpocock/skills),
[OpenSpec](https://github.com/Fission-AI/OpenSpec)

## Intent

A small, clear change gets a lighter route through `/aiae:1-plan` that still ends with the user's
approval, and still leaves a `SPEC.md` for the later skills to work from.

A user without an issue or a written draft can start `/aiae:1-plan` from a conversation, in which
the skill interviews them and writes `SPEC.md.draft` itself.

## Out of scope

- agreeing a small change in chat with no `SPEC.md`: `/aiae:2-implement` and the later skills keep
  relying on the file, and do not change
- the small-change path for a phase of a multi-phase project: phases keep the full route
- starting from a conversation in `/aiae:multi-phase-spec-pr` and `/aiae:stabilize`
- replacing the screenshot `docs/plan-asks-for-the-spec.png`, which keeps showing two options until
  someone retakes it

## Acceptance criteria

Starting from a conversation

- AC1 (manual): when asked how to provide the specification in the standalone flow, `/aiae:1-plan`
  offers three options: GitHub issue, writing it yourself, and starting from a conversation
- AC2 (manual): starting from a conversation, the skill first asks openly what the user wants to
  change and why, then asks follow-up questions in groups until nothing blocks writing the draft,
  and reads the code rather than asking when the code can answer
- AC3 (manual): the interview ends with the skill writing `SPEC.md.draft` itself, after which the
  flow continues the same way as for the other two options

The small-change path

- AC4 (manual): for a standalone change, with any of the three sources, once the draft exists the
  skill says whether the change looks small and clear, gives its reasons, and asks the user which
  route to take; the user can choose either route whatever the skill proposes
- AC5 (manual): a change is proposed as small and clear only when it has no open decision, touches
  one module or area, and introduces no new domain concept or abstraction
- AC6 (manual): on the small-change path, the user sees the brief specification and the plan
  together and approves them once, with no separate approval of the draft, the specification or the
  plan
- AC7 (manual): the small-change path does not ask about or run the enabling refactoring analysis,
  and `SPEC.md` records `The enabling refactoring analysis was skipped.`
- AC8 (manual): the `SPEC.md` of the small-change path has the required sections in the required
  order and numbered acceptance criteria, each served by a plan item, and it is committed on a
  feature branch as `docs: feature specification`, so `/aiae:2-implement` runs on it unchanged
- AC9 (manual): if, on the small-change path, an open decision appears or the user declines the
  single approval because the change is bigger than it looked, the skill can move to the full route
  without losing the draft
- AC10 (manual): a phase of a multi-phase project is not offered the small-change path

Documentation and the repository's rules

- AC11 (manual): the README describes the three ways to provide the specification and the
  small-change path, including where it says `/aiae:1-plan` asks where the specification comes from
- AC12 (manual): every reference to a step of `/aiae:1-plan` from another skill still points at the
  step it means
- AC13: `version` in `plugins/aiae/.claude-plugin/plugin.json` is bumped following semantic
  versioning
- AC14: `claude plugin validate .` and `claude plugin validate ./plugins/aiae` both pass

## Plan

This repository holds Markdown skills, not layered code, so each item names the file it changes
instead of a layer. Steps of `/aiae:1-plan` keep their numbers: the new parts are named sections
inside existing steps, so references from other skills stay valid.

1. **`skills/1-plan/SKILL.md` — start from a conversation** (AC1, AC2, AC3)
   - add a third option to the question in "Standalone Project Flow"
   - describe the interview: an open first question, grouped follow-ups with `AskUserQuestion`, the
     code read where it can answer, and `SPEC.md.draft` written once nothing blocks it
2. **`skills/1-plan/SKILL.md` — choose the route** (AC4, AC5, AC10)
   - add a "Choose the route" section to Step 2, between the standalone flow and "Approve the
     draft": the proposal with its reasons, the definition of small and clear, and the user's choice
   - the multi-phase flow never reaches this section
   - in Step 1, resuming a standalone `SPEC.md.draft` goes through this section first, so a resumed
     draft is offered the route too
3. **`skills/1-plan/SKILL.md` — the small-change route** (AC6, AC7, AC8, AC9)
   - add a "Small-Change Route" section: write the brief specification in the required structure,
     with the plan and the skipped-analysis line, into `SPEC.md.draft`
   - one `AskUserQuestion` approval, with an option to move to the full route at Step 3, keeping the
     draft; moving on when an open decision appears works the same way
   - on approval, `mv SPEC.md.draft SPEC.md` and continue at Step 7, whose checks hold unchanged
   - mention the route in "The Specification Files", where the stages are listed as strictly in
     order, and in the skill's `description`
4. **`README.md` — describe both additions** (AC11)
   - the three sources, in "You stay in the loop" and "A simple feature"
   - the small-change path, in "A simple feature" and in the principle that every feature is
     planned in stages
   - the screenshot and its alt text stay as they are, since the alt text still describes the image
5. **Check the references to `/aiae:1-plan` steps** (AC12)
   - confirm `/aiae:stabilize` (Steps 3, 6, 8) and `/aiae:multi-phase-spec-pr` (Step 2's "Approve
     the draft", and Step 3) still point at what they mean
6. **`plugins/aiae/.claude-plugin/plugin.json` — bump the version to 1.3.0 and validate** (AC13,
   AC14)
   - a minor bump, because the skill gains backward-compatible behaviour

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. start from a conversation
- [x] 2. choose the route
- [x] 3. the small-change route
- [x] 4. README
- [x] 5. references to `/aiae:1-plan` steps: no change needed, since no step was renumbered
- [x] 6. version 1.3.0 and validation

Acceptance criteria:

- AC1: met — confirmed by the user: `skills/1-plan/SKILL.md`, "Standalone Project Flow"
- AC2: met — confirmed by the user: `skills/1-plan/SKILL.md`, "Interview the user"
- AC3: met — confirmed by the user: `skills/1-plan/SKILL.md`, "Interview the user"
- AC4: met — confirmed by the user: `skills/1-plan/SKILL.md`, "Choose the route"
- AC5: met — confirmed by the user: `skills/1-plan/SKILL.md`, "Choose the route"
- AC6: met — confirmed by the user: `skills/1-plan/SKILL.md`, "Small-Change Route"
- AC7: met — confirmed by the user: `skills/1-plan/SKILL.md`, "Small-Change Route"
- AC8: met — confirmed by the user: `skills/1-plan/SKILL.md`, "Small-Change Route" and Step 7
- AC9: met — confirmed by the user: `skills/1-plan/SKILL.md`, "Small-Change Route"
- AC10: met — confirmed by the user: `skills/1-plan/SKILL.md`, "Choose the route"
- AC11: met — confirmed by the user: `README.md`
- AC12: met — confirmed by the user: step headings unchanged, references in `/aiae:stabilize` and
  `/aiae:multi-phase-spec-pr` read
- AC13: met — `plugin.json` is at 1.3.0, and no other file mentions 1.2.1
- AC14: met — both `claude plugin validate` commands pass, with the existing missing-icon warning

Manual criteria were confirmed from the skill text; the new routes have not been run end to end.

Key decisions:

- this repository has no test suite or linter, so items were written directly, with no TDD cycles
- moving to the full route removes `## Plan` and the skipped-analysis line from the draft, because
  Steps 4 to 6 redo them and Step 3 would otherwise treat them as content that fits no section
- a resumed standalone draft goes through "Choose the route" first

The final Systemic Design Checkpoint was skipped by the user. No refactorings were deferred.
