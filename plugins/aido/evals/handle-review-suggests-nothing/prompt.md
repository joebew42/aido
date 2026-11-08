---
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Handle the review of this branch's pull request, using `/aido:5-handle-review` if it is available. There
is no GitHub access here: the review comments are in `.fixture/review.md`. The tests run with
`./test_todo.sh`. If you ask which feedback to implement, take the answer as: approve all.
