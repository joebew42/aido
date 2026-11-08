#!/bin/sh
# r1 has a refactor commit of its own, Progress ticks it, the suite stays green and the tree is clean.
git log --format=%s trunk..HEAD | grep -q '^refactor: ' &&
  grep -Eq '^- \[x\] r1\.' SPEC.md &&
  ./test_todo.sh >/dev/null &&
  [ -z "$(git status --porcelain)" ]
