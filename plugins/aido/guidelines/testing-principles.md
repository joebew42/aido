# Testing Principles

## Structure Tests as Arrange, Act, Assert

**Core Rule:** Every test reads top to bottom in three phases, separated by blank lines: **Arrange**
the setup, **Act** once, then **Assert** on the outcome.

- keep **Act** to a single statement, and capture its outcome in a variable
- keep **Act** and **Assert** apart: never call the behaviour under test inside the assertion
- **omit the `# Arrange / # Act / # Assert` labels**: the blank lines already show the structure. A
  test that needs them to be readable needs to be smaller, or a named setup helper

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

## Don't Generate Tests in a Loop

**Core Rule:** Don't write a loop that generates tests, such as `for value in [...]: test "testing %s"
value`. The generated tests get generic names, and hide which behaviour each one documents. What to
write instead depends on what the loop runs over.

**A loop over methods that share a behaviour** becomes a separate test per method, each named after
its behaviour.

```
# ❌ One generated test per method — the names hide which behaviour each one documents
for action in [complete, archive, delete]:
    test "%s by another user" action:
        task = task_owned_by("ann")

        result = action(task, by: "bob")

        assert result == Refused
```

```
# ✅ A separate test per method, each named after its behaviour
test "only the owner can complete a task":
    task = task_owned_by("ann")

    result = task.complete(by: "bob")

    assert result == Refused

test "only the owner can archive a task":
    task = task_owned_by("ann")

    result = task.archive(by: "bob")

    assert result == Refused

test "only the owner can delete a task":
    task = task_owned_by("ann")

    result = task.delete(by: "bob")

    assert result == Refused
```

**A loop over inputs to one behaviour** becomes one test that documents the behaviour. A loop of
assertions inside it is fine, when a failure names the input that failed. Where the framework,
library or language offers parameterised tests, use one instead.

```
# ❌ One generated test per input — named after the value, not the behaviour
for title in ["", "   ", "\t"]:
    test "saving a task titled '%s'" title:
        task = new_task(title: title)

        result = task.save()

        assert result == Refused
```

```
# ✅ One test documents the behaviour, and a failure names the input
test "a task with a blank title is refused":
    for title in ["", "   ", "\t"]:
        task = new_task(title: title)

        result = task.save()

        assert result == Refused, "title: '%s'" title
```

```
# ✅ A parameterised test, where the framework, library or language offers one
test "a task with a blank title is refused" for each title in ["", "   ", "\t"]:
    task = new_task(title: title)

    result = task.save()

    assert result == Refused
```

## Test Collaboration, Real Behaviour End-to-End

Thin **infrastructure that calls in** (a controller, API endpoint or CLI handler) translates input,
delegates to an application service, and maps the result back. Its unit test documents that
**collaboration**, without exercising the service again:

- **stub the service**, and assert it is **called with the expected input**, or **not called** when
  it short-circuits (e.g. an auth guard, a validation refusal)
- assert it **maps or passes through** the service's result correctly
- mocking the service is right here: it is a real service boundary, not an internal data structure

Application and domain code follow the same split, down to the collaborators they call out to:

- **unit tests of application and domain code mock their collaborators to the contract**, such as
  that of `TaskRepository`, because that contract is controlled and known
- **a real implementation is tested alone against the real thing**: `PostgresqlTaskRepository`
  against a PostgreSQL database
- **acceptance and integration tests use the real implementations**
- **do not mock what the project does not control**, such as ORM query methods or third-party
  clients. Where ORM models are their own repositories, there is no separate contract to mock:
  create real records and let the code find them

Leave the **real, end-to-end behaviour** (infrastructure, the real service and persistence) to
integration and acceptance tests. The unit tests stay fast and focused, and don't repeat the
service's own tests.

**Example (API endpoint):** the endpoint test stubs `Service.call`, asserts it received the mapped
arguments (and is skipped for a guest), and asserts the endpoint returned the right result type. The
integration test drives the endpoint against the real service and database.

### Keep the stub in the test that needs it

Set the stub up **inside the example**, in its Arrange step, not in a shared setup hook (`before`,
`beforeEach`, `setUp`) or a shared fixture. Hoisting it splits Arrange from the Act and Assert that
depend on it, and gives every example a return value only some of them use.

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

Keep shared setup hooks for ambient setup that every example depends on and none is *about*:
freezing time, configuring a client, silencing a logger.

### One shared service, many call sites: assert the collaboration, once each

The same rule applies when several call sites delegate to one shared service, where it is most often
missed. Each call site's test asserts only that the service was called with the expected arguments.
What the service *does* is verified **once**, in its own tests.

Asserting the effects again at every call site multiplies the same coverage, and the copies drift: a
missing effect at one site looks the same as a deliberate one.

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

Once a shared service is extracted, collapse the per-effect assertions at each call site. The
extraction isn't finished while they remain.

## Assert Literal Expected Values, Not Recomputed Ones

In request/response and serialization tests, assert the **literal** expected output, not a value
recomputed with the production code's own transformation. Recomputing is tautological: the test
repeats the code's logic, so it passes even when that logic is wrong.

```
# ❌ Tautological — reruns the code's own serialization to build the expectation
completedAt: format_iso8601(to_utc(datetime(2026, 1, 1, 12, utc)))

# ✅ Literal — pins the exact value the API returns
completedAt: "2026-01-01T12:00:00Z"
```

Keep the **input** explicit (e.g. `completed_at: datetime(2026, 1, 1, 12, utc)`) so the fixture is
readable, and hardcode only the **expected** serialized value. When you don't know the literal,
capture it once from the real output and paste it in.

## Avoid Flaky Tests: Precise Assertions Over Partial Matches

**Core Rule:** An assertion must be specific enough to tell the behaviour under test from unrelated
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

A test that sometimes fails on random data is worse than no test: it erodes trust in the whole
suite.
