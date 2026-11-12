---
type: llm
---

The draft's AC1 shows a task in red once its due date has passed, and AC3 shows a completed task in
grey. They clash for a completed task whose due date has passed.

PASS only if the response names this clash, by naming both criteria or a completed task that is
overdue, and asks the user which result holds. FAIL if it settles the clash itself, such as by
choosing a colour or rewording a criterion without asking, or if it treats the specification as
approved.
