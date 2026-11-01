---
description: Assesses the current repository's architecture area by area for evidence-backed systemic refactorings (duplicated knowledge, misplaced ownership, reinvented abstractions, crossed boundaries) and, for the findings the user picks, opens deduplicated GitHub issues. Invoked when the user wants to assess the architecture, find refactoring opportunities across the codebase, open refactoring issues, or runs /aiae:assess-architecture.
disable-model-invocation: false
---

# Assess the Architecture

Review the repository's design area by area, independent of any feature, and turn the findings
the user picks into GitHub issues. The issue tracker becomes the refactoring backlog.

This skill reads the repository and never edits it. Its only outward action is opening (or
commenting on) issues the user explicitly chose.

## Step 0: Load Context

- identify `<repo-name>` and the index directory as defined in **Index Location and Shape** in
  `${CLAUDE_PLUGIN_ROOT}/skills/map-architecture/SKILL.md`
- load `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md` — "Systemic Refactoring" defines what to look
  for and the evidence rule; "Architecture" and "Code Quality" hold the rules each finding is
  judged by — and `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`, then gather the host repository's
  conventions as it describes
- run `git fetch origin`, and check `gh repo view` works for this repository — if it does not,
  stop and tell the user why
- **no index** → `AskUserQuestion`: "This repo has no architecture index yet. The assessment needs
  one." — options **Run /aiae:map-architecture first** / **Cancel**. On the first, run that skill, then
  continue here
- **index stale** (see **Staleness** under **Index Location and Shape**) →
  `AskUserQuestion`: "The index was built `<n>` commits ago." — options **Update it first
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
- the "Systemic Refactoring" section and the rules it points to, copied from `code-standards.md`
  — the subagent has not loaded the guidelines
- to apply it inside the area **and** across its boundary with other areas (e.g. the same rule
  enforced in this area and another)
- to treat the index as a map only — read the code before claiming anything
- to group related findings in the area into one candidate issue, so the volume stays low
- never to edit files
- to return only this, per candidate issue:

  ```markdown
  ### <issue title, plain language, no prefix>
  - **Category:** duplicated knowledge | misplaced ownership | reinvented abstraction | crossed boundary
  - **Size:** S | M | L
  - **Observation:** what looks wrong
  - **Evidence:** `path` — `Symbol` (one line each)
  - **Impact:** why it matters for the design
  - **Recommendation:** the smallest useful refactoring
  - **Risk:** behaviour or consumers that could be affected
  ```

  followed by one line listing hypotheses it checked and rejected, so the user can see what was
  ruled out.

If `fable` is unavailable or the call is denied, run the same brief with the session's model and
say so in the presentation.

## Step 3: Present the Findings

Number every candidate across all areas and show them grouped by area: title, category, size and
evidence count, then the full detail of each. Close with the rejected hypotheses and which areas
had no findings.

If nothing was found, say so and stop — that is a valid result.

## Step 4: Pick the Issues

Nothing is opened in bulk without this choice.

- **4 candidates or fewer** → multi-select `AskUserQuestion`: "Which of these should become GitHub
  issues?" — one option per candidate title
- **more than 4** → `AskUserQuestion`: "Which of these should become GitHub issues?" — options
  **All** / **None** / **By number** (the user types the numbers)

On none, stop.

## Step 5: Check for Duplicates

For each picked candidate, search open issues by its key terms and main symbols:

```sh
gh issue list --state open --search "<terms> in:title,body" --limit 5
```

If one looks like the same problem, show it and `AskUserQuestion`: "#<n> `<title>` looks like the
same problem." — options **Skip** / **Comment the evidence on #<n>** / **Open a new issue anyway**.

## Step 6: Open the Issues

- labels: `gh label list --search refactor`. If the repo has a refactoring label, apply it; never
  create a label without asking
- write the body to a temporary file in the scratchpad and run
  `gh issue create --title "<title>" --body-file <file> [--label "<label>"]`
- body: the **Observation**, **Evidence**, **Impact**, **Recommendation** and **Risk** sections,
  ending with one line: "Found while assessing the architecture at `<short SHA>`."
- follow the PR description rules in `/aiae:4-create-pr` that apply to any GitHub body: plain, concise
  language; no hard-wrapped prose; no reference to Claude Code

## Step 7: Report

List each issue opened or commented on with its URL, each skipped candidate with the reason, and
any step that fell back from `fable` to the session model.

## STOP — Skill Complete

Do NOT refactor anything or edit the repository.
