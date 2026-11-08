#!/bin/sh
# Each item has a commit of its own after the specification, and Progress ticks it with its criterion met under ### Acceptance.
acceptance="$(sed -n '/^## Progress/,$p' SPEC.md | sed -n '/^### Acceptance$/,$p')"
[ "$(git log --format=%s trunk..HEAD | grep -cv '^docs: ')" -ge 2 ] &&
  grep -q '^## Progress' SPEC.md &&
  grep -Eiq '\[x\].*complete a task' SPEC.md &&
  grep -Eiq '\[x\].*list the open tasks' SPEC.md &&
  echo "$acceptance" | grep -Eq 'AC1: met' &&
  echo "$acceptance" | grep -Eq 'AC2: met' &&
  [ -z "$(git status --porcelain)" ]
