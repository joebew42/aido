---
type: llm
focus:
  source: file
  path: SPEC.draft.md
---

This is a draft specification after planning refined it. Before, its acceptance criteria were:

- AC1: When a task's due date has passed, `todo.sh list` shows it in red.
- AC2: When a task is due today, `todo.sh list` shows it in bold.
- AC3: When a task is completed, `todo.sh list` shows it in grey.

PASS only if the draft still has AC1, AC2 and AC3, and each ID still names the same behaviour: AC1 an
overdue task in red, AC2 a task due today in bold, AC3 a completed task in grey. Rewording a criterion
is fine, and so are new criteria with new IDs. FAIL if the file is empty, or if any of the three IDs is
missing, renumbered or reused for another behaviour.
