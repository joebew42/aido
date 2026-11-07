# Show the workflow as a diagram at the top of the README

## Context

The README shows aido's flow as the "Your first feature, in five steps" table, after the install
commands, so a reader has to read rows to see it. A workflow drawn in text, right below the pitch,
shows the whole flow at a glance, before any setup.

## Intent

Add a text diagram of the five-skill workflow right after the README's pitch. Under each stage, it
shows what you decide there, because aido's message is "AI does, you decide". The rest of the README
stays as it is.

## Out of scope

- shortening the README, or moving detail into a docs page
- removing or redrawing the "spec at the center" picture
- changing any skill, guideline or hook

## Acceptance criteria

- AC1: When the README is opened, a text diagram in a code block appears after the pitch, before "Get started".
- AC2: The diagram shows `/aido:1-plan` to `/aido:5-handle-review` in order, each with what the agent does.
- AC3: Under each stage, the diagram shows what you decide there.
- AC4: No line of the diagram is wider than 100 characters, so GitHub shows it without scrolling.
- AC5: Every other README section, the "five steps" table and the "spec at the center" picture stay unchanged.
- AC6 (manual): The diagram's boxes and columns line up on GitHub and in a terminal.
- AC7: The "human in the loop" picture is removed from the README and the repository.

## Plan

1. **docs — draw the workflow diagram under the README's pitch** (AC1, AC2, AC3, AC4, AC5, AC6) —
   inside-out: the stages follow the "five steps" table in `README.md`, and each stage's decisions
   follow `docs/readme/human-in-the-loop.svg`. Touches `README.md` only
   - five boxes connected by arrows, one per skill, each with a short line on what the agent does
   - under each box, the skill's name and the main decisions you make there
   - in a `text` code block just after the centred header, before "Get started"
   - check the width with a one-off command, and check alignment by viewing it on GitHub
2. **docs — remove the "human in the loop" picture** (AC5, AC7) — inside-out: the diagram now shows
   its decisions. Touches `README.md` and `docs/readme/human-in-the-loop.svg`

The enabling refactoring analysis was skipped.

## Progress

- [x] Item 1: workflow diagram under the README's pitch — two rows of boxes (stages 1–3, then 4–5),
  joined by a connector on the right, since one row of five does not fit in 100 columns
- [x] Item 2: "human in the loop" picture removed from the README and `docs/readme/`, at the user's
  request, because the diagram covered its decisions

Acceptance:

- AC1: met — one-off check: a `text` code block sits between the centred header and "Get started"
- AC2: met — one-off check: `/aido:1-plan` to `/aido:5-handle-review` appear in order, each box saying
  what the agent does
- AC3: deferred — the user removed the "you decide" lists from the diagram, finding them already
  stated; the README no longer lists each stage's decisions, and the Intent's line about them is not met
- AC4: met — one-off check: widest line is 99 characters
- AC5: met — one-off check: apart from the diagram and the removed picture, the README matches `main`
- AC6: met — confirmed by the user: the diagram viewed in a terminal; the later removal of the lists
  kept the same columns
- AC7: changed — added during implementation at the user's request; met — one-off check: the SVG
  file and its README reference are gone

Decisions:

- the criteria were checked with a throwaway script, not a committed test, as the plan asked
- the final design review was skipped
