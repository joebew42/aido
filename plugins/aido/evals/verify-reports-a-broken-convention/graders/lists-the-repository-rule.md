---
type: llm
---

`AGENTS.md` says scripts use only POSIX shell tools, with no `perl`. The new `complete` command in
`todo.sh` calls `perl` to mark the task done. PASS only if the response lists this broken rule in a
section for conventions, apart from any section for deviations, and names `AGENTS.md` as its source
and `todo.sh` as where it breaks. FAIL if it reports the rule only as a deviation, or doesn't mention
it.
