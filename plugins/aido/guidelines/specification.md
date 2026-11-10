# The Feature Specification

## The Specification File

Each feature's specification lives in one file at the repository root, `SPEC.md` by default. Its
draft sits next to it, with `.draft` added (`SPEC.md.draft`). Some repositories have a `SPEC.md` of
their own, so every skill resolves the name once per run. The first rule that matches wins:

1. **The host repository names it** — its `CLAUDE.md` or `AGENTS.md` says where the feature
   specification goes (e.g. "the aido feature specification lives in `FEATURE-SPEC.md`"). Use that
   path
2. **The branch already has one** — the spec file is the file the branch's
   `docs: feature specification` commit added:
   `git log --format=%H --grep='^docs: feature specification$' <default-branch>..HEAD`, then
   `git show --name-only --format= <sha>`
3. **No clash** — `SPEC.md` does not exist on the default branch
   (`git cat-file -e origin/<default-branch>:SPEC.md` fails). Use `SPEC.md`
4. **A leftover** — the `SPEC.md` on the default branch is a spec an earlier feature left behind, as
   "A Leftover Spec" below describes. Use `SPEC.md`, and act as that section says
5. **Clash** — `SPEC.md` is the repository's own. Ask with `AskUserQuestion`: "This repository
   already has its own `SPEC.md`. Where should the feature specification go?" — options
   **`FEATURE-SPEC.md` (Recommended)** / **Another path**, which the user types. A path outside the
   root belongs to the repository, as "When the Spec Is Settled" describes. Never write to the
   repository's own `SPEC.md`

After a clash, offer to record the choice in the host repository's `CLAUDE.md`, or `AGENTS.md` if
that is the file it uses, so rule 1 answers it next time. Ask with `AskUserQuestion` — options
**Record it** / **Not now**. On **Record it**, add one line naming the path. Commit it on the feature
branch right after the spec commit, as `docs: name the feature specification file`.

Skills write **`SPEC.md`** and **`SPEC.md.draft`**: read them as the resolved spec file and its
draft.

The draft is refined with the user and is **never committed**. The spec file holds the approved
specification, then the plan and the design notes. It is committed first on the feature branch, as
"Special Cases" in `git-workflow.md` describes, and every later skill reads it.

**Never keep a draft next to its spec file.** Whenever you find both, or right after you create the
spec file, delete the draft and tell the user.

### A Leftover Spec

A branch merged without settling its spec leaves the spec file on the default branch. When the branch
has no `docs: feature specification` commit of its own, check the resolved path on the default branch,
rule 1's path included. The file there is a **leftover spec** when it has the marker line, or when
the commit that added the file there is `docs: feature specification`:

```
git show origin/<default-branch>:<path> | grep -qxF '> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.'
git log -1 --diff-filter=A --format=%s origin/<default-branch> -- <path>
```

The first succeeds, or the second prints `docs: feature specification`: it is a leftover. A file
added, removed and added again is judged by its latest add. A file with neither is the
repository's own, and never counts as a leftover.

On a leftover:

- **a skill about to write a new spec** writes nothing, and stops. It tells the user: "`<path>` on
  `<default-branch>` is a spec an earlier feature left behind. Remove it in its own PR, then run this
  again."
- **any other skill** says so in one line, and carries on

### Reading the Approved Specification

Once the commits are organized, the spec file may be reverted or distilled, as "Closing the
Specification" describes. Read it from where it is now:

- the spec file in the working tree. On an older branch, the path a
  `docs: move feature specification to <path>` commit moved it to
- otherwise, from the branch history, just before the `revert: docs: feature specification` commit:
  `git show <revert-sha>^:<spec-file>`. This holds for a distilled spec too: the distilled doc is not
  the spec

## The Specification Structure

Every skill that writes a specification uses this structure, and every skill that reads one relies
on it. Skills point here rather than restating it.

```markdown
# <descriptive title>

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

GitHub Issue: <repo link>/#<NUMBER>   (or omit)

## Context

<why the change is needed — the technical or product situation that calls for it>

## Intent

<what the change must achieve — not how>

## Out of scope

<what it deliberately does not do>

## Acceptance criteria

- AC1: When <trigger>, <what happens>.
- AC2 (manual): <one statement only a person can confirm>

## Alignment decisions

<added only when the engineer proceeds despite a significant misalignment>

## Plan

<added by planning>

## Design notes

<added by planning, when the enabling refactoring analysis ran>

## Refactorings

<added by implementation, when the user accepts a refactoring>

## Progress

<added by implementation>
```

**The marker line**, the quote under the title, tells any reader, aido user or not, that the file is
a working spec to remove before merging. Every spec has it, word for word, once. A spec written outside
the root of the host repository has none: it belongs to the repository. A spec written before the
marker line existed has none either, and stays valid.

**The specification states what and why, never how.** Context, Intent, Out of scope and Acceptance
criteria are approved before any planning. How the change is built belongs to `## Plan` and
`## Design notes`. A skill may add its own sections after the title, such as where the original work
came from. The required sections keep their names and order.

**The specification is quick to read.** It follows `language.md`. Context and Intent aim for about 3
sentences each, and may run over when the content needs it. File names and symbols stay in the plan,
unless a criterion is about that file.

### Acceptance Criteria

- number them `AC1`, `AC2`, … in order. An ID is never renumbered or reused, even when a criterion
  is changed or deferred: other sections and the commit history refer to it
- each one is a single, specific statement that can be checked: a behaviour, not a task
- one with a trigger uses a when/then shape: `AC1: When a task is completed, it moves to the Done
  list.` One with no trigger is one plain sentence: `AC2 (manual): The Done list is easy to scan.`
- aim for about 20 words. Go over only when the criterion would otherwise stop being checkable
- one an automated test can check is **automatable**, with no marker. One only a person can confirm,
  such as documentation that reads well, is **manual**, marked `(manual)` after its ID
- group a long list under short plain-text labels. The numbering stays continuous
- in a specification split into phases, a phase carries only the criteria it delivers, with their
  original IDs

### Alignment Decisions

`## Alignment decisions` records each significant misalignment (see `repository-alignment.md`) the
engineer chose to proceed with, one line each, so later checks don't raise it again:

- `<the conflict, with the file that shows it> — proceeding because <the engineer's reason>`

### Plan Items

Each item in `## Plan` names the criteria it serves, in parentheses after its title, e.g.
`1. **domain — let a list be shared** (AC1, AC3)`. Every criterion is served by at least one item.
An enabling refactoring serves none, and says so: `(enabling)`. Items use short sentences.

These rules apply to the plan of a feature or a phase. The phases of a main plan, written by
`/aido:multi-phase-spec-pr`, only name the criteria they deliver.

- each item names the layers it touches: domain, application service, or infrastructure (see
  "Architecture" in `code-standards.md`)
- every feature item, meaning any item not marked `(enabling)`, names its mode and the reason for it
  after its title, as "The Modes" in `tdd.md` defines them:
  - `inside-out` cites the existing code or known contract it conforms to
  - `outside-in` names its unknown and lists its slices in order, with any guard such as
    authorization in the first slice
  - `in-unit` names the unknown logic
- enabling refactorings come first, each as its own `refactor:` item
- the rest is ordered by dependency: an outside-in item comes before any inside-out item relying on
  the contract it discovers. Otherwise the order is inside-out: domain → application → infrastructure,
  with what inner code calls out to before what calls in

```markdown
1. **refactor: extract the task store** (enabling) — infrastructure
2. **complete a task** (AC1) — inside-out: follows `add_task` in `lib/tasks.sh`. Touches domain,
   application
3. **sync tasks to the calendar** (AC2, AC3) — outside-in: the provider's error responses are
   unconfirmed. Touches application, infrastructure
   - slice 1: a completed task reaches the provider, through the authorization check
   - slice 2: a rejected sync is reported to the user
4. **repeat a task monthly** (AC4) — in-unit: the month-end rule is unsettled. Touches domain
```

### Refactorings

`## Refactorings` holds the refactorings the user accepted during implementation. They are built
later, like plan items:

- each one has a code, `r1`, `r2`, …, in the order they are recorded. A refactoring's code is never
  renumbered or reused, like a criterion's ID
- each one keeps every field under **What every finding states** in `systemic-refactoring.md`
- each one is a `refactor:` item: it serves no criterion and has no mode. It is done once its line is
  ticked, as "Items in Progress" describes
- refactorings found by planning stay plan items, marked `(enabling)`, with no `r` code

```markdown
### r1. <title>

- **Change:** …
- **Why:** …
- **Where:** `lib/tasks.sh` — `add_task`
- **Confidence:** high
- **Risk:** …
```

### Acceptance in Progress

`## Progress` records each criterion that has been checked, one line each:

- `AC1: met — <test that covers it>`
- `AC2: met — confirmed by the user: <what was shown>`
- `AC3: changed — <what changed and why>` (the criterion in `## Acceptance criteria` is updated too)
- `AC4: deferred — <why>`
- `AC5: unchecked` — its plan items are not done yet

These lines go under a `### Acceptance` heading, the last heading in `## Progress`. They come after
the items and every other note, so they don't read as part of the last item:

```markdown
## Progress

- [x] 1. complete a task
  - `Task.complete` refuses a task already completed

### Acceptance

- AC1: met — `completing a task moves it to the Done list`
- AC2: unchecked
```

A specification no implementing session has recorded progress for has no `### Acceptance` heading.
Once one has, every criterion has a line there, `unchecked` until it is checked.

### Items in Progress

`## Progress` ticks each item that is done, plan item or refactoring alike, on one line with its code
and title. `/aido:2-implement` reads these lines to know what is left:

- `- [x] <code>. <title>`, such as `- [x] 3. list the open tasks` or `- [x] r1. <title>`

An item is done only when its line is ticked. An item not done yet has no line, or an unticked one:
`- [ ] 4. <title>`.

### Modes and Slices in Progress

`## Progress` records what was built where it differs from, or adds to, the plan.
`/aido:3-organize-commits` shapes the history from it:

- `Item 3 mode changed: outside-in → inside-out — <why>`
- `Item 3 slices built: <slice>; <slice>`

### Specifications Without Acceptance Criteria

A specification approved before this structure existed may have no `## Acceptance criteria` section,
or criteria without `AC` numbers. Skills then verify the plan alone, check no criteria, and ask
nothing about them.

## Closing the Specification

The spec file lives as long as its branch. Before the branch is merged, the skill that settles it asks
what happens to it. The answer becomes the branch's **last** commit, the **outcome commit**.

### When the Spec Is Settled

No skill asks about the spec when:

- the branch has no spec
- the spec is already settled
- the branch is a main plan branch, whose name contains `main-plan-`. Its spec stays for the phases
- the spec file lives outside the root of the host repository. It belongs to the repository, which
  decides what happens to it

The spec is **settled** when an outcome commit comes after the branch's `docs: feature specification`
commit, found by rule 2 of "The Specification File":

```
git log --format=%s -E --grep='^(revert: docs: feature specification$|docs: move feature specification to )' <spec-sha>..HEAD
```

Any line it prints means settled: a revert, or an older move commit. The outcome commit is
the last commit when it is made. Later commits, such as review fixes, don't reopen it.

### Settling It

By default, **revert** it. The specification then stays in the branch history, but leaves no file
behind. What lasts beyond the branch, such as the problem and the decisions, can be **distilled**
into the repository's docs first. The plan and the progress describe one moment, and are never kept.

**Find where a distilled doc would belong**, in this order:

1. the host repository's `CLAUDE.md` or `AGENTS.md`: a place they name for specifications, design
   documents, decision records or other docs
2. an existing documentation folder, such as `docs/specs/`, `docs/design/`, `docs/adr/` or `docs/`.
   Name and place the file the way the files already there are. An existing doc on the same topic
   counts too
3. no documentation folder → offer only the default and a path the user types

Name a new file after the feature, in the folder's own style, such as
`docs/specs/shared-todo-lists.md`. Never overwrite an existing file: distilling into one adds to it.

**Ask** with `AskUserQuestion`: "What should happen to `SPEC.md` once the feature is done?" —
options:

- **Revert it (Recommended)** — the last commit is `revert: docs: feature specification`
- **Distil it into `<path>`** — one option per place found above, up to two. Each description says
  why that place fits, and that the spec itself is still reverted
- the user can always type a different path to distil into

The answer gives the last commits:

- **revert** → `revert: docs: feature specification`
- **distil** → write the distilled text, then show it whole and ask with `AskUserQuestion` —
  options **Approve it** / **Adjust it** / **Revert only**, so the user approves it before it is
  committed. In the same call, ask whether to include the acceptance criteria — options **Leave them
  out** / **Include them**. Commit it as `docs: distil feature specification into <path>`. The revert
  still follows, as the last commit, and is the outcome commit

**The distilled text** states the problem, from Context, and the decisions, from Intent, Out of
scope, the alignment decisions and the key decisions in `## Progress`, with the acceptance criteria
only if the user wants them. It follows `language.md`, and reads as the repository's doc, not as a
spec. The distilled text holds no plan, progress, design notes, refactorings or marker line.
