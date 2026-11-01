# Testing Principles

## Structure Tests as Arrange, Act, Assert

**Core Rule:** Every test reads top-to-bottom in three phases — **Arrange** the setup, **Act**
once, then **Assert** on the outcome — separated by blank lines.

- keep **Act** to a single statement and capture its outcome in a variable
- keep **Act** and **Assert** as separate statements — never invoke the behaviour under test
  inside the assertion itself
- **omit the `# Arrange / # Act / # Assert` labels** — the blank lines already carry the
  structure, so the labels only restate what the layout shows; if a test needs them to be
  readable, the fix is a smaller test or a named setup helper, not a label

```
test "completing an already completed task is rejected":
    task = completed_task(title: "Pay rent", completed_at: "2026-10-01")

    result = task.complete()

    assert result == Rejected
    assert task.completed_at == "2026-10-01"
```

```
# Avoid — act nested inside the assertion, no separation
test "completing an already completed task is rejected":
    assert completed_task(title: "Pay rent", completed_at: "2026-10-01").complete() == Rejected
```

**Why:** the separation makes the cause (Act) and the effect (Assert) obvious, keeps one
behaviour per test, and produces clearer failures — you can see exactly which call and which
expectation broke.

## Test Collaboration, Real Behaviour End-to-End

Thin **infrastructure that calls in** (controller, API endpoint, CLI handler, etc.) exists to
translate input, delegate to an application service, and map the result back. Its unit test should
document that **collaboration**, not re-exercise the service:

- **stub the service** and assert it is **called with the expected input** — or assert it is
  **not called** when it short-circuits (e.g. an auth guard, a validation refusal)
- assert it **maps / passes through** the service's result correctly
- mocking the service is appropriate here — it is a genuine service boundary, not an internal
  data structure

Application and domain code follow the same split, down to the collaborators they call out to:

- **unit tests of application and domain code mock their collaborators to the contract**, such as
  that of `TaskRepository`, because that contract is controlled and known
- **a real implementation is tested alone against the real thing**: `PostgresqlTaskRepository`
  against a PostgreSQL database
- **acceptance and integration tests use the real implementations**
- **do not mock what the project does not control**, such as ORM query methods or third-party
  clients. Where ORM models are their own repositories, there is no separate contract to mock:
  create real records and let the code find them

Leave the **real, end-to-end behaviour** (infrastructure + the real service + persistence) to
integration / acceptance tests. This keeps these unit tests fast and focused and avoids duplicating
the service's own unit tests.

**Example (API endpoint):** the endpoint test stubs `Service.call`, asserts it received the mapped
arguments (and is skipped for a guest), and asserts the endpoint returned the right result type; the
integration test drives the endpoint against the real service and database.

### Keep the stub in the test that needs it

Set the stub up **inside the example**, as part of its Arrange step — not in a shared setup hook
(`before`, `beforeEach`, `setUp`) or a fixture shared across the group. The stub is the test's setup; hoisting it splits Arrange away from
the Act and Assert that depend on it, so the example no longer reads top-to-bottom.

Hoisting also hides mismatches between what each example sets up and what it actually needs. A
shared setup hook that stubs a return value silently hands that return value to examples
that only assert on the arguments — inlining makes the unused half visible and lets each example
stub exactly what it uses.

```
# ❌ Arrange lives somewhere else; both examples get a return value only one of them uses
setup:
    progress = ListProgress.Empty()
    stub ListProgress.call returning progress

test "resolves the list progress":
    result = resolve()
    # ...

# ✅ Each example arranges what it needs
test "resolves the list progress":
    progress = ListProgress.Empty()
    stub ListProgress.call returning progress

    result = resolve()

    assert result == progress

test "falls back to the default list color when none is set":
    stub ListProgress.call        # no return value — nothing asserts on it
    # ...
```

Reserve shared setup hooks for genuinely ambient setup that every example in the group depends on and none
of them is *about* — freezing time, configuring a client, silencing a logger.

### One shared service, many call sites: assert the collaboration, once each

The same rule applies when several call sites delegate to one shared service — and this is where it
is most often missed. Each call site's test asserts only that the service was called with the
expected arguments. What the service *does* is verified **once**, in its own tests.

Re-asserting the downstream effects at every call site multiplies the same coverage by the number of
call sites, and each new effect added to the shared service then has to be added to every one of
those tests — so they drift, and a missing effect at one site looks identical to a deliberate one.

```
# ❌ Seven call sites x three effects = 21 examples asserting the same three things
test "sends the invitation email":
    sharing.share_list()
    assert SendInvitationJob was enqueued with list.id
# ...and the same again for the other two effects, in all seven test files

# ✅ Each call site documents the collaboration
test "runs the list shared side effects":
    stub ListShared.call

    sharing.share_list()

    assert ListShared.call was called with list

# ✅ The shared service's tests own the effects, and are the only place they change
describe ListShared:
    test "sends the invitation email"
    test "adds the list to the collaborator's sidebar"
```

**Before extracting the shared service**, the per-effect assertions at each call site were correct —
they were the only place that behaviour existed. Once the extraction lands, collapse them: the
extraction is not finished while the old assertions remain.

## Scope the Pre-Commit Suite to What the Change Touches

`code-standards.md` requires running "the full relevant test suite, not just the test for the file
directly modified". **Relevant** has an upper bound as well as a lower one: the unit's own tests,
the tests of its collaborators, and the tests of every file the change actually edited. It does
**not** mean the enclosing directory.

Reaching for a whole directory (all request tests, all model tests) is not extra safety — it is a worse signal. It sweeps in tests the change cannot affect, so any failure among
them has to be disproved before the commit can proceed, and a genuinely broken pre-existing test
looks identical to a regression you just introduced. The targeted set runs in seconds and fails
for reasons you can act on.

Derive the list mechanically from the diff rather than by directory:

```sh
git diff --name-only main...HEAD          # what changed
# → run each changed test, the test for each changed source file, and their collaborators' tests
```

## Assert Literal Expected Values, Not Recomputed Ones

In request/response and serialization tests, assert the **literal** expected output — not a value
recomputed with the same transformation the production code uses. Recomputing is tautological: the
test reproduces the code's logic, so it passes even when that logic is wrong.

```
# ❌ Tautological — reruns the code's own serialization to build the expectation
completedAt: format_iso8601(to_utc(datetime(2026, 1, 1, 12, utc)))

# ✅ Literal — pins the exact value the API returns
completedAt: "2026-01-01T12:00:00Z"
```

Keep the **input/setup** explicit (e.g. `completed_at: datetime(2026, 1, 1, 12, utc)`) so the
fixture is readable, and hardcode only the **expected** serialized value. When you don't know the
literal, capture it once from the real output (a runner or a first test run) and paste it in.

## Avoid Flaky Tests: Precise Assertions Over Partial Matches

**Core Rule:** Assertions must be specific enough to isolate the behavior under test from unrelated dynamic data.

### The Problem

Tests become flaky when assertions match unintended data. This typically happens when:

1. **Auto-generated data** contains values that collide with test assertions
2. **Vague assertions** match partial strings or numbers that appear in multiple contexts

### Example: Due Date Filtering

A test filtered TODO items by their due day and verified results, but the assertion was too vague:

```
# ❌ Flaky - "20" matched generated list name "List 0020"
- Filter tasks due on day "10"
- Assert page contains "10"
- Assert page does NOT contain "20"  # Failed when a generated list name or ID contained "20"
```

**The fix:** Assert on complete, contextual values:

```
# ✅ Stable - full context prevents collisions
- Assert page contains "Pay rent — due Oct 10" (complete task)
- Assert page does NOT contain "Renew passport — due Oct 20"
```

### Example: Task Status Filtering

Testing a TODO list filtered by task status:

```
# ❌ Flaky - "done" and "undone" could match task titles, notes, etc.
- Filter tasks by status: "done"
- Assert page contains "done"
- Assert page does NOT contain "undone"  # Fails if a note says "undone until Friday"
```

**The fix:** Use complete, meaningful identifiers:

```
# ✅ Stable - use unique, explicit task titles
- Create task "Pay rent" with status "done"
- Create task "Renew passport" with status "open"
- Filter by status: "done"
- Assert page contains "Pay rent"
- Assert page does NOT contain "Renew passport"
```

## Guidelines to Prevent Flaky Tests

### 1. Assert on Complete, Contextual Values

- ❌ **Don't:** Assert on fragments that could match unrelated data
- ✅ **Do:** Assert on complete values that include sufficient context

```
# ❌ Bad - short strings/numbers have high collision risk
Assert page contains "5"
Assert page contains "open"

# ✅ Good - complete values are unambiguous
Assert page contains "5 tasks left"
Assert page contains "Task #12345: open"
```

### 2. Scope Assertions to Specific Page Regions

Limit assertions to relevant sections of the interface to reduce collision with unrelated content.

```
# ✅ Better - scoped to relevant section
Within search results section:
  - Assert contains "Pay rent — due Oct 10"

Within task status section:
  - Assert contains "open"
```

### 3. Control Test Data Creation

Use explicit, deterministic values for test data instead of auto-generated values.

```
# ❌ Risky - auto-generated values may collide
Create task with random title

# ✅ Safe - explicit, predictable test data
Create task with:
  - title: "Water the plants"
  - list: "Home chores"
```

### 4. Think About Collision Domains

Before asserting on short strings or numbers, ask: **"Could this match unrelated data?"**

**Common collision risks:**
- **Numbers:** IDs, counts, dates, prices, postal codes, phone numbers
- **Status words:** "active", "pending", "complete" (may appear in usernames, descriptions)
- **Generic terms:** "test", "user", "admin" (often used in generated data)
- **Timestamps:** "2024", "12:00" (may appear in multiple contexts)

### 5. Write Assertions That Fail Clearly

Specific assertions produce actionable failure messages.

```
# ❌ Unclear failure
Assert page does NOT contain "20"
→ Failure: "found '20' in page content" (where? what matched?)

# ✅ Clear failure
Assert page does NOT contain "Renew passport — due Oct 20"
→ Failure: "found 'Renew passport — due Oct 20' in results table" (immediately actionable)
```

### 6. Use Semantic Selectors for Precise Selection

When testing dynamic content, use semantic identifiers (data attributes, IDs, classes) instead of text matching.

```
# ❌ Fragile - text may change or collide
Assert page contains "Water the plants - due today"

# ✅ Robust - semantic selector
Assert element with data-task-id="water-plants" exists
Assert element with data-task-id="water-plants" contains "due today"
```

## Summary Checklist

Before writing an assertion, verify:

- [ ] Could this value match auto-generated data elsewhere? (IDs, names, timestamps)
- [ ] Am I asserting on a complete, meaningful value? (not just fragments)
- [ ] Is my assertion scoped to the relevant interface region?
- [ ] Have I controlled test data that appears in assertions? (explicit values)
- [ ] Will the failure message clearly indicate what went wrong?

**Remember:** A test that occasionally fails due to random data is worse than no test at all—it erodes trust in the entire test suite.
