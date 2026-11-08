# Systemic Refactoring — Look Beyond the Changed Lines

The REFACTOR step improves the code just written. It can't see that another module already owns the
concept, enforces the same rule, or offers the abstraction the new code reinvented. A **systemic
design check** looks for that. It runs less often, and is never a broad scan after every cycle:

- **when planning** — look for *enabling* refactorings, which make this feature easy before it is
  built ("make the change easy, then make the easy change")
- **during implementation, on evidence** — when a cycle reveals a possibly shared concept, a
  duplicated business rule or a boundary crossing
- **before the feature is done** — once, over the whole diff against the default branch

The planning and before-done checks can take long and aren't always needed, so they are offered to
the user. The design check during a cycle is part of the cycle.

It works with any testing strategy: the strategy decides how to discover behaviour, and this check
decides how widely to look before settling the design.

**What it looks for**, each judged by the rule in `code-standards.md` that defines it:

- **duplicated knowledge** — another module enforces the same business rule or invariant → "avoid
  duplicating logic — search before extracting" under Code Quality
- **misplaced ownership** — the behaviour belongs to an object or module that already owns the
  concept → "aggregates and entities hold the behaviour" and "domain services" under Architecture
- **reinvented abstraction** — a pattern, collaborator or term that already exists → "don't invent
  domain vocabulary" under Code Quality, "Existing organization" and "Existing tooling" under
  Implementation Guidelines
- **crossed boundary** — an outward dependency or unwanted coupling → "The Dependency Rule"

**Evidence before action:**

- every finding names the files and symbols it rests on, checked against the current code
- similar-looking code is not proof. Confirm the two pieces mean the same business thing before
  merging them: two look-alikes are often two different domain concepts
- "nothing to refactor" is a normal, valid outcome
- a session that receives a finding from a subagent opens the cited files and confirms the finding
  against the current code before relying on it. Each skill says which findings this covers

**Before recording a finding**, weigh it:

- the competing explanations for what the code shows, always including that no change is needed, and
  what settles each
- what the finding assumes that the code does not show
- what evidence would change the conclusion

These shape the finding and its confidence. They are not written down.

**What every finding states**, in short plain sentences:

- **Change** — the smallest useful refactoring
- **Why** — what the code shows, and what it costs if it stays, such as a rule changed in two places
- **Where** — `path` — `Symbol`, one line each
- **Confidence** — high, medium or low, as defined below, with its reason when it isn't high
- **Risk** — behaviour or consumers that could be affected

**Confidence** rests on the evidence, not on how plausible the finding sounds:

- **high** — the evidence is checked against the current code, it settles every competing
  explanation, and no assumption could change the conclusion
- **medium** — the evidence is checked against the current code, but a competing explanation or an
  assumption could still change the conclusion
- **low** — the finding rests mainly on assumptions or on similar-looking code

A finding carries no numeric scores, weightings or probabilities: they suggest a precision the
evidence doesn't have.

The design check during implementation writes a finding out only when it is shown to the user,
planned or recorded as deferred. Routine cycles stay light.

**Showing a finding:** In chat, a finding is shown as one line: its Change and Why,
such as "Move the due-date check into the task, so the rule lives in one place". When the user asks
for a finding in full, show every field. A finding recorded in a file keeps every field: the
specification's `## Design notes`, `## Refactorings` and `## Progress`, and an opportunity's file.

**Classify every finding:**

- **fix now** — a design problem this change introduced
- **refactor now** — directly related to the change, bounded, and covered by tests
- **defer** — worthwhile, but broader or riskier than this change justifies. Record it with its
  evidence, and park it as **Parking an opportunity** describes
- **no action** — an intentional difference, or a hypothesis the evidence did not support

When planning, nothing is built yet, so fix now and refactor now collapse into one outcome:
**enabling**, a refactoring planned before the feature to make it easier. At the final design
review, fix now and refactor now also collapse into one outcome: **planned**, recorded in the
specification's `## Refactorings` and built later, like a plan item.

A low-confidence finding is classified only as **defer** or **no action**, and names the evidence
still missing.

**Parking an opportunity:** a refactoring is made as part of a working feature, so it is never
tracked as an issue. Park one worth keeping until a planned change can pull it in:

- each opportunity has its own file,
  `~/.claude/repos/<repo-name>/refactoring-opportunities/YYYY-MM-DD-<refactoring-title>.md`, named
  with the day it was parked and its title in lower case with hyphens. `<repo-name>` is as
  `/aido:map-architecture` defines it
- the file holds the finding:

  ```markdown
  # <title>

  Parked at `<short SHA>`.

  - **Change:** …
  - **Why:** …
  - **Where:** `lib/tasks.sh` — `add_task`
  - **Confidence:** …
  - **Risk:** …
  ```
- before parking, look for a file with the same evidence, and don't add a second one
- `/aido:1-plan` offers the opportunities that fit a planned change. The file is removed once the
  refactoring is committed, or when the code no longer shows the problem
- the folder lives on this machine, outside the repository: it isn't shared, and can't be rebuilt

**Boundaries:** behaviour and public contracts stay as they are, and tests stay green. No cleanup of
unrelated modules, no abstraction for superficial duplication, no style rewrites. A refactoring that
spans modules needs the user's approval first. One that can't be validated safely is deferred.

**Stop searching** once you can answer, with evidence: where the behaviour belongs, which existing
behaviour or abstraction is relevant, which boundaries must hold, which other modules or consumers
are affected, and what uncertainty could still change the design. Start from the diff and a few
searches for the domain's own vocabulary. Widen only when a finding points somewhere wider. Carry
forward conclusions with file references, not raw search output.
