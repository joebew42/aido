# Code Standards

## Development Approach

### Test-Driven Methodology (Red-Green-Refactor, one test at a time)
- this is *test-driven*, not *test-first*: grow tests and implementation together, one small
  behavior per cycle — never write a whole spec file up front and satisfy it all at once
- add or change existing tests for each change made
- add only the most valuable and relevant tests
- run tests every time a change is added

#### The Red-Green-Refactor Cycle
Each cycle covers exactly **one** new behavior. A class or service is built from a *sequence* of
these cycles, not a single big one.

0. **PRE-RED**: Before adding the first test to an existing suite, run it to confirm it starts GREEN
1. **RED**: Write **one** failing test for the next smallest behavior — nothing more. Watch it
   fail for the right reason before writing any implementation.
2. **GREEN**: Write the **minimum** code to make that one test pass. Prefer, in order:
   - **Fake it** — return a constant when one test can't yet justify real logic
   - **Triangulate** — let the next test force you to generalize the fake
   - **Obvious implementation** — write the real thing directly only when it is trivial

   Do not implement behavior that no current test demands (no speculative generalization).
3. **REFACTOR**: After tests pass, review code and refactor if needed:
   - check for code smells, SOLID violations, abstraction issues
   - refactor while keeping tests green
   - commit stand-alone refactoring separately from feature work

   Then return to RED for the next behavior.

#### Test-First vs. Strict TDD — Match Step Size to Uncertainty

Strict TDD (one test at a time, fake-it → triangulate) and test-first are **not mutually
exclusive** — they are points on one spectrum of *step size*, and step size should track how much
design you still have to **discover** versus **conform to**. The deciding question is: *what is
this test for?*

- **conforming to a known shape** (external contract, legacy behavior, trivial mapping) →
  **test-first**: the test is a specification you satisfy, so write it, then write the code
- **discovering an unknown shape** (emergent design, branchy edge cases, expensive-to-undo
  abstraction) → **strict TDD**: the test is a design instrument, so take the smallest step and let
  the next test force the next bit
- note "**obvious implementation**" is strict TDD's own escape hatch — when you already know what
  to type, type it; the cycle simply collapses to "one test, write the real thing"

Fast proxies (heuristics, not laws — anchor on *uncertainty*, not on layer):

- API request/acceptance specs, schema/protocol conformance, characterization of legacy behavior,
  pure DTO/mapping/plumbing → lean **test-first**
- helpers and small services whose whole implementation fits in your head → **obvious
  implementation** (≈ test-first)
- domain/application services and complex domain logic, or when you feel the urge to over-engineer
  → lean **strict TDD**

**They compose (outside-in double loop):** write the acceptance/contract test **test-first** at the
boundary (it stays red as the goal post, and is committed last — see git-workflow), then grow the
units it requires with **strict TDD, inside-out**. It is test-first at the boundary, strict TDD in
the middle — not one or the other.

The failure modes are symmetric, and each is a smell that you picked the wrong step size:

- test-first on genuinely complex logic → the red→green gap is huge, debugging is hard, and you
  over-build
- strict TDD on a fixed contract → triangulation theater, ceremony with no design discovered

#### Systemic Refactoring — Look Beyond the Changed Lines

The REFACTOR step improves the code just written. It cannot see that another module already owns
the concept, enforces the same rule, or offers the abstraction the new code reinvented. A
**systemic design check** looks for exactly that, and it is a separate, less frequent activity —
never a broad scan after every cycle:

- **when planning** — look for *enabling* refactorings: changes that make this feature easy before
  it is built ("make the change easy, then make the easy change")
- **during implementation, on evidence** — when a cycle reveals a possibly shared concept, a
  duplicated business rule or a boundary crossing
- **before the feature is done** — once, over the whole diff against main

The planning and before-done checks can take long and are not always needed, so they are offered
to the user rather than run unconditionally; the on-evidence check is part of the cycle.

It applies whichever testing strategy was chosen above: the testing strategy decides how to
discover behaviour, the systemic check decides how widely to look before settling the design.

**What it looks for** — each judged by the rule that already defines it:

- **duplicated knowledge** — another module enforces the same business rule or invariant → "avoid
  duplicating logic — search before extracting" under Code Quality
- **misplaced ownership** — the behaviour belongs to an object or module that already owns the
  concept → "aggregates and entities hold the behaviour" and "domain services" under Architecture
- **reinvented abstraction** — a pattern, collaborator or term that already exists → "don't invent
  domain vocabulary" under Code Quality, "use existing infrastructure" under Implementation
  Guidelines
- **crossed boundary** — an outward dependency or unwanted coupling → "The Dependency Rule"

**Evidence before action:**

- every finding names the files and symbols it rests on, checked against the current code
- similar-looking code is not proof — confirm the two pieces encode the same business meaning
  before merging them; two look-alikes are often two different domain concepts
- "nothing to refactor" is a normal, valid outcome

**Classify every finding:**

- **fix now** — a design problem this change introduced
- **refactor now** — directly related to the change, bounded, and covered by tests
- **defer** — worthwhile but broader or riskier than this change justifies; record it with its
  evidence
- **no action** — an intentional difference, or a hypothesis the evidence did not support

When planning, nothing has been built yet, so fix now and refactor now collapse into one outcome:
**enabling** — a refactoring that makes this feature easier and is planned before it.

**Boundaries:** behaviour and public contracts are preserved and tests stay green; no cleanup of
unrelated modules, no abstraction for superficial duplication, no style rewrites; a refactoring
that spans modules needs the user's approval first; one that cannot be validated safely is
deferred.

**Stop searching** once you can answer, with evidence: where the behaviour belongs, which existing
behaviour or abstraction is relevant, which boundaries must hold, which other modules or consumers
are affected, and what uncertainty could still change the design. Start from the diff and a few
searches for the domain's own vocabulary; widen only when a finding points somewhere wider. Carry
forward conclusions with file references, not raw search output.

### Testing Strategy: Unit vs Integration Tests

When implementing features that modify business logic, use the appropriate test level:

**Unit Tests**
- add specific tests for the logic being changed
- focus on testing method/class/function behavior directly
- test edge cases, validation logic, and business rules at the unit level

**Integration/Request Tests**
- update existing integration tests to document end-to-end behavior
- verify behavior through the full integration flow
- do NOT add duplicate tests for unit-level logic
- prefer updating existing integration tests over creating new ones for unit-level concerns

**Core Principle**
- unit tests verify specific logic changes
- integration tests verify end-to-end behavior
- avoid duplicating unit-level assertions in integration tests

## Design Principles

### Architecture

Design follows Clean Architecture, Hexagonal Architecture, Crafted Design (Sandro Mancuso) and
Domain-Driven Design, with SOLID at the class level. Code is split into two areas — **delivery
mechanisms** on the outside, **application / domain code** on the inside — held together by the
Dependency Rule.

#### The Dependency Rule

Source code dependencies point **inward only**: delivery → application → domain. Inner code never
names anything outer — no controller, resolver, job, session, API type, HTTP client or other
framework concept appears in an application service or a domain object. When inner code needs the
outside world (sending an email, calling another system), it depends on a collaborator named in
its own business terms, and the outer layer supplies the implementation.

**Smell test**: if a use case would have to change because the API, the queue or the UI changed,
a dependency points the wrong way.

#### 1. Delivery mechanisms

The outermost layer: web controllers, views, API resolvers and endpoints, background jobs,
scheduled tasks, CLIs, queue consumers. Each handles the communication between the
outside world and the application, and nothing more:

1. translate the external input (params, arguments, session) into a use-case request
2. call the application service
3. map its response back to the outside (HTTP status, API type, exit code)

Delivery-only concerns — "is there a logged-in user?", serialisation, retries — stay here.

- **keep delivery mechanisms thin — they delegate, they don't decide**: a background job,
  controller action, scheduled task or CLI command unpacks its arguments and calls an application
  service; the logic belongs in that service, where it can be tested and reused without a queue or a
  request. A job handler that loads records, branches on a feature flag, writes to the database or
  builds a payload is doing domain work in an infrastructure class.
  ```
  # Instead of:
  job SendTaskReminderJob(user_id, task_id):
      task = database.find_task(task_id)
      # ...loading, guarding, recording, sending...

  # Use:
  job SendTaskReminderJob(user_id, task_id):
      RemindUserOfDueTask.call(user_id, task_id)
  ```
  The job's spec then documents only the delegation, and the service's spec documents the behaviour.

#### 2. Application / domain code

Application Services → Repositories → Domain Aggregates / Entities (or Domain Services)

- **application services (use cases)** are the entry points to the domain. Each maps **one**
  business rule and is named as an imperative verb-noun in business terms (`CompleteTask`,
  `ShareList` — not `TaskManager`, `ListProcessor`). It loads what it needs, orchestrates the
  domain objects, saves the changes, and returns a response the caller can branch on — typed
  outcomes (`Completed`, `NotFound`) rather than delivery-specific values. Group them by domain
  area (e.g. a `tasks/` directory), so the directory tree reads as what the system does.
- **repositories** are collection-like persistence collaborators (`find`, `save`) that keep
  storage details out of the use case. How this maps onto a framework — e.g. whether ORM models
  double as repositories — is the host repo's call (see `project-conventions.md`).
- **aggregates and entities hold the behaviour — put it on the object that owns the data (avoid
  feature envy / anemic models)**: before adding a method to a service or resolver that reaches
  into another object's columns, foreign keys, or associations to answer a question *about that
  object*, put the method on the object itself. "Is this user the owner of this TODO list?" / "is
  this user a collaborator on it?" is knowledge the aggregate already holds — expose it as
  `owned_by(user)` / `has_collaborator(user)` on the list, not as a `UserInvolvement` service that
  reads `owner_id` and queries the collaborators table. It
  is a **default, not an absolute** — the rule is scoped to "a question about that one object".
  **Smell test**: if a new class's methods mostly read another object's internals, that's feature
  envy — move them onto that object.
- **domain services** hold domain logic that genuinely spans aggregates and belongs to none of
  them. Reach for one only after the aggregate has been ruled out.

#### Worked example

"Complete a task", in pseudocode. The endpoint owns the session concern and the API mapping;
the use case knows nothing about either; the aggregate owns its own behaviour.

```
# Delivery — translate input, delegate, nothing else
endpoint CompleteTask(id, session):
    if not session.logged_in:
        return LoginRequired

    outcome = CompleteTaskService.call(user_id: session.user_id, id: id)

    match outcome:
        Completed -> return OperationSucceeded
        NotFound  -> return TaskNotFound

# Application service — one business action, typed outcomes, no API or session in sight
service CompleteTaskService(user_id, id):
    task = tasks.find_for(user_id, id)
    if task is missing:
        return NotFound

    in transaction:
        cancel_pending_reminder(task)
        task.complete()

    return Completed
```

### Code Quality
- avoid code smells like magic numbers
- follow Single Level of Abstraction principle:
  - a method should operate at **one** level of abstraction — don't mix high-level domain steps
    with low-level mechanics in the same method
  - the public entry point (e.g. a service's `call`) should read as the **domain narrative** —
    intention-revealing steps a domain reader recognizes, not framework/persistence lingo
  - push low-level details (ORM queries, JSON shaping, HTTP plumbing) **down** into named private
    methods whose names state the *intent*
- maintain clear separation of concerns
- **avoid duplicating logic — search before extracting**: before creating a new service/utility,
  search the relevant domain directory for an existing one that already
  covers the need; prefer reusing or extending it over a parallel implementation
- **don't invent domain vocabulary — use the language the project already speaks**: before coining
  a term for a concept (a collective noun for two sibling models, a name for an intermediate
  value), find out what the project already calls it. Check a glossary or domain-language doc if
  the repo has one; otherwise read the vocabulary the code, its specs and its PR descriptions
  already use. If a name exists, use it. If none does, treat that as information rather than a gap
  to fill — some domains deliberately leave a concept unnamed — so name the thing for the concepts
  the domain *does* have, or ask the team. Inventing a plausible-sounding term (`dwelling`,
  `entity`, `record`) adds vocabulary nobody agreed to and that reads as domain language to the
  next person.
- **consistent multi-line formatting**: when a set of similar one-line definitions (constants,
  constructor calls, etc.) needs to wrap, format them all multi-line the same way — don't leave
  only the single over-long line wrapped while the rest stay on one line

### Treat Third-Party Libraries as Black Boxes

Use dependencies through their **documented public contract** — don't read a library's (or
framework's, or lint rule's) internal source to explain *why* it behaves the way it does. The
explanation rarely changes what you need to do, and it burns time and context. When a tool reports
something (a linter offense, a test-matcher failure, a library raising), **fix it against the
observable contract and re-run to verify** rather than diving into vendored source.

If you genuinely feel you must inspect a third-party's internals — a suspected bug in the library,
or undocumented behavior that is actually blocking you — **stop and ask the user first with
`AskUserQuestion`**, stating why you think it's necessary. Reading dependency source should be a
deliberate, approved step, never an idle reflex.

### Comments

**The default is no comment.** Well-named methods, constants and tests are the documentation. A
comment is an exception that has to earn its place, not a courtesy you add while writing code.

Before writing one, ask: *would a competent reader of this codebase be wrong or stuck without it?*
If the answer is no, delete it. If the answer is "they'd be slightly slower", also delete it — and
consider whether a better name would have removed the question entirely.

#### Machine-required comments are always fine

Some comments are not prose for a reader — they are **instructions a tool executes**. These are
code, they are never optional, and nothing below applies to them:

- linter and formatter directives that disable or enable a rule
- compiler and type-checker directives that suppress or annotate a check
- file-level pragmas and magic comments, such as encoding headers
- structured annotations a tool parses — `TODO(#123)` where the tracker scans for it

A machine directive that suppresses a rule should say which rule and why in the same line, because
the *suppression* is the non-obvious part.

#### Everything else must clear a much higher bar

A discretionary comment earns its place only when it carries knowledge that is **external to this
codebase and unrecoverable by reading it**. Both halves are required: if a sufficiently patient
reader could recover the fact by following the code, a test, or a type, the comment fails the bar.

- a constraint imposed by another system (an external schema that rejects a value, an API that
  swallows errors)
- a non-obvious consequence of removing or changing the line (why a validation is deliberately
  *absent*; why insert order matters)
- a workaround whose reason is invisible locally (a SQL `COALESCE` needed to treat `NULL` as blank)

**Complex logic is not on that list, and never qualifies.** Difficulty is recoverable by reading —
it is a signal to extract a named method, introduce a domain term, or add a test that demonstrates
the case. Explaining a tangle in prose leaves the tangle in place and adds a second thing to keep
in sync. Untangle it instead.

#### Code you are editing

When changing existing code, the comment bar applies to your diff, not just to new files:

- do **not** add a comment to a line or method that did not have one — if it managed without,
  your change does not license one
- never leave a comment that describes **your own change** — `# changed to use the new API`,
  `# added for the X feature`, `# was previously nil` — git history already records this, and the
  note rots the moment the next change lands
- when you edit a line that carries an existing comment, re-check it: update it if it is still
  earned, delete it if your change made it false or redundant

These are the recurring failure modes — all of them are noise, delete on sight:

```
# ❌ Restates the line below it
# The reminder time comes from the user's settings, not the task
remind_at = user.settings.reminder_time

# ❌ Paraphrases the class name
# Reminds a user that one of their tasks is due.
class RemindUserOfDueTask

# ❌ Repeats, in a test, a comment that already sits on the code under test
# The calendar sync service declares priority as a strict enum, so a bad value must fail loudly
test "raises for a priority the calendar sync service does not accept"

# ❌ Narrates a well-named test
# A list with no tasks must not show a progress bar
test "returns no progress for an empty list"

# ❌ Describes your own change instead of the code
# Switched to batched iteration to avoid loading every row
for task in tasks.in_batches():

# ❌ Explains complexity that should have been extracted
# Loop the lists, skip the archived ones, and take the newest task per list
latest = group_by_list(reject_archived(tasks)).map(newest_task)
```

Prefer a clearer name, a smaller method, or a test that documents the behaviour over any comment.
When a comment is genuinely warranted, keep it to one or two lines.

### Implementation Guidelines
- **API Design**: Consistent parameter ordering (context before specifics)
- **Code Structure**: Extract parameter objects to avoid data clumps when too many arguments are passed into a function signature
- **Implementation Approach**: Use existing infrastructure (project scripts, tasks, admin tooling) over new code

## Evolving Guidelines

After completing a PR or phase, review the work for conventions worth writing down in the host
repository's own agent instruction files — its `CLAUDE.md` or `AGENTS.md`. These are the **only**
targets: the plugin's guidelines are not edited from a host repository, and the installed plugin
copy is replaced on every update.

**Proposing nothing is the normal outcome.** Most work — even large, interesting, well-executed
work — produces no new convention. A convention is a rule that will change how *future, unrelated*
work in this repository is done; a fact about the code you just wrote is not one, however
hard-won it felt. Agent instruction files are read before every task, so each addition costs
attention forever: a weak rule does not merely sit there, it dilutes the strong ones around it.
Treat "nothing to add" as success and say so in one line, rather than reaching for something to
fill a quota.

**Do not use auto-memory.** Never write to `~/.claude/projects/*/memory/MEMORY.md`. Any insight worth preserving belongs in the host repository's `CLAUDE.md` or `AGENTS.md` — propose it through the process below.

### Process

1. **Analyze the work completed:**
   - look for coding patterns, naming conventions, architectural decisions, or workflow improvements
     specific to this repository
   - identify practices that could benefit future work here

2. **Check what is already written down — discard anything covered:**
   - the host repository's `CLAUDE.md` and `AGENTS.md`, including nested ones
   - the plugin's guidelines in this `guidelines/` directory — the workflow already applies them in
     every repository, so restating one adds nothing

3. **Apply the generality test — discard anything that fails:**

   A candidate must pass **every** check below. One failure discards it; do not soften the
   wording to squeeze it through, since a rule vague enough to pass is too vague to follow.

   - **It is a rule, not a fact about the code just written.** *"Prefer an existing helper over a
     hand-rolled equivalent"* is a rule. *"`TaskService` should use `DueDateFormatter`"* is a
     fact about one file, and belongs in that code or its review, not the instruction file.
   - **It applies to a future change in a different file and a different feature.** Imagine the
     next three unrelated tasks in this repository — if it would not fire in any of them, it is not
     a convention.
   - **It is actionable by someone who never saw this PR.** If understanding it requires the
     context of this ticket, it will be unreadable in three months.
   - **It reflects a recurring pattern, not a one-off decision.** One occurrence is an anecdote.
     Wait for the second before writing a rule; a decision made once is better recorded in the
     code or the PR description.
   - **Following it would have changed an outcome.** A rule that merely describes what you
     already did, correctly and by instinct, adds reading cost and changes nothing.

   State the result of this test honestly. If nothing passes, report that and stop — that is the
   expected result, not a failure to find something.

4. **Choose the target file for each surviving candidate:**
   - the nearest `CLAUDE.md` or `AGENTS.md` that covers the files the rule is about — a nested file
     for a rule about one subtree, the root file otherwise
   - when both exist, the one that already holds related rules
   - when neither exists, the candidate proposes creating the file the repository is more likely to
     want — `AGENTS.md` if other agent tools are used here, `CLAUDE.md` otherwise

5. **Ask with `AskUserQuestion`:** "These conventions could be added to this repository's agent
   instruction files. Which should I add?" — multi-select, one option per candidate:
   - present **at most 2**, and only those that cleared the test — zero is a valid and common
     answer; never pad to reach a number, and with zero, skip the question
   - each option names the target file, and its preview shows the exact text to add
   - each description names the check it most strongly passes

6. **Add the chosen ones:**
   - add only what the user picked, with clear, concise language and an example where helpful
   - commit each target file's change on the current branch as `docs: <what the rule covers>`,
     per `git-workflow.md`
   - never push without asking, per `git-workflow.md`

**Skip this step if:**
- the work was trivial or routine
- no new patterns or conventions emerged
- all practices are already documented
- the insight is specific to this feature or ticket rather than to how code is written in this
  repository
- it restates an existing rule, in the repository's files or the plugin's guidelines, in different
  words — a near-duplicate is worse than nothing, because two phrasings of one rule invite drift
  between them
- it emerged from a single occurrence and has not yet been seen a second time

## Quality Checks

### Before Every Commit (Including Review Fixes)
- after implementing any change — especially review feedback — run the **full relevant test suite**, not just the spec for the file directly modified — and see "Scope the Pre-Commit Suite to What the Change Touches" in `testing-principles.md` for the upper bound on *relevant*: the unit's own spec, its collaborators' specs, and the spec for every file the change edited, **not** the enclosing directory
- when a value, constant, flag, or API is changed **or removed**, search the codebase for **all** references to the old form — including **comments and documentation**, not just specs — and update them in the same change; removing a flag while leaving a comment that still describes it produces stale, misleading docs
- read the diff you are about to commit and delete every comment it introduces that is not
  machine-required or a justified exception under "Comments" above — review the diff itself, not
  the finished file, because a comment that felt reasonable while writing the line is the one most
  likely to be restating it
- check for any linting issues and fix them
- ensure all tests pass before committing

### Before Marking Tasks Complete
- check that no potential regressions are present in the code
- check for any linting issues and fix them
- ensure all tests pass

## Interaction Style

- when a question is ambiguous or several approaches are valid, present the options with
  `AskUserQuestion` instead of picking silently
- whenever a skill asks the user to choose between discrete options (yes/no, A/B, "pick one of
  these branches"), use `AskUserQuestion`; keep free-text prompts for genuinely open-ended input —
  IDs, names, links, custom messages, multi-line specifications
