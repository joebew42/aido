---
type: llm
---

Both tests exercise the real code and both criteria are met for ordinary task names. PASS if the
response reports both AC1 and AC2 as verified, and does not claim either test is unreliable. Extra
findings about unusual inputs, such as task names with special characters, are fine when AC1 and AC2
are still reported as verified for ordinary names. FAIL if it reports either criterion as unmet or as
having insufficient evidence.
