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
(`before`, `beforeEach`, `setUp`) or a fixture shared across the group. Hoisting it splits Arrange
from the Act and Assert that depend on it, and hands every example a return value only some of them
use.

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

Re-asserting the downstream effects at every call site multiplies the same coverage, and the copies
drift: a missing effect at one site looks identical to a deliberate one.

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

Once a shared service is extracted, collapse the per-effect assertions at each call site: the
extraction is not finished while they remain.

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

**Core Rule:** Assertions must be specific enough to isolate the behavior under test from unrelated
dynamic data. Before asserting on a short string or number, ask: **"Could this match unrelated
data?"** IDs, counts, dates, prices, status words ("active", "complete"), generic terms ("test",
"admin") and timestamps all collide easily.

- **assert on complete, contextual values** rather than fragments
- **scope assertions** to the relevant region of the interface
- **control test data**: explicit, deterministic values instead of auto-generated ones
- **use semantic selectors** (data attributes, IDs, classes) over text matching for dynamic content
- **write assertions that fail clearly**, so the failure says what matched and where

```
# ❌ Flaky - "20" matched the generated list name "List 0020"
Filter tasks due on day "10"
Assert page contains "10"
Assert page does NOT contain "20"

# ✅ Stable - explicit test data, complete values, and a failure that names what matched
Create task "Pay rent" due Oct 10, and task "Renew passport" due Oct 20
Filter tasks due on day "10"
Within search results: assert contains "Pay rent — due Oct 10"
Within search results: assert does NOT contain "Renew passport — due Oct 20"
```

A test that occasionally fails due to random data is worse than no test at all: it erodes trust in
the entire suite.
