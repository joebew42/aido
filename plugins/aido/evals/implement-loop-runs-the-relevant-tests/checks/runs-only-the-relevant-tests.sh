#!/bin/sh
# The item is ticked, and the backup tests, unrelated to the plan, never ran.
grep -Eiq '\[x\].*complete a task' SPEC.md &&
  [ ! -e .fixture/whole-suite-ran ] &&
  [ -z "$(git status --porcelain)" ]
