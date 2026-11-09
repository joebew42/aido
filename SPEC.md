# Don't take shortcuts when writing tests

## Context

`testing-principles.md` asks for tests with a clear Arrange, Act, Assert structure. It says nothing
about loops that generate tests, such as `for value in [...]: test "testing %s" value`. Agents take
this shortcut. The generated tests get generic names and hide which behaviour they document.

## Intent

The testing guideline tells agents not to generate tests in a loop, and says what to write instead.
That depends on what the loop runs over. A loop over methods that share a behaviour becomes separate
tests, one per method. A loop over inputs to one behaviour becomes one test that documents the
behaviour, or a parameterised test where the stack offers one. The guideline shows each case with a
DON'T and a DO example.

### Examples

A loop over methods that share a behaviour:

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

A loop over inputs to one behaviour:

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

## Out of scope

- logic inside a test body, such as conditionals that decide what to arrange or assert
- other shortcuts in tests
- changes to the skills that load the guideline

## Acceptance criteria

- AC1 (manual): The testing guideline names a loop that generates tests as a shortcut to avoid, with a DON'T example.
- AC2 (manual): For a loop over methods that share a behaviour, the guideline asks for a separate test per method, with a DO example.
- AC3 (manual): For a loop over inputs to one behaviour, the guideline asks for one test that documents the behaviour, with a DO example.
- AC4 (manual): The guideline allows a loop of assertions inside that one test, when a failure names the input that failed.
- AC5 (manual): The guideline welcomes parameterised tests for inputs to one behaviour, when the framework, library or language offers them.
- AC6 (manual): The new examples are stack-agnostic, use the TODO app, and match those under Intent.

## Plan

1. **guideline — don't generate tests in a loop** (AC1, AC2, AC3, AC4, AC5, AC6) — inside-out:
   follows the shape of "Assert Literal Expected Values, Not Recomputed Ones" in
   `plugins/aido/guidelines/testing-principles.md`: a rule, its reason, then ❌/✅ examples, here
   taken from `### Examples` above. Touches the guideline only
   - add the section right after "Structure Tests as Arrange, Act, Assert", since it is about how a
     test is laid out
   - bump `version` in `plugins/aido/.claude-plugin/plugin.json` from 5.6.1 to 5.7.0: new guidance,
     nothing removed
   - no eval case covers this rule. The PR says so
   - run `tests/all.sh`

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. guideline — don't generate tests in a loop
  - "Don't Generate Tests in a Loop" added to `testing-principles.md`, right after "Structure Tests as
    Arrange, Act, Assert", with the examples from `### Examples`
  - plugin version bumped to 5.7.0
- the final design review was skipped
- no eval case covers this rule. The PR says so

### Acceptance

- AC1: met — confirmed by the user: the rule and the ❌ example of a loop over methods, in "Don't Generate Tests in a Loop"
- AC2: met — confirmed by the user: the ✅ example with one test per method, each named after its behaviour
- AC3: met — confirmed by the user: the ✅ example "a task with a blank title is refused"
- AC4: met — confirmed by the user: the loop of assertions whose failure names the title
- AC5: met — confirmed by the user: the ✅ parameterised example, offered where the stack has one
- AC6: met — confirmed by the user: the examples are the pseudocode TODO examples from `### Examples`
