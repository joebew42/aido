# Code Standards

## Development Approach

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

Clean Architecture, Hexagonal Architecture, Crafted Design and Domain-Driven Design all make the
same point; these rules state it once, in Domain-Driven Design language, with SOLID at the class
level.

Code is split into two areas, held together by the Dependency Rule: **infrastructure** communicates
with the outside world, and **application / domain code** holds what the system does.

#### The Dependency Rule

Source code dependencies point **inward only**: infrastructure → application → domain. Application
and domain code never name anything in infrastructure — no controller, endpoint, job, session, API
type, HTTP client, database or other framework concept. When inner code needs the outside world
(storing a task, cancelling a reminder), it depends on a **collaborator** named in its own business
terms. It does not choose the implementation: that is supplied from outside it.

**Smell test**: if a use case would have to change because the API, the queue, the UI or the
database changed, a dependency points the wrong way.

#### Collaborators and their implementations

By default, inner code depends on a collaborator and its implementation lives in infrastructure,
**even when there is only one implementation**. This separation is a design boundary, not
speculative generalization; no further implementation is added until a test needs it. The
collaborator's name follows the vocabulary the host repository already uses — `TaskRepository` or
`Tasks` (see "don't invent domain vocabulary" under Code Quality).

The default applies only when these leave the question open, in this order:

1. **the host repository's instruction files** can choose otherwise, for example ORM models as
   their own repositories (see `project-conventions.md`)
2. **the code around the change**: see "Existing organization" under Implementation Guidelines
3. **the framework's conventions**: where the framework has its own way, such as ORM models that
   are their own repositories, follow it and do not bend it to this model

#### 1. Infrastructure

The outermost area, at the boundaries of the system. It comes in two kinds, and neither decides
anything about the business.

**What calls in** — web controllers, views, HTTP and GraphQL endpoints, CLIs, background job
handlers, scheduled tasks, queue consumers. Each translates the external input into a use-case
request, calls the application service, and maps its response back to the outside (HTTP status, API
type, exit code). Concerns of the outside world — "is there a logged-in user?", serialisation,
retries — stay here.

**Keep it thin — it delegates, it doesn't decide.** A job handler that loads records, branches on a
feature flag, writes to the database or builds a payload is doing domain work in an infrastructure
class: `SendTaskReminderJob` only unpacks its arguments and calls `RemindUserOfDueTask`. Its test
then documents the delegation, and the service's test documents the behaviour.

**What inner code calls out to** — repository implementations, email senders, clients of other
systems, queue publishers. Each implements a collaborator's contract and translates between business
terms and the outside world. A collaborator may have several implementations, one for each way of
communicating: `PostgresqlTaskRepository` talks to a PostgreSQL database, and `QueueTaskReminders`
implements `TaskReminders` on a job queue.

#### 2. Application / domain code

- **application services (use cases)** are the entry points to the domain. Each maps **one**
  business rule and is named as an imperative verb-noun in business terms (`CompleteTask`,
  `ShareList` — not `TaskManager`, `ListProcessor`). It loads what it needs, orchestrates the
  domain objects, saves the changes, and returns a response the caller can branch on — typed
  outcomes (`Completed`, `NotFound`) rather than values tied to one way of calling it. Group them by
  domain area (e.g. a `tasks/` directory), so the directory tree reads as what the system does.
- **collaborators** are the contracts inner code talks to. **Repositories** are the collection-like
  ones (`find`, `save`) that keep storage details out of the use case; every other need of the
  outside world, such as `TaskReminders`, works the same way.
- **aggregates and entities hold the behaviour — the business logic and invariants, on the object
  that owns the data (avoid feature envy / anemic models)**. An entity has an identity. "Is this
  user the owner of this TODO list?" is knowledge the aggregate already holds — expose it as
  `owned_by(user)` on the list, not as a `UserInvolvement` service that reads `owner_id`. This is a
  **default, not an absolute**, scoped to "a question about that one object". **Smell test**: if a
  new class's methods mostly read another object's internals, that's feature envy — move them onto
  that object.
- **value objects** have no identity and are compared by value: two `DueDate`s for the same day are
  the same due date.
- **domain services** hold domain logic that genuinely spans aggregates and belongs to none of
  them. Reach for one only after the aggregate has been ruled out.

#### Worked example

"Complete a task", in pseudocode, through every role.

```
# Infrastructure, calling in — translate input, delegate, map the outcome
endpoint CompleteTaskEndpoint(id, session):
    if not session.logged_in:
        return LoginRequired

    outcome = complete_task.call(user_id: session.user_id, id: id)

    match outcome:
        Completed        -> return OperationSucceeded
        NotFound         -> return TaskNotFound
        AlreadyCompleted -> return TaskAlreadyCompleted

# Application service — one business action, typed outcomes, no API or session in sight
service CompleteTask(tasks: TaskRepository, reminders: TaskReminders):
    call(user_id, id):
        task = tasks.find_for(user_id, id)
        if task is missing:
            return NotFound

        if task.complete() is Rejected:
            return AlreadyCompleted

        reminders.cancel_for(task)
        tasks.save(task)

        return Completed

# Entity — has an identity, enforces its own invariant
entity Task(id, due_date: DueDate, completed_at):
    complete():
        if completed_at is set:
            return Rejected
        completed_at = now

# Value object — no identity, compared by value
value DueDate(day)

# Collaborators — contracts in business terms
collaborator TaskRepository: find_for(user_id, id), save(task)
collaborator TaskReminders: cancel_for(task)

# Infrastructure, called by inner code — implements a contract, talks to the outside world
PostgresqlTaskRepository implements TaskRepository
QueueTaskReminders implements TaskReminders

# Infrastructure — supplies the implementations
complete_task = CompleteTask(tasks: PostgresqlTaskRepository(), reminders: QueueTaskReminders())
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
  the repo has one; otherwise read the vocabulary the code, its tests and its PR descriptions
  already use. If a name exists, use it. If none does, treat that as information rather than a gap
  to fill — some domains deliberately leave a concept unnamed — so name the thing for the concepts
  the domain *does* have, or ask the team. Inventing a plausible-sounding term (`work item`,
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
- file-level pragmas, such as encoding or strict-mode declarations
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
  `# added for the X feature`, `# was previously empty` — git history already records this, and the
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
# The export format declares priority as a strict enum, so a bad value must fail loudly
test "raises for a priority the export format does not accept"

# ❌ Narrates a well-named test
# A list with no tasks must not show a progress bar
test "returns no progress for an empty list"

# ❌ Describes your own change instead of the code
# Switched to batched iteration to avoid loading every row
for task in batched(tasks):

# ❌ Explains complexity that should have been extracted
# Loop the lists, skip the archived ones, and take the newest task per list
latest = group_by_list(reject_archived(tasks)).map(newest_task)
```

Prefer a clearer name, a smaller method, or a test that documents the behaviour over any comment.
When a comment is genuinely warranted, keep it to one or two lines.

### Implementation Guidelines
- **API Design**: Consistent parameter ordering (context before specifics)
- **Code Structure**: Extract parameter objects to avoid data clumps when too many arguments are passed into a function signature
- **Existing organization**: follow how the code around the change is already organized, even when
  it differs from "Architecture", over introducing a new way of organizing it. Moving it to that
  model is a separate refactoring the user decides on. This covers where things live, not bad
  habits: new job handlers and endpoints still stay thin, even when their neighbours are not
- **Existing tooling**: use project scripts, tasks and admin tooling over new code

## Quality Checks

### Before Every Commit (Including Review Fixes)
- after implementing any change — especially review feedback — run the **full relevant test suite**, not just the test for the file directly modified — and see "Scope the Pre-Commit Suite to What the Change Touches" in `testing-principles.md` for the upper bound on *relevant*: the unit's own tests, its collaborators' tests, and the tests for every file the change edited, **not** the enclosing directory
- when a value, constant, flag, or API is changed **or removed**, search the codebase for **all** references to the old form — including **comments and documentation**, not just tests — and update them in the same change; removing a flag while leaving a comment that still describes it produces stale, misleading docs
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
