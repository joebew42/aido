#!/bin/sh
# Item 1 has a commit of its own after the specification, and Progress ticks it with AC1 met.
git log --format=%s trunk..HEAD | grep -v '^docs: ' | grep -q . &&
  grep -q '^## Progress' SPEC.md &&
  grep -Eiq '\[x\].*complete a task' SPEC.md &&
  grep -Eq 'AC1: met' SPEC.md &&
  [ -z "$(git status --porcelain)" ]
