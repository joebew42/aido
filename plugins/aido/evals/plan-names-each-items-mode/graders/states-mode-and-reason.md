---
type: llm
focus:
  source: file
  path: SPEC.md
---

This is a specification with a `## Plan`. It asks for three things: completing a task, which works
just like adding one in `lib/tasks.sh`; syncing to a calendar provider nobody has called; and a monthly
repeat whose month-end rule is unsettled.

PASS only if every plan item that is not marked `(enabling)` names one of the modes `inside-out`,
`outside-in` or `in-unit` with its reason, and all of these hold:

- an `inside-out` item cites existing code, by file or function, that it conforms to
- an `outside-in` or `in-unit` item names what is unknown
- an `outside-in` item lists its slices in order
- syncing to the provider is not `inside-out`
