---
description: Explores competing designs for a feature before planning — two agents propose a design independently, one aiming for the best design and one for the simplest, and a third compares them and recommends one. Saves the design the developer approves in SPEC.md.draft for /aido:1-plan to plan from. Invoked when the user wants to deliberate on a design, compare design alternatives before planning, or runs /aido:deliberate.
disable-model-invocation: false
---

# Deliberate on the Design

**In Copilot CLI only:** before anything else, read `guidelines/copilot-cli.md` in the plugin root, two folders above this skill's base directory, and follow it. Read every guideline this skill names whole, with `view`, one file per call.

Weigh competing designs before planning. Two agents propose a design for the same requirements, each
on its own. A third compares them and recommends one. The design the developer approves is saved in
`SPEC.md.draft`, and `/aido:1-plan` plans from it. This step is optional: planning without it works
as before.

Resolve `SPEC.md` and `SPEC.md.draft` first, as "The Specification File" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

This skill writes only `SPEC.md.draft`, and only once the developer approves a design. It changes no
code, commits nothing and pushes nothing.

## Step 0: Load Context

- run `git fetch origin`
- load `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` and
  `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`. Gather the host repository's conventions
  as the latter describes
- on a leftover spec, stop, as "A Leftover Spec" in
  `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md` describes
- **`SPEC.md` exists** → say the specification is already approved, and stop without deliberating.
  Delete a `SPEC.md.draft` next to it first, as "The Specification File" says

## Step 1: Find the Requirements

The argument decides what to deliberate on:

- **a GitHub issue**, as a number or a link → read it with `gh issue view <NUMBER>`. The
  requirements are its title and body
- **a feature request**, any other text → the requirements are the request, as given
- **nothing, and `SPEC.md.draft` exists** → deliberate on the draft
- **nothing, and no draft** → ask in free text what the feature should do, and why

When an issue or a request is given while `SPEC.md.draft` exists, ask with `AskUserQuestion`:
"`SPEC.md.draft` already exists. Which requirements should I deliberate on?" — options
**Use the draft** / **Replace it with the request**. On **Replace it with the request**, the draft
stays untouched until a design is approved.

## STOP — Skill Complete

Once the decision is saved, end as "Ending a Skill" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, with `Needs you: run /aido:1-plan`. It
resumes the draft and plans from the decision. Ask nothing more. When the skill stops early, end the
same way, and say that nothing was saved.
