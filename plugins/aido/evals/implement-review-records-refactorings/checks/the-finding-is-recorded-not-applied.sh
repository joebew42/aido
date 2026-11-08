#!/bin/sh
# The accepted finding is r1 in Refactorings, the code is as the feature left it, and the tree is clean.
grep -q '^## Refactorings' SPEC.md &&
  grep -Eq '^#+ r1\. ' SPEC.md &&
  git diff --quiet feature-built HEAD -- bin lib test_todo.sh &&
  [ -z "$(git status --porcelain)" ]
