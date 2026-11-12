---
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Implement every item of the approved plan in `SPEC.md` in this session, using `/aido:2-implement` if
it is available, without stopping to ask which items. Nobody is available to answer questions. The
tests run with `./test_todo.sh`.
