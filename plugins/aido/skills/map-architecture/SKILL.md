---
description: Builds or refreshes a slim architecture index of the current repository — its domain areas and the building blocks in each (infrastructure, application services, collaborators, aggregates, value objects, domain services) — stored locally under ~/.claude/repos/. Invoked when the user wants to map the architecture, warm up or update the architecture index, or runs /aido:map-architecture.
disable-model-invocation: false
---

# Map the Architecture

Build (**warm-up**) or refresh (**update**) a slim map of the current repository, so systemic
design checks know *where* to look instead of searching from scratch. The index is a navigation
aid: the source code stays authoritative, and every consumer verifies what it reads against it.

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

- `<repo-name>` is the last path segment of the `origin` remote URL without `.git` (e.g.
  `git@github.com:acme/todo-app.git` → `todo-app`), so every worktree of a repo shares one
  index. With no `origin`, use the basename of `git rev-parse --show-toplevel` and say so.
- the index lives outside every repository and outside the plugin, so it survives plugin updates;
  it is derived and can always be rebuilt

### Staleness

An index is **stale** when more than 50 commits on the default branch landed after the commit it was built
from: `git rev-list --count <recorded SHA>..origin/<default-branch>`, after `git fetch origin`. Skills that
read the index offer an update past this threshold, and stay quiet below it.

### Reading the Index

Every entry is one self-contained line — name, path and, for rule-owning roles, the rule it owns —
so the index is cheaper to search than to read. Skills that use it for a design check:

1. read `README.md`
2. search the area files for the domain's own terms from the spec or diff:
   `rg -i -n "<term>|<term>" ~/.claude/repos/<repo-name>/architecture/areas -g '!*.extra.md'`
   (pass the directory, not a file glob — `rg` ignores `-g` for files named explicitly)
   — matches across areas are exactly the related rules worth checking
3. open a whole `areas/<area-slug>.md` only for an area at the centre of the change, or when the
   matches leave its structure unclear
4. never read the `.extra.md` files for a design check — only `/aido:assess-architecture` needs them

The index is a map: verify anything it says against the code before relying on it.

### `README.md`

```markdown
# <repo-name> architecture index

Built from `<full SHA>` on <YYYY-MM-DD>. The code is authoritative; this is a map.

| Area | Responsibility | Paths |
|---|---|---|
| [Sharing](areas/sharing.md) | TODO lists a user shares and the collaborators who can edit them | `src/sharing/`, `src/api/sharing/` |
```

Keep it to a single screen. If the repo has more areas than fit, the areas are too fine-grained —
merge siblings rather than growing the table.

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

  Collaborators are the contracts inner code talks to, repositories included; their implementations
  go under Infrastructure.

  The roles are the layers in "Architecture" in `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md`; where the
  host repository's `CLAUDE.md` or `AGENTS.md` maps them onto its own code, use that mapping
- **one entry per line**, never wrapped — every line must make sense as a search match on its own
- **entries** are a name and a path, plus a description where business rules live:
  - **application services, domain services and aggregates / entities** — one short line naming
    the business rule or concept the entry owns, in the project's words. Say what it is
    responsible for, not how it works: "decides whether a collaborator may edit a shared list",
    not "loads the list and checks three flags". This is what lets a reader tell
    whether two similarly named entries enforce the same rule without opening both
  - **every other role** — name and path only; add a description only when the name does not
    already say what the thing does, the same bar as the Comments guideline
- **collapse volume, not meaning**: list application services, aggregates, value objects and
  domain services one by one; collapse a directory of more than ~10 infrastructure entries, types or
  serializers into one line with a count
- **map the code as it is.** Something that does not fit one role cleanly goes under **Doesn't
  fit** with a few words on why — never force it into a role. Boundary violations noticed along the
  way go under **Observations**, as facts with a path, not as rules
- use the project's own vocabulary for area names and descriptions — see "don't invent domain
  vocabulary" in `code-standards.md`

## Step 0: Load Context

- identify `<repo-name>` and the index directory as above
- load `${CLAUDE_PLUGIN_ROOT}/guidelines/code-standards.md` (the "Architecture" section defines the roles) and
  `${CLAUDE_PLUGIN_ROOT}/guidelines/project-conventions.md`, then gather the host repository's conventions as it
  describes — they may say how the roles map onto this codebase
- run `git fetch origin`. If the current branch is not the default branch, or is behind it, use
  `AskUserQuestion`: "The index should describe the default branch, `<default-branch>`. You're on `<branch>`." — options
  **Map the current checkout** / **Cancel**. The index records whichever commit it was built from
- if `.skip-map-architecture` exists, delete it — running this skill explicitly overrides
  "never ask"

## Step 1: Choose the Mode

- no `architecture/README.md` → **warm-up** (Step 2)
- `README.md` exists → `AskUserQuestion`: "An index built from `<short SHA>` on `<date>` exists.
  What would you like to do?" — options **Update (Recommended)** — refresh only the areas changed
  since then (Step 3) / **Rebuild** — discard it and run a warm-up (Step 2)

## Step 2: Warm-Up

### 2a. Discover the areas — `fable` subagent

Launch one `Agent` with `model: "fable"`. Brief it to:

- survey the directory tree and namespaces — not file bodies, apart from a small sample to confirm
  what a directory holds — plus the repo's `CLAUDE.md` and `AGENTS.md` files
- infer the domain areas from how the code is already grouped (e.g. `src/sharing/`,
  an `api.sharing` namespace, `apps/*/src/features/*`), named in the project's vocabulary
- return, per area: name, slug, a one-line responsibility, and the paths that belong to it; plus
  any significant paths that belong to no area, with a word on what they hold
- return only that list — no file contents, no exploration log

If `fable` is unavailable or the call is denied, run the same brief with the session's model and
say so in the final report.

### 2b. Confirm the areas

Show the proposed areas as a table, then `AskUserQuestion`: "Does this split into areas look
right?" — options **Looks right** / **Adjust** (the user describes the changes; apply them and ask
again). Area boundaries are the decision everything else builds on, so they get a human check.

### 2c. Catalogue each area — `sonnet` subagents

Launch one `Agent` per area with `model: "sonnet"`, in parallel. Brief each with:

- the area's name, responsibility and paths, and the full area list (so it knows what belongs
  elsewhere)
- the area file format and rules from **Index Location and Shape**, copied in full
- to write that area's two files, `<area-slug>.md` and `<area-slug>.extra.md`, directly to
  `~/.claude/repos/<repo-name>/architecture/areas/`, and to reply with one line: the number of
  entries and of **Doesn't fit** and **Observations** items

Subagents read the code and write only their own area's files. They never edit the repository.

If `sonnet` is unavailable or the call is denied, run the same brief with the session's model and
say so in the final report.

### 2d. Write `README.md`

Write the table from the confirmed areas, recording the full SHA of the commit that was mapped
(`git rev-parse HEAD`) and today's date. Then go to Step 4.

## Step 3: Update

1. read the recorded SHA from `README.md`. If `git cat-file -e <sha>` fails (history rewritten or
   pruned), say so and offer **Rebuild** / **Cancel** with `AskUserQuestion`
2. list the changes: `git diff --name-status <sha>..HEAD`
3. map each changed path to an area through the **Paths** column
4. paths that match no area: if they form a new top-level grouping, run 2a's `fable` subagent
   scoped to those paths only, and confirm any new area as in 2b; otherwise ignore them
5. an area whose paths no longer exist: delete its two files and its row
6. re-catalogue every affected or new area as in 2c — a full rewrite of that area's two files, not
   a patch. An area that still has a single file from before the split is rewritten in the split
   format
7. update `README.md`: rows for added or removed areas, the new SHA and date

If nothing changed since the recorded SHA, say the index is current and stop.

## Step 4: Report

Tell the user, briefly:

- the index path, the mode run, and the commit it now describes
- the areas written or refreshed, and how many **Doesn't fit** and **Observations** items they
  hold
- which steps fell back from the planned model to the session model, if any

Mention that `/aido:assess-architecture` can turn the index into reviewed refactoring findings.

## STOP — Skill Complete

Do NOT refactor anything, open issues, or edit the repository.
