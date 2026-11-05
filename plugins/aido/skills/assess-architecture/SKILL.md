---
description: Assesses the current repository's architecture area by area for evidence-backed systemic refactorings (duplicated knowledge, misplaced ownership, reinvented abstractions, crossed boundaries) and parks the findings the user picks as refactoring opportunities, for a later planned change to pull in. Invoked when the user wants to assess the architecture, find refactoring opportunities across the codebase, or runs /aido:assess-architecture.
disable-model-invocation: false
---

# Assess the Architecture

Review the repository's design area by area, independent of any feature, and park the findings the
user picks as refactoring opportunities. `/aido:1-plan` offers them when a planned change can
include them, so each refactoring is made as part of a working feature.

This skill reads the repository and never edits it. It writes only the opportunity files the user
explicitly chose, which live outside the repository.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Step 0: Load Context

- identify `<repo-name>` and the index directory as defined in **Index Location and Shape** in
  `${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md`
- load `${CLAUDE_PLUGIN_ROOT}/guidelines/systemic-refactoring.md`, which defines what to look for, the
  evidence rule and how to park an opportunity, `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`, whose "Architecture" and "Code Quality" hold the
  rules each finding is judged by, and `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`, then gather the host repository's conventions as it
  describes
- run `git fetch origin`
- **no index** → `AskUserQuestion`: "This repository has no map of its architecture, and the assessment needs one. Should I build it first?" — options **Run /aido:map-architecture first** / **Cancel**. On the first, run that skill, then
  continue here
- **index stale** (see **Staleness** under **Index Location and Shape**) →
  `AskUserQuestion`: "The architecture map is `<n>` commits old. Should I update it first?" — options **Update it first
  (Recommended)** / **Assess with it as is**

## Step 1: Choose the Scope

Read `architecture/README.md` and show its areas. Then `AskUserQuestion`: "Which areas should I
assess?" — options **All areas** / **Specific areas** (the user names them).

## Step 2: Assess Each Area — `fable` subagents

Launch one `Agent` per area with `model: "fable"`, in parallel. Brief each with:

- the area's two file paths (`<area-slug>.md` and `<area-slug>.extra.md` — the second holds the
  infrastructure, misfits and observations this assessment needs), the `README.md` path, and
  the repository root
- to look across the area boundary by searching the other areas' files for this area's rules and
  terms, as in **Reading the Index** in `${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md` — not by
  reading them whole
- `systemic-refactoring.md` and the rules it points to in `code-standards.md`, copied
  — the subagent has not loaded the guidelines
- to apply it inside the area **and** across its boundary with other areas (e.g. the same rule
  enforced in this area and another)
- to treat the index as a map only — read the code before claiming anything
- to group related findings in the area into one candidate, so the volume stays low
- never to edit files
- to return only this, per candidate:

  ```markdown
  ### <title, plain language, no prefix>
  - **Category:** duplicated knowledge | misplaced ownership | reinvented abstraction | crossed boundary
  - **Size:** S | M | L
  - **Impact:** why it matters for the design
  - every field under **What every finding states** in `systemic-refactoring.md`
  ```

  followed by one line listing hypotheses it checked and rejected, so the user can see what was
  ruled out.

If `fable` is unavailable or the call is denied, run the same brief with the session's model and
say so in the presentation.

## Step 3: Confirm and Present the Findings

Confirm each finding before presenting it, as **Evidence before action** in
`systemic-refactoring.md` describes. A finding the code does not support is dropped, and is not
offered for parking.

Number every confirmed candidate across all areas and show them grouped by area: title, category,
size and evidence count, then the full detail of each. Close with the dropped findings, each with
the reason it was dropped and outside the numbering, the rejected hypotheses, and which areas had no
findings.

If no finding was found or confirmed, say so, list any dropped findings, and stop — that is a valid
result.

## Step 4: Park the Opportunities

Ask which of the numbered candidates shown in Step 3 to park:

- **4 candidates or fewer** → multi-select `AskUserQuestion`: "Which of these should I save for later?" — one option per title
- **more than 4** → `AskUserQuestion`: "Which of these should I save for later?"
  — options **All** / **None** / **By number** (the user types the numbers)

Park each picked candidate as **Parking an opportunity** in `systemic-refactoring.md` describes. Its
**Category** names the design smell, and its **Impact** is why it matters. When a file with the same
evidence already exists, show it and `AskUserQuestion`: "`<file>` looks like the same refactoring idea. What should I do?"
— options **Skip** / **Replace it**.

## Step 5: Report

List each opportunity parked with its file path, each skipped candidate with the reason, each
dropped finding with the reason, and any step that fell back from `fable` to the session model.

## STOP — Skill Complete

Do NOT refactor anything or edit the repository.
