---
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Run `/aido:2-implement` on the approved plan in `SPEC.md`. Every plan item is already done. Run the
final design review, and accept every finding you confirm. Nobody is available to answer other
questions. The tests run with `./test_todo.sh`.
