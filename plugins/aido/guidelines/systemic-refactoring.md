# Systemic Refactoring — Look Beyond the Changed Lines

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

**What every finding states:**

- **Observation** — what looks wrong
- **Evidence** — `path` — `Symbol`, one line each
- **Recommendation** — the smallest useful refactoring
- **Risk** — behaviour or consumers that could be affected

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
