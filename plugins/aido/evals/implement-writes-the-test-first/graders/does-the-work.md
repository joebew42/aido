---
type: llm
focus: { source: file, path: todo.sh }
---

PASS only if this script has a `complete` command that marks an open task `done` in `tasks.txt`, and
that prints `already completed` and exits with status 1 for a task already done.
