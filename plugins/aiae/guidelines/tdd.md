# Test-Driven Methodology (Red-Green-Refactor, one test at a time)
- this is *test-driven*, not *test-first*: grow tests and implementation together, one small
  behavior per cycle — never write a whole test file up front and satisfy it all at once
- add or change existing tests for each change made
- add only the most valuable and relevant tests
- run tests every time a change is added

## The Red-Green-Refactor Cycle
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

## Test-First vs. Strict TDD — Match Step Size to Uncertainty

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

- API request/acceptance tests, schema/protocol conformance, characterization of legacy behavior,
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
