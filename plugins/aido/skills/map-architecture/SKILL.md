---
description: Builds or refreshes a slim map of the current repository's architecture — its domain areas and the building blocks in each (infrastructure, application services, collaborators, aggregates, value objects, domain services) — stored locally under ~/.claude/repos/. Invoked when the user wants to map the architecture, warm up or update the architecture map or index, or runs /aido:map-architecture.
disable-model-invocation: false
---

# Map the Architecture

Build (**warm-up**) or refresh (**update**) a slim map of the current repository. Design checks then
know *where* to look, instead of searching from scratch. The index is only a map: the code is the
truth, and every reader checks what it reads against the code.

This skill only reads the repository. It writes nothing inside it.

Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.

## Index Location and Shape

```
~/.claude/repos/<repo-name>/
  .skip-map-architecture   # present only when the user chose "never ask for this repo"
  architecture/
    README.md                    # always read: build commit, one line per area
    areas/<area-slug>.md         # where the business rules live — searched, opened when central
    areas/<area-slug>.extra.md   # infrastructure, misfits, observations — assessment only
  refactoring-opportunities/     # not part of the index: see systemic-refactoring.md
```

- `<repo-name>` is the last path segment of the `origin` remote URL without `.git`, such as
  `git@github.com:acme/todo-app.git` → `todo-app`. Every worktree of a repo then shares one index.
  With no `origin`, use the basename of `git rev-parse --show-toplevel`, and say so.
- the index lives outside every repository and outside the plugin, so it survives plugin updates. It
  is derived from the code, and can always be rebuilt

### Staleness

An index is **stale** when more than 50 commits landed on the default branch after the commit it was
built from: `git rev-list --count <recorded SHA>..origin/<default-branch>`, after `git fetch origin`.
Skills that read the index offer an update past this threshold, and stay quiet below it.

### Reading the Index

Every entry is one line that stands alone: a name, a path, and for roles that own rules, the rule it
owns. So the index is cheaper to search than to read. A skill that uses it for a design check:

1. reads `README.md`
2. searches the area files for the domain's own terms from the spec or diff:
   `rg -i -n "<term>|<term>" ~/.claude/repos/<repo-name>/architecture/areas -g '!*.extra.md'`.
   Pass the directory, not a file glob: `rg` ignores `-g` for files named explicitly. Matches across
   areas are exactly the related rules worth checking
3. opens a whole `areas/<area-slug>.md` only for an area at the centre of the change, or when the
   matches leave its structure unclear
4. never reads the `.extra.md` files for a design check. Only `/aido:assess-architecture` needs them

The index is a map: check anything it says against the code before relying on it.

### `README.md`

```markdown
# <repo-name> architecture index

Built from `<full SHA>` on <YYYY-MM-DD>. The code is authoritative; this is a map.

| Area | Responsibility | Paths |
|---|---|---|
| [Sharing](areas/sharing.md) | TODO lists a user shares and the collaborators who can edit them | `src/sharing/`, `src/api/sharing/` |
```

Keep it to a single screen. If the repo has more areas than fit, the areas are too small. Merge
siblings instead of growing the table.

### `areas/<area-slug>.md` and `areas/<area-slug>.extra.md`

Each area is split in two, so a design check reads only where rules live:

```markdown
# Sharing

TODO lists a user shares and the collaborators who can edit them.

## Application services
- `ShareListService` — `src/sharing/share_list_service.ext` — gives a collaborator edit access to a list and sends them an invitation

## Collaborators
- `InvitationSender` — `src/sharing/invitation_sender.ext`

## Aggregates / entities
- `TodoList` — `src/lists/todo_list.ext` — a list of tasks owned by one user; decides who may edit it; also its own repository (ORM model)
```

```markdown
# Sharing — infrastructure and notes

## Infrastructure
- `ShareListEndpoint` — `src/api/sharing/share_list_endpoint.ext`
- `SmtpInvitationSender` — `src/sharing/smtp_invitation_sender.ext`
- `src/api/sharing/serializers/` — 14 serializers

## Doesn't fit
- `SharingHelpers` — `src/sharing/helpers.ext` — mixes query building and formatting

## Observations
- `InvitationJob` loads records and branches on a feature flag — decision-making in infrastructure that calls in
```

- **sections**, in this order, omitting empty ones:
  - `<area-slug>.md`: Application services, Collaborators, Aggregates / entities, Value objects,
    Domain services
  - `<area-slug>.extra.md`: Infrastructure, Doesn't fit, Observations

  Collaborators are the contracts inner code talks to, repositories included. Their implementations
  go under Infrastructure.

  The roles are the layers in "Architecture" in `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`.
  Where the host repository's `CLAUDE.md` or `AGENTS.md` maps them onto its own code, use that mapping
- **one entry per line**, never wrapped. Every line must make sense alone, as a search match
- **entries** are a name and a path, plus a description where business rules live:
  - **application services, domain services and aggregates / entities**: one short line naming the
    business rule or concept the entry owns, in the project's words. Say what it is responsible for,
    not how it works: "decides whether a collaborator may edit a shared list", not "loads the list and
    checks three flags". This lets a reader tell whether two entries with similar names enforce the
    same rule, without opening both
  - **every other role**: name and path only. Add a description only when the name doesn't already
    say what the thing does, the same bar as the Comments guideline
- **collapse volume, not meaning**: list application services, aggregates, value objects and domain
  services one by one. Collapse a directory of more than ~10 infrastructure entries, types or
  serializers into one line with a count
- **map the code as it is.** Something that doesn't fit one role cleanly goes under **Doesn't fit**,
  with a few words on why. Never force it into a role. Boundary violations noticed along the way go
  under **Observations**, as facts with a path, not as rules
- use the project's own words for area names and descriptions, as "don't invent domain vocabulary" in
  `code-standards.md` asks

## Step 0: Load Context

- find `<repo-name>` and the index directory, as above
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
- the area file format and rules from **Index Location and Shape**, copied in full
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
