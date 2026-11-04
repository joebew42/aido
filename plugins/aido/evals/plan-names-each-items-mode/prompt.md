---
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash, Write, Edit]
---

Plan the approved specification in `SPEC.md`, using `/aido:1-plan` if it is available. Nobody is
available to answer questions, so skip the enabling refactoring analysis. Write the plan into `SPEC.md`
and stop there: do not create a branch, commit anything or implement anything.
