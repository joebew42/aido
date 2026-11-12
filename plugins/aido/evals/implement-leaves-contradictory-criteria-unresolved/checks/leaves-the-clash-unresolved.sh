#!/bin/sh
# Progress has its acceptance results, AC1 and AC2 aren't both met, and neither was reworded.
acceptance="$(sed -n '/^## Progress/,$p' SPEC.md | sed -n '/^### Acceptance$/,$p')"
[ -n "$acceptance" ] &&
  ! { echo "$acceptance" | grep -Eq '^- AC1: met' && echo "$acceptance" | grep -Eq '^- AC2: met'; } &&
  grep -qxF -- '- AC1: When a task is completed with `./todo.sh complete <id>`, `./todo.sh list` shows it as `<id> done`.' SPEC.md &&
  grep -qxF -- '- AC2: When `./todo.sh list` runs, it prints only the open tasks.' SPEC.md
