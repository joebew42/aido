# Test-Driven Methodology
- write the tests before the code they cover, and give every unit tests of its own
- add or change existing tests for each change made
- add only the most valuable and relevant tests
- run tests every time a change is added

## The Test-Driven Cycle
A unit, such as a class, a service or a module, is built from its tests, at the step size its mode
calls for (see "Step Size" in "The Modes" below).

0. **BEFORE THE FIRST TEST**: run the relevant existing tests to confirm they start green
1. **TESTS, THEN CODE**:
   - a unit that is a contract, a mapping or a DTO, and relies on no existing code: write the tests
     for every behaviour the plan gives it, together, then the code that makes them pass
   - every other unit, in every mode, including an `inside-out` unit that relies on existing code:
     write **one** test for the next behaviour, then the code for it, then the next test. Never write
     a second test while one is failing

   In every mode, write the real implementation straight away: no hardcoded value to pass a test, and
   no test whose only job is to force generalizing one. Do not implement behaviour that no test
   demands (no speculative generalization). Run the relevant tests after every change.
2. **CHECK THAT THE TESTS CAN FAIL**: once all of the unit's tests are green, set aside the unit's
   production changes, for example with `git stash push --include-untracked -- <its production
   files>`. Then run its new tests, and confirm each one fails for the right reason. Then restore the
   changes, with `git stash pop`, and confirm they are green again. A new test that still passes
   without the code doesn't test it: fix the test before going on.
3. **REFACTOR**, once per unit, with all tests green: review the unit and refactor if needed:
   - check for code smells (magic numbers, duplication), Single Level of Abstraction, SOLID
     violations and separation of concerns
   - refactor in small steps, re-running tests after each
   - commit stand-alone refactoring separately with a `refactor:` prefix

   Then start the next unit.

## The Modes — Let Uncertainty Choose Step Size and Direction

Uncertainty decides both how small the steps are and which way the work grows, part by part. Planning
gives every feature item in a plan a mode, where the user can review it (see "Plan Items" in
`specification.md`), and implementation honours it.

| What's unknown | Mode | Approach |
| --- | --- | --- |
| Nothing: the part conforms to existing code or a known contract | `inside-out` | Layer by layer, one test at a time where it relies on existing code |
| How the parts fit, or what an interface should be | `outside-in` | One test at a time, in tracer bullet slices |
| Logic within one unit | `in-unit` | One test at a time in that unit, with no direction to choose |

**Inside-out is the default, and it has to be earned.** A part is inside-out only if the plan can cite
the existing code or contract it conforms to. Otherwise the plan names the unknown. Prefer outside-in
when the plan rests on something nobody has run: mocks written from the plan agree with it even when
it is wrong, so a bad assumption would surface only at the end, after the other layers were built on
it.

In every mode, an automatable criterion gets an acceptance test at the boundary, written first, which
stays red as the goal post while the units behind it are grown.

### Step Size

Step size is how many tests you write before the code: all of a unit's tests, or one. It tracks how
much design you still have to **discover** versus **conform to**. Ask: *what will the next test run
tell me?* Anchor on uncertainty, not on layer; the examples are heuristics, not laws.

- **conforming to a known shape** → **test-first**: the tests are a specification you satisfy, so
  write the unit's tests together, then the code. Only a contract, a mapping or a DTO grows this way,
  and only when it relies on no existing code
- **discovering an unknown shape** → **one test at a time**: each run tells you something you couldn't
  predict, so write one test, make it pass with the real code, and let what the run shows steer the
  next test. For example emergent design, branchy edge cases, an expensive-to-undo abstraction,
  domain/application services and complex domain logic, or when you feel the urge to over-engineer.
  Existing code counts too: it may not behave as it reads, and a run after each test is what shows
  it. `outside-in` and `in-unit` units grow this way, and so does any `inside-out` unit that relies on
  existing code

Each failure mode is a smell that you picked the wrong step size:

- test-first on genuinely complex logic → the red→green gap is huge, debugging is hard, and you
  over-build
- one test at a time on a fixed contract → many runs that tell you nothing you didn't already know

### `inside-out`

Grow the units layer by layer: domain → application → infrastructure. A unit that relies on existing
code grows one test at a time, because that code may not do what its name says. Only a contract, a
mapping or a DTO that relies on no existing code has its tests written together, then its code.

### `outside-in`

Work through the item's slices in order. A **slice** is one behaviour, connected from the real entry
point to the real effect. Connecting comes first, so the first slice is the thinnest path that works,
and edge cases wait for the later slices.

1. write the slice's acceptance test at the entry point, and watch it fail
2. let it say what is missing: start at the entry point and go inward, one unit at a time
3. grow each unit one test at a time
4. finish the slice before starting the next

A slice is **finished** only when its acceptance test is green against real code and every unit it
added has its own tests. A thin slice tempts you to hardcode your way to one green acceptance test, or
to skip the unit tests once it is green; the acceptance test stands in for neither. Any guard, such as
authorization, belongs in the first slice, so the behaviour never exists without it.

### `in-unit`

Grow the one unit one test at a time. There is no direction to choose.
