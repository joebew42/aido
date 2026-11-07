---
description: Builds or refreshes a slim map of the current repository's architecture — its domain areas and the building blocks in each (infrastructure, application services, collaborators, aggregates, value objects, domain services) — stored locally under ~/.claude/repos/. Invoked when the user wants to map the architecture, warm up or update the architecture map or index, or runs /aido:map-architecture.
disable-model-invocation: false
---

# Map the Architecture

In Copilot CLI, resolve `${CLAUDE_PLUGIN_ROOT}` as two directories above the skill base directory,
then load `${CLAUDE_PLUGIN_ROOT}/guidelines/copilot-cli.md`.

Build (**warm-up**) or refresh (**update**) a slim map of the current repository. Design checks then
know *where* to look, instead of searching from scratch. The index is only a map: the code is the
truth, and every reader checks what it reads against the code.

This skill only reads the repository. It writes nothing inside it.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Step 0: Load Context

- read **Index Location and Shape** in `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md`. It
  says where the index lives and how each file this skill writes is shaped. Find `<repo-name>` and
  the index directory as it describes
- load `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`, whose "Architecture" section defines the
  roles, and `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`. Then gather the host
  repository's conventions as it describes. They may say how the roles map onto this codebase
- run `git fetch origin`. If the current branch isn't the default branch, or is behind it, use
  `AskUserQuestion`: "You're on `<branch>`, but the map should describe `<default-branch>`. Map this checkout anyway?" — options
  **Map the current checkout** / **Cancel**. The index records whichever commit it was built from
- if `.skip-map-architecture` exists, delete it. Running this skill explicitly overrides
  "never ask"

## Step 1: Choose the Mode

- no `architecture/README.md` → **warm-up** (Step 2)
- `README.md` exists → `AskUserQuestion`: "A map from `<short SHA>` on `<date>` already exists. What should I do with it?" — options **Update (Recommended)** — refresh only the areas changed
  since then (Step 3) / **Rebuild** — discard it and run a warm-up (Step 2)

## Step 2: Warm-Up

### 2a. Discover the areas — `fable` subagent

Launch one `Agent` with `model: "fable"`. Brief it to:

- survey the directory tree and namespaces, and the repo's `CLAUDE.md` and `AGENTS.md` files. Read
  no file bodies, apart from a small sample to confirm what a directory holds
- infer the domain areas from how the code is already grouped, such as `src/sharing/`, an
  `api.sharing` namespace or `apps/*/src/features/*`. Name them in the project's words
- return, per area: name, slug, a one-line responsibility, and the paths that belong to it. Add any
  significant paths that belong to no area, with a word on what they hold
- return only that list: no file contents, no exploration log

If `fable` is unavailable, act as "When the Model Is Unavailable" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md` describes.

### 2b. Confirm the areas

Show the proposed areas as a table, then `AskUserQuestion`: "Does this split into areas look
right?" — options **Looks right** / **Adjust**. On **Adjust**, the user describes the changes. Apply
them, show what changed as "Showing What Changed" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md`
describes, and ask again. Everything else builds on the areas, so a person checks them.

### 2c. Catalogue each area — `sonnet` subagents

Launch one `Agent` per area with `model: "sonnet"`, in parallel. Brief each with:

- the area's name, responsibility and paths, and the full area list, so it knows what belongs
  elsewhere
- the area file format and rules from **Index Location and Shape** in `architecture-index.md`,
  copied in full
- to write that area's two files, `<area-slug>.md` and `<area-slug>.extra.md`, directly to
  `~/.claude/repos/<repo-name>/architecture/areas/`. Then to reply with one line: the number of
  entries, and of **Doesn't fit** and **Observations** items

Subagents read the code and write only their own area's files. They never edit the repository.

If `sonnet` is unavailable, act as "When the Model Is Unavailable" in
`${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md` describes.

### 2d. Write `README.md`

Write the table from the confirmed areas. Record the full SHA of the commit that was mapped
(`git rev-parse HEAD`) and today's date. Then go to Step 4.

## Step 3: Update

1. read the recorded SHA from `README.md`. If `git cat-file -e <sha>` fails, because history was
   rewritten or pruned, say so and offer **Rebuild** / **Cancel** with `AskUserQuestion`
2. list the changes: `git diff --name-status <sha>..HEAD`
3. map each changed path to an area through the **Paths** column
4. paths that match no area: if they form a new top-level group, run 2a's `fable` subagent on those
   paths only, and confirm any new area as in 2b. Otherwise ignore them
5. an area whose paths no longer exist: delete its two files and its row
6. catalogue every affected or new area again, as in 2c. Rewrite its two files in full; don't patch
   them. An area that still has a single file from before the split is rewritten in the split format
7. update `README.md`: rows for added or removed areas, the new SHA and date

If nothing changed since the recorded SHA, say the index is current and stop.

## Step 4: Report

Tell the user, briefly:

- the index path, the mode run, and the commit it now describes
- the areas written or refreshed, and how many **Doesn't fit** and **Observations** items they
  hold
- which steps fell back from the planned model to the session's model, if any

Mention that `/aido:assess-architecture` can turn the index into reviewed refactoring findings.

Then end as "Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` describes. When
`/aido:1-plan` started this skill, return to it, and add no block.

## STOP — Skill Complete

Do NOT refactor anything, open issues, or edit the repository.
