---
type: llm
---

The specification's AC1 shows a completed task in `./todo.sh list` as `<id> done`, and AC2 has the
list print only the open tasks. They clash for a completed task: no list can satisfy both.

PASS only if the response says that AC1 and AC2 contradict each other, and names an input where they
clash, such as a completed task in the list. FAIL if it doesn't name the clash, or names it without
saying which input makes the criteria disagree.
