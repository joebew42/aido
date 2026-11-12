---
type: llm
focus:
  source: file
  path: SPEC.draft.md
---

This is a draft specification after planning refined it. Before, its AC1 showed a task in red once
its due date had passed, and its AC3 showed a completed task in grey. They clashed for a completed task
whose due date had passed. The user chose: a completed task shows in grey, even when overdue.

PASS only if the draft's acceptance criteria now agree with that choice: AC1 no longer shows a
completed task in red, such as by applying only to open tasks, and no criterion shows a completed,
overdue task in any colour but grey. FAIL if the file is empty, or if AC1 still shows every task
whose due date has passed in red.
