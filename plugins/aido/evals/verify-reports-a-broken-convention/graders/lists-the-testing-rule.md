---
type: llm
---

aido's testing rules say never to call the behaviour under test inside the assertion. The AC2 test in
`test_todo.sh` runs `./todo.sh complete 1` inside its `[ ... ]` check. PASS only if the response lists
this broken rule in a section for conventions, apart from any section for deviations, and names
`testing-principles.md` as its source and `test_todo.sh` as where it breaks. FAIL if it doesn't
mention it, or names no source for the rule.
