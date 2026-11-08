# The Architecture Index

The architecture index is a slim map of a repository: its domain areas and the building blocks in
each. `/aido:map-architecture` builds and refreshes it. Planning, implementation and
`/aido:assess-architecture` read it. The index is only a map: the code is the truth, and every reader
checks what it reads against the code.

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

  The roles are the layers in "Architecture" in `code-standards.md`.
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
