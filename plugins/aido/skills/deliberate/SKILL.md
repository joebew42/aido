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

## Step 2: Two Independent Proposals — `fable` subagents

Each design agent works alone, so neither anchors on the other. Launch two `Agent` calls with
`model: "fable"`, in one message, so they run in parallel. One aims for **the best design**, the other
for **the simplest design**. Brief each with "The Shared Brief" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`, and:

- the same requirements, word for word, and the same repository: its root, and the host repository's
  agent instruction files to read
- the constraints from earlier rounds, if any, word for word
- `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`, copied in full. The agent hasn't loaded it
- if there is an architecture index, its directory and the **Reading the Index** steps from
  `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md`, copied in full. Find it as
  **Index Location and Shape** in `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md`
  describes. Never offer to build it here: that belongs to planning
- "The Proposal Brief" below, copied in full, with the agent's own objective
- nothing else from this session, and never the other agent's proposal

If `fable` is unavailable, act as "When the Model Is Unavailable" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md` describes. When no subagent can run at all, say that
deliberation needs independent agents, save nothing, and stop. One session playing both agents would
see both proposals.

### The Proposal Brief

Propose one design for the requirements below. Read the code before you claim anything about it.
Prefer what the repository already has: existing code to reuse, and the rules in its agent
instruction files. Your objective is one of these:

- **the best design** — the design that fits the domain and the repository best, and stays easy to
  change. It may cost more to build
- **the simplest design** — the least new code and the fewest new concepts that meet every
  requirement. It may leave later changes harder

Don't plan the work, and don't write code. Return only this:

```markdown
## <the best design | the simplest design>

- **Approach:** <the design, in a few sentences>
- **Rationale:** <why it meets the requirements and the objective>
- **Assumes:** <what it takes for granted about the requirements or the code>
- **Risks:** <what could go wrong, and what it would cost>
- **Repository constraints:** <the existing code and rules it rests on, as `path` — `Symbol`>
- **Implementation impact:** <what changes, by module or area, and roughly how much>
```

## STOP — Skill Complete

Once the decision is saved, end as "Ending a Skill" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes, with `Needs you: run /aido:1-plan`. It
resumes the draft and plans from the decision. Ask nothing more. When the skill stops early, end the
same way, and say that nothing was saved.
