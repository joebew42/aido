#!/bin/sh
# Each item has a commit of its own after the specification, and Progress ticks it with its criterion met.
[ "$(git log --format=%s trunk..HEAD | grep -cv '^docs: ')" -ge 2 ] &&
  grep -q '^## Progress' SPEC.md &&
  grep -Eiq '\[x\].*complete a task' SPEC.md &&
  grep -Eiq '\[x\].*list the open tasks' SPEC.md &&
  grep -Eq 'AC1: met' SPEC.md &&
  grep -Eq 'AC2: met' SPEC.md &&
  [ -z "$(git status --porcelain)" ]
