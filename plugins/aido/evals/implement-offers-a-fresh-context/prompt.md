---
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Implement the approved plan in `SPEC.md`, all of it apart from what its `## Progress` defers, without
stopping to ask which items. The tests run with `./test_todo.sh`. If you ask how to continue once
implementation is complete, take the answer as: organize the commits in a fresh context.
