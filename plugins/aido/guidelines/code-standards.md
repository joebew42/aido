# Code Standards

## Development Approach

### Testing Strategy: Unit vs Integration Tests

When a feature changes business logic, test each thing at its level:

- **unit tests** cover the logic being changed, directly on the method, class or function: its edge
  cases, validation and business rules
- **integration or request tests** document the end-to-end behaviour through the full flow. Update
  the existing ones rather than adding new ones, and don't repeat unit-level assertions in them

## Design Principles

### Architecture

Clean Architecture, Hexagonal Architecture, Crafted Design and Domain-Driven Design make the same
point. These rules state it once, in Domain-Driven Design words, with SOLID at the class level.

Code is split into two areas, held together by the Dependency Rule: **infrastructure** talks to the
outside world, and **application / domain code** holds what the system does.

#### The Dependency Rule

Source code dependencies point **inward only**: infrastructure → application → domain. Application
and domain code never name anything in infrastructure — no controller, endpoint, job, session, API
type, HTTP client, database or other framework concept. When inner code needs the outside world
(storing a task, cancelling a reminder), it depends on a **collaborator** named in its own business
terms. It does not choose the implementation: that is supplied from outside it.

**Smell test**: if a use case would have to change because the API, the queue, the UI or the
database changed, a dependency points the wrong way.

#### Collaborators and their implementations

By default, inner code depends on a collaborator, and its implementation lives in infrastructure,
**even when there is only one implementation**. This is a design boundary, not speculative
generalization: no further implementation is added until a test needs it. The collaborator's name
uses the host repository's words, such as `TaskRepository` or `Tasks` (see "don't invent domain
vocabulary" under Code Quality).

The default applies only when these leave the question open, in this order:

1. **the host repository's instruction files** can choose otherwise, for example ORM models as
   their own repositories (see `project-conventions.md`)
2. **the code around the change**: see "Existing organization" under Implementation Guidelines
3. **the framework's conventions**: where the framework has its own way, such as ORM models that
   are their own repositories, follow it and do not bend it to this model

#### 1. Infrastructure

The outermost area, at the system's boundaries. It comes in two kinds, and neither makes business
decisions.

**What calls in** — web controllers, views, HTTP and GraphQL endpoints, CLIs, background job
handlers, scheduled tasks, queue consumers. Each translates the external input into a use-case
request, calls the application service, and maps its response back to the outside (HTTP status, API
type, exit code). Concerns of the outside world — "is there a logged-in user?", serialisation,
retries — stay here.

**Keep it thin: it delegates, it doesn't decide.** A job handler that loads records, branches on a
feature flag, writes to the database or builds a payload does domain work in an infrastructure
class. `SendTaskReminderJob` only unpacks its arguments and calls `RemindUserOfDueTask`. Its test
documents the delegation, and the service's test documents the behaviour.

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
    if not session.logged_in: return LoginRequired
    match complete_task.call(user_id: session.user_id, id: id):
        Completed -> return OperationSucceeded
        NotFound  -> return TaskNotFound
        AlreadyCompleted -> return TaskAlreadyCompleted

# Application service — one business action, typed outcomes, no API or session in sight
service CompleteTask(tasks: TaskRepository, reminders: TaskReminders):
    call(user_id, id):
        task = tasks.find_for(user_id, id)
        if task is missing: return NotFound
        if task.complete() is Rejected: return AlreadyCompleted
        reminders.cancel_for(task)
        tasks.save(task)
        return Completed

# Entity — has an identity, enforces its own invariant
entity Task(id, due_date: DueDate, completed_at):
    complete():
        if completed_at is set: return Rejected
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
- avoid code smells such as magic numbers
- follow the Single Level of Abstraction principle:
  - a method works at **one** level of abstraction. Don't mix high-level domain steps with low-level
    mechanics in one method
  - the public entry point, such as a service's `call`, reads as the **domain narrative**: steps a
    domain reader recognizes, not framework or persistence words
  - push low-level details (ORM queries, JSON shaping, HTTP plumbing) **down** into private methods
    whose names state the *intent*
- keep concerns separate
- **avoid duplicating logic — search before extracting**: before creating a new service or utility,
  search the domain directory for one that already covers the need. Reuse or extend it rather than
  writing a parallel one
- **don't invent domain vocabulary — use the language the project already speaks**: before naming a
  concept, check a glossary or domain-language doc if the repo has one, then the words its code,
  tests and PR descriptions use. If a name exists, use it. If none does, the domain may leave the
  concept unnamed on purpose: name the thing for the concepts the domain *does* have, or ask the
  team. A plausible term (`work item`, `entity`, `record`) reads as domain language to the next
  person, though nobody agreed to it.
- **consistent multi-line formatting**: when one of a set of similar one-line definitions (constants,
  constructor calls) needs to wrap, format them all multi-line the same way

### Depend on Third-Party Contracts, Not Internals

**Your code** uses a dependency (a library, framework or lint rule) through its documented public
contract. Do not call its private APIs or rely on undocumented behaviour, because an upgrade can
change them without notice.

**Your understanding** can come from anywhere. When the documentation doesn't explain what you see,
read the source of the version the project has installed. Check what you learn by running the code,
and fix the problem against the public contract.

### Comments

**The default is no comment.** Well-named methods, constants and tests are the documentation.
Before writing one, ask: *would a competent reader of this codebase be wrong or stuck without it?*
If not, delete it, and consider whether a better name would remove the question.

**Machine-required comments are always fine**, because a tool executes them: linter, formatter,
compiler and type-checker directives, file-level pragmas, and annotations a tool parses, such as
`TODO(#123)`. A directive that suppresses a rule names the rule and the reason on the same line.

**Any other comment** must carry knowledge that is **external to this codebase and can't be
recovered by reading it**: a constraint imposed by another system, a non-obvious consequence of
changing the line, or a workaround whose reason isn't visible locally. **Complex logic never
qualifies**: extract a named method, introduce a domain term, or add a test that shows the case. A
warranted comment is one or two lines.

**When editing existing code, the bar applies to your diff:**

- do **not** add a comment to a line or method that had none
- never leave a comment that describes **your own change**: git history records that
- when you edit a line that has a comment, update it if it is still earned, and delete it if your
  change made it false or redundant

These are noise, delete on sight:

```
# ❌ Restates the line below it
# The reminder time comes from the user's settings, not the task
remind_at = user.settings.reminder_time

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

### Implementation Guidelines
- **API Design**: keep parameter order consistent, context before specifics
- **Code Structure**: extract a parameter object when a function takes too many arguments
- **Existing organization**: follow how the code around the change is organized, even when it
  differs from "Architecture", rather than introducing a new way. Moving it to that model is a
  separate refactoring the user decides on. This covers where things live, not bad habits: new job
  handlers and endpoints still stay thin, even when their neighbours aren't
- **Existing tooling**: use project scripts, tasks and admin tooling rather than new code
