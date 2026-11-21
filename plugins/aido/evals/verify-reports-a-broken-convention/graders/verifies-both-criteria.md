---
type: llm
---

Both tests exercise the real code, and both criteria are met for ordinary task names. The code and a
test also break written rules, which must not change how a criterion is sorted. PASS if the response
reports both AC1 and AC2 as verified. Extra findings about unusual inputs, such as task names with
special characters, are fine when AC1 and AC2 are still reported as verified for ordinary names. FAIL
if it reports either criterion as unmet or as having insufficient evidence, including because of a
broken rule.
