# Systemic Refactoring — Look Beyond the Changed Lines

The REFACTOR step improves the code just written. It cannot see that another module already owns
the concept, enforces the same rule, or offers the abstraction the new code reinvented. A
**systemic design check** looks for exactly that, and it is a separate, less frequent activity —
never a broad scan after every cycle:

- **when planning** — look for *enabling* refactorings: changes that make this feature easy before
  it is built ("make the change easy, then make the easy change")
- **during implementation, on evidence** — when a cycle reveals a possibly shared concept, a
  duplicated business rule or a boundary crossing
- **before the feature is done** — once, over the whole diff against the default branch

The planning and before-done checks can take long and are not always needed, so they are offered
to the user rather than run unconditionally; the on-evidence check is part of the cycle.

It applies whichever testing strategy is in use: the testing strategy decides how to
discover behaviour, the systemic check decides how widely to look before settling the design.

**What it looks for** — each judged by the rule that already defines it in `code-standards.md`:

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
- similar-looking code is not proof — confirm the two pieces encode the same business meaning
  before merging them; two look-alikes are often two different domain concepts
- "nothing to refactor" is a normal, valid outcome
- a session that receives a finding from a subagent opens the cited files and confirms the finding
  against the current code before relying on it; each skill says which findings this covers

**What every finding states:**

- **Observation** — what the code shows, leaving out anything inferred
- **Evidence** — `path` — `Symbol`, one line each
- **Competing explanations** — the other explanations considered and what settled each, always
  including that no change is needed
- **Assumptions** — what the finding takes to be true that the code does not show, or `none`
- **Confidence** — high, medium or low, as defined below
- **What would change it** — the evidence that would change the conclusion
- **Recommendation** — the smallest useful refactoring
- **Why it matters** — what the problem costs the design if it stays, such as a rule changed in
  two places
- **Risk** — behaviour or consumers that could be affected

**Confidence** rests on the strength of the evidence, not on how plausible the finding sounds:

- **high** — the evidence is checked against the current code, it settles every competing
  explanation, and no assumption could change the conclusion
- **medium** — the evidence is checked against the current code, but a competing explanation or an
  assumption could still change the conclusion
- **low** — the finding rests mainly on assumptions or on similar-looking code

A finding carries no numeric scores, weightings or probabilities: they suggest a precision the
evidence does not have.

The on-evidence check during implementation writes this reasoning out only for a finding shown to
the user or recorded as deferred, so routine cycles stay light.

**Showing a finding:** In chat, a finding is shown as one line: its Recommendation and Why it matters,
such as "Move the due-date check into the task, so the rule lives in one place". When the user asks
for a finding in full, show every field. A finding recorded in a file keeps every field: the
specification's `## Design notes` and `## Progress`, and an opportunity's file.

**Classify every finding:**

- **fix now** — a design problem this change introduced
- **refactor now** — directly related to the change, bounded, and covered by tests
- **defer** — worthwhile but broader or riskier than this change justifies; record it with its
  evidence and park it, as **Parking an opportunity** describes
- **no action** — an intentional difference, or a hypothesis the evidence did not support

When planning, nothing has been built yet, so fix now and refactor now collapse into one outcome:
**enabling** — a refactoring that makes this feature easier and is planned before it.

A low-confidence finding is classified only as **defer** or **no action**, and names the evidence
still missing.

**Parking an opportunity:** a refactoring is made as part of a working feature, so it is never
tracked as an issue. The session parks one worth keeping, until a planned change can pull it in:

- each opportunity has its own file,
  `~/.claude/repos/<repo-name>/refactoring-opportunities/YYYY-MM-DD-<refactoring-title>.md`, named
  with the day it was parked and its title in lower case with hyphens. `<repo-name>` is as
  `/aido:map-architecture` defines it
- the file holds the nature of the refactoring, the design smell it solves and why that matters, then
  the rest of the finding:

  ```markdown
  # <title>

  Parked at `<short SHA>`.

  ## Refactoring
  <the Recommendation: what would change>

  ## Design smell
  <what kind of problem it is, and the Observation>

  ## Why it matters
  <the Why it matters field>

  ## Finding
  <Evidence, Competing explanations, Assumptions, Confidence, What would change it and Risk>
  ```
- before parking, look for a file with the same evidence, and do not add a second one
- `/aido:1-plan` offers the opportunities that fit a planned change, and the file is removed once the
  refactoring is committed, or when the code no longer shows the problem
- the folder lives outside the repository, on this machine: it is not shared, and cannot be rebuilt

**Boundaries:** behaviour and public contracts are preserved and tests stay green; no cleanup of
unrelated modules, no abstraction for superficial duplication, no style rewrites; a refactoring
that spans modules needs the user's approval first; one that cannot be validated safely is
deferred.

**Stop searching** once you can answer, with evidence: where the behaviour belongs, which existing
behaviour or abstraction is relevant, which boundaries must hold, which other modules or consumers
are affected, and what uncertainty could still change the design. Start from the diff and a few
searches for the domain's own vocabulary; widen only when a finding points somewhere wider. Carry
forward conclusions with file references, not raw search output.
