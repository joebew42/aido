# Distil the architecture guidelines into one model, in DDD language

## Context

The "Architecture" section of `plugins/aiae/guidelines/code-standards.md` says design follows Clean
Architecture, Hexagonal Architecture, Crafted Design and Domain-Driven Design. All four make the
same point, but offering them as references gives an AI agent several vocabularies to choose from
and several sources to interpret.

The section also leaves gaps. It splits code into delivery mechanisms on the outside and
application / domain code on the inside, and delivery mechanisms only cover what calls into the
application. Code that implements a collaborator by talking to the outside world, such as a
repository backed by PostgreSQL, has no place in the model. Value objects are never defined, though
`/aiae:map-architecture` lists them as a role.

Two rules stand in the way of closing that gap: `code-standards.md` leaves it to the host
repository whether ORM models double as repositories, with no default when the host repository is
silent, and `testing-principles.md` says not to mock data access and to create real records.

## Intent

The guidelines give an AI agent one unambiguous and consistent architecture model, stated
in Domain-Driven Design language:

- integration moves to the boundaries of the system: everything that communicates with the outside
  world is infrastructure, whether HTTP, GraphQL, a CLI, a background job or a repository
  implementation
- application and domain code talk to collaborators named in business terms, such as a
  `TaskRepository` or `Tasks`, depending on the host repository's preference and the vocabulary its
  code already uses
- a collaborator may have several implementations, one for each way of communicating with the
  outside world; `PostgresqlTaskRepository` is the one that talks to a PostgreSQL database
- the same holds for every other kind of collaborator, not only repositories
- a small reference example shows an agent how the roles connect
- tests follow the same split, and the skills speak the same vocabulary as the guidelines
- code that is already organized differently, such as a legacy or inherited codebase, keeps its
  organization: the model applies where the code around the change does not settle the question
- a framework with its own conventions keeps them: where a framework has its own way, such as ORM
  models that are their own repositories, agents follow it rather than bend it to DDD, because the
  extra indirection is unnecessary

## Out of scope

- the rest of `code-standards.md` and `testing-principles.md`: test-driven development, comments,
  code quality, and test structure not related to collaborators
- the rule that a host repository is authoritative on every topic it covers
- the categories of finding in `/aiae:assess-architecture`
- the README's "Clean architecture" wording in its list of practices, a general description rather
  than a reference for coding conventions
- migrating architecture indexes that already exist; they stay usable and keep their "Delivery
  mechanisms" heading until they are rebuilt
- changing any host repository's code

## Acceptance criteria

The architecture model

- AC1: the "Architecture" section of `code-standards.md` names Clean Architecture, Hexagonal
  Architecture, Crafted Design and Domain-Driven Design in one line that credits them as the same
  idea, and no other guideline or skill names them as references
- AC2: the section defines two areas: infrastructure (everything that communicates with the outside
  world) and application / domain code
- AC3: the Dependency Rule states that infrastructure depends inward, and that application and
  domain code never name anything in infrastructure
- AC4: the section states that inner code does not choose its implementations: they are supplied
  from outside it
- AC5: the section states the default for when the host repository's instruction files, its
  framework's conventions and the code around the change all leave the question open: inner code
  depends on a collaborator named in
  business terms and its implementation lives in infrastructure, even when there is only one
  implementation; the collaborator's name follows the vocabulary the host repository already uses,
  such as `TaskRepository` or `Tasks`. The section also states that this separation is a design
  boundary rather than speculative generalization, and that no further implementation is added
  until a test needs it
- AC6: the section states that a host repository can choose otherwise, for example ORM models as
  their own repositories, and no longer presents that choice as having no default
- AC7: the section applies the rule to a collaborator other than a repository, with an example
  from the TODO app
- AC8: the worked example is one labelled flow from the TODO app that passes through every role:
  infrastructure that calls in, an application service, an entity enforcing an invariant, a value
  object, `TaskRepository`, and `PostgresqlTaskRepository`; every example in the section uses the
  TODO app
- AC9 (manual): the section reads as one model, less ambiguous than today, and uses DDD language
  throughout
- AC24: the section distinguishes the two kinds of infrastructure: what calls in (HTTP, GraphQL,
  CLI, background job handlers) stays thin and delegates to an application service; what inner code
  calls out to (`PostgresqlTaskRepository`) implements a collaborator's contract
- AC25: the section states that entities and aggregates hold the business logic and invariants, and
  that value objects have no identity and are compared by value

Testing

- AC10: `testing-principles.md` states that unit tests of application and domain code mock their
  collaborators to the collaborator's contract, such as that of `TaskRepository`, because that
  contract is controlled and known
- AC11: it states that a real implementation, such as `PostgresqlTaskRepository`, is tested alone
  against the real thing
- AC12: it states that acceptance tests and integration tests use the real implementations
- AC13: its guidance on data access no longer contradicts AC10, and it still says not to mock what
  the project does not control, such as ORM query methods or third-party clients; where ORM models
  are their own repositories (AC26), tests create real records

The skills

- AC14: the plan step of `/aiae:1-plan` names the layers domain, application and infrastructure, and
  orders the plan in that sequence, with what inner code calls out to before what calls in
- AC15: the Dependency Rule check in `/aiae:2-implement` covers application or domain code naming
  anything in infrastructure, and decision-making left in infrastructure
- AC16: the layering checks and plan template in `/aiae:stabilize` use infrastructure
- AC17: `/aiae:map-architecture` records an Infrastructure role in `<area-slug>.extra.md` in place
  of Delivery mechanisms, and a Collaborators role in `<area-slug>.md` in place of Repositories,
  covering repositories and every other contract

The plugin

- AC18: no skill or guideline uses "delivery mechanism" or any other name for the outer area than
  "infrastructure"; the "boundary/adapter" wording in `testing-principles.md` is reworded to match,
  `README.md` describes `testing-principles.md` as covering collaboration tests rather than
  "boundary collaboration", and the review guidance in `/aiae:pr-review` speaks of logic in
  infrastructure
- AC19: `version` in `plugins/aiae/.claude-plugin/plugin.json` is bumped following semantic
  versioning
- AC20: `claude plugin validate .` and `claude plugin validate ./plugins/aiae` pass

Existing code and commits

- AC21: the Implementation Guidelines in `code-standards.md` state: follow how the code around the
  change is already organized, even when it differs from "Architecture", over introducing a new way
  of organizing it; moving it to that model is a separate refactoring the user decides on
- AC22: the Implementation Guidelines state separately: use project scripts, tasks and admin tooling
  over new code; the word "infrastructure" is no longer used for that tooling anywhere in
  `code-standards.md`
- AC23: the commit organization in `git-workflow.md` gives implementations of collaborators their
  own commit, after application code and before API-layer commits, and `/aiae:3-organize-commits`
  agrees with it
- AC26: the "Architecture" section of `code-standards.md` states that where the host repository's
  framework has its own conventions, such as ORM models that are their own repositories, agents
  follow them and do not bend them to this model; it says so without naming a specific framework,
  so the guideline stays stack-agnostic

## Plan

The plugin has no code layers, so each item names the file kind it changes. Guidelines come first,
because the skills refer to them. There are no automated tests: each criterion is checked by
searching and reading the changed files, except AC9, which the user confirms, and AC20, which is
run.

1. **guideline — one architecture model in `code-standards.md`** (AC1, AC2, AC3, AC4, AC5, AC6, AC7,
   AC8, AC9, AC24, AC25, AC26, AC18): rewrite "Architecture" with the one-line credit, the two
   areas, the two kinds of infrastructure, the Dependency Rule, the default and when a framework's
   conventions replace it, and the definitions of entities,
   aggregates and value objects; extend "Complete a task" into the one labelled flow, replacing
   prose it makes redundant; use a collaborator such as `TaskReminders`, implemented by
   `QueueTaskReminders`, for AC7
2. **guideline — existing organization and tooling in `code-standards.md`** (AC21, AC22): replace
   line 375 with the two rules and update the pointer at line 93 to the new rule's name, keeping
   "don't invent domain vocabulary" as it is
3. **guideline — collaborators in `testing-principles.md`** (AC10, AC11, AC12, AC13, AC18): extend
   the section at lines 35–54 to mock collaborators to their contract, test real implementations
   alone, and use real implementations in acceptance and integration tests; reword
   "boundary/adapter" to infrastructure that calls in
4. **guideline and skill — commits for implementations** (AC23): add the rule to `git-workflow.md`
   and align `3-organize-commits/SKILL.md`, whose API-layer lines stay
5. **skill — layer lists in the workflow skills** (AC14, AC15, AC16): update `1-plan/SKILL.md` lines
   252–254; shorten `2-implement/SKILL.md` lines 134–136 to the rule and a pointer; update
   `stabilize/SKILL.md` lines 63–64 and 138–139, and check line 120
6. **skill — infrastructure in the architecture index** (AC17, AC18): update
   `map-architecture/SKILL.md` lines 2, 22, 84–96, 99–101 and 115, and the description of
   `.extra.md` in `assess-architecture/SKILL.md` lines 40–41
7. **docs and skill — remaining vocabulary** (AC18): update `README.md` line 159 and
   `pr-review/SKILL.md` line 165, then search the plugin for "delivery" and any other name for the
   outer area
8. **plugin — version and validation** (AC19, AC20): bump `version` to 1.2.0, a minor change because
   the guidance changes what agents do, and run both validations

## Design notes

- **Where it belongs:** "Architecture" in `plugins/aiae/guidelines/code-standards.md` is the
  single definition of the model; the test split belongs in "Test Collaboration, Real Behaviour
  End-to-End" in `testing-principles.md`
- **Existing behaviour and abstractions to reuse:** `code-standards.md` — the two-area split, and
  the Dependency Rule, which already had "collaborator" and an
  outer layer supplying the implementation; `code-standards.md` — "don't invent domain vocabulary"
  for the collaborator's name; `project-conventions.md` — the host repository's authority, for AC6 and AC21; `testing-principles.md` — mocking a service was already allowed
- **Boundaries that must hold:** skills keep pointing at "Architecture" and restate only what they
  need to act on, such as ordering; `code-standards.md` lines 126–144 get no copy of the test split;
  guidelines refer to each other by file name and skills through `${CLAUDE_PLUGIN_ROOT}`; "boundary"
  meaning the edge of the system or of an area (`code-standards.md` lines 56–58,
  `assess-architecture/SKILL.md` lines 43 and 57) stays, because it does not name a layer
- **Other modules or consumers affected:** the files in the plan; `assess-architecture` picks up the
  Dependency Rule through its existing pointer. Checked and unaffected: `multi-phase-*`,
  `4-create-pr`, `5-handle-review`, `resolve-migration-conflict`, `docs/`
- **Enabling refactorings (planned):** none. The analysis proposed freeing the word "infrastructure"
  first; rewriting line 375 adds a rule, so it became AC21 and AC22 instead
- **Deferred:** the layer order stays restated in `1-plan` and `stabilize`, because they need it to
  act on; consolidating it is not worth a change of its own
- **Open questions:** none

## Progress

- [x] 1. one architecture model in `code-standards.md`
- [x] 2. existing organization and tooling
- [x] 3. collaborators in `testing-principles.md`
- [x] 4. commits for implementations
- [x] 5. layer lists in the workflow skills
- [x] 6. infrastructure in the architecture index
- [x] 7. remaining vocabulary
- [x] 8. version 1.2.0 and validation

No automated tests exist, so automatable criteria were checked by searching and reading the files.
The plugin was validated but not tried in a live session with `--plugin-dir`.

- AC1: met — credit in "Architecture"; a search finds the names nowhere else but the out-of-scope README line
- AC2: met — read in "Architecture"
- AC3: met — "The Dependency Rule"
- AC4: met — "The Dependency Rule", and the last line of the worked example
- AC5: met — "Collaborators and their implementations"
- AC6: met — same section, item 1 of its list
- AC7: met — `TaskReminders` / `QueueTaskReminders`
- AC8: met — "Worked example"
- AC9: changed — "more concise" dropped because the section grew from 103 to 136 lines by covering more; the user chose to keep it and reword the criterion, and "concise" was dropped from the Intent to match
- AC10: met — `testing-principles.md`, "Test Collaboration, Real Behaviour End-to-End"
- AC11: met — same section
- AC12: met — same section
- AC13: met — same section
- AC14: met — `1-plan/SKILL.md`, Step 6
- AC15: met — `2-implement/SKILL.md`, REFACTOR checklist
- AC16: met — `stabilize/SKILL.md`, gap list and plan template
- AC17: changed — Collaborators replaces Repositories, so contracts such as `TaskReminders` have a place in the index; met — `map-architecture/SKILL.md`, section list
- AC18: met — a search for "delivery", "adapter", "outer layer", "outer concept" and "boundary/" finds nothing
- AC19: met — `plugin.json` is 1.2.0
- AC20: met — both validations pass
- AC21: met — "Existing organization"
- AC22: met — "Existing tooling"; "existing infrastructure" is gone
- AC23: met — `git-workflow.md`, `3-organize-commits/SKILL.md`
- AC24: met — "1. Infrastructure"
- AC25: met — "2. Application / domain code"
- AC26: met — "Collaborators and their implementations", naming no framework

Decisions from the final Systemic Design Checkpoint, all agreed with the user:

- the code around the change comes before the framework's conventions
- "Existing organization" covers where things live; new job handlers and endpoints still stay thin
- in the test section, "collaborator" means a contract and "service" the application service; the
  pre-commit scope wording ("its collaborators' tests") stays, as it reads correctly either way
- the worked example's endpoint is `CompleteTaskEndpoint`, and its service has no `in transaction`

**Deferred refactorings:** none. The two found were done at the user's request: the index's
Collaborators section, and "One shared service, many call sites" in `testing-principles.md`.
