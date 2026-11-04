# Test-Driven Methodology (Red-Green-Refactor, one test at a time)
- grow tests and implementation together, one small behavior per cycle — never write a whole test
  file up front and satisfy it all at once
- add or change existing tests for each change made
- add only the most valuable and relevant tests
- run tests every time a change is added

## The Red-Green-Refactor Cycle
Each cycle covers exactly **one** new behavior. A class or service is built from a *sequence* of
these cycles, not a single big one.

0. **PRE-RED**: Before the first test of a unit, run the relevant existing tests to confirm they start GREEN
1. **RED**: Write **one** failing test for the next smallest behavior — nothing more, and no second
   test while red. Watch it fail for the right reason before writing any implementation.
2. **GREEN**: Write the **minimum** code to make that one test pass, in the step your uncertainty
   calls for (see "Step Size" in "The Modes" below):
   - **Obvious implementation** — strict TDD's own escape hatch: when you already know what to type,
     write the real thing directly, and the cycle collapses to "one test, write the real thing"
   - **Fake it** — when you don't yet see the real logic, return a constant; an embarrassing
     hardcoded value is fine if that is all the current tests demand
   - **Triangulate** — let the next test force you to generalize the fake

   Do not implement behavior that no current test demands (no speculative generalization). Run all
   relevant tests to confirm green with no regressions, and do not refactor yet.
3. **REFACTOR**: With all tests green, review the code and refactor if needed:
   - check for code smells (magic numbers, duplication), Single Level of Abstraction, SOLID
     violations and separation of concerns
   - refactor in small steps, re-running tests after each
   - commit stand-alone refactoring separately with a `refactor:` prefix

   Then return to RED for the next behavior.

## The Modes — Let Uncertainty Choose Step Size and Direction

Uncertainty decides both how small the steps are and which way the work grows, part by part. Planning
gives every feature item in a plan a mode, where the user can review it (see "Plan Items" in
`specification.md`), and implementation honours it.

| What's unknown | Mode | Approach |
| --- | --- | --- |
| Nothing: the part conforms to existing code or a known contract | `inside-out` | Test-first, layer by layer |
| How the parts fit, or what an interface should be | `outside-in` | Strict TDD, in tracer bullet slices |
| Logic within one unit | `in-unit` | Strict TDD in that unit, with no direction to choose |

**Inside-out is the default, and it has to be earned.** A part is inside-out only if the plan can cite
the existing code or contract it conforms to. Otherwise the plan names the unknown. Prefer outside-in
when the plan rests on something nobody has run: mocks written from the plan agree with it even when
it is wrong, so a bad assumption would surface only at the end, after the other layers were built on
it.

In every mode, an automatable criterion gets an acceptance test at the boundary, written first. It
stays red as the goal post while the units behind it are grown, and `git-workflow.md` says when it is
committed.

### Step Size

Strict TDD (one test at a time, fake-it → triangulate) and test-first are points on one spectrum of
step size, which tracks how much design you still have to **discover** versus **conform to**. Ask:
*what is this test for?* Anchor on uncertainty, not on layer; the examples are heuristics, not laws.

- **conforming to a known shape** → **test-first**: the test is a specification you satisfy, so write
  it, then write the code. For example an external contract, API request/acceptance tests,
  schema/protocol conformance, characterization of legacy behavior, or pure DTO/mapping/plumbing
- **discovering an unknown shape** → **strict TDD**: the test is a design instrument, so take the
  smallest step and let the next test force the next bit. For example emergent design, branchy edge
  cases, an expensive-to-undo abstraction, domain/application services and complex domain logic, or
  when you feel the urge to over-engineer
- **a helper or small service whose whole implementation fits in your head** → **obvious
  implementation** (≈ test-first)

Each failure mode is a smell that you picked the wrong step size:

- test-first on genuinely complex logic → the red→green gap is huge, debugging is hard, and you
  over-build
- strict TDD on a fixed contract → triangulation theater, ceremony with no design discovered

### `inside-out`

Grow the units layer by layer: domain → application → infrastructure. Each unit still goes one failing
test at a time, but with the real implementation straight away: you already know the shape, so faking
and triangulating would be ceremony.

### `outside-in`

Work through the item's slices in order. A **slice** is one behaviour, connected from the real entry
point to the real effect. Connecting comes first, so the first slice is the thinnest path that works,
and edge cases wait for the later slices.

1. write the slice's acceptance test at the entry point, and watch it fail
2. let it say what is missing: start at the entry point and go inward, one unit at a time
3. grow each unit with strict TDD
4. finish the slice before starting the next

A slice is **finished** only when its acceptance test is green against real code and every unit it
added has its own tests. A thin slice tempts you to hardcode your way to one green acceptance test, or
to skip the unit tests once it is green; the acceptance test stands in for neither. Any guard, such as
authorization, belongs in the first slice, so the behaviour never exists without it.

### `in-unit`

Grow the one unit with strict TDD. There is no direction to choose.
