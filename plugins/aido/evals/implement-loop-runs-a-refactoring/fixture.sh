#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../implement-todo.sh"

todo_app
spec_with <<'SPEC'
# Complete a task

## Context

Tasks can be added but never finished.

## Intent

Let a user complete a task.

## Out of scope

Reopening a task.

## Acceptance criteria

- AC1: completing an open task with `./todo.sh complete <id>` marks it `done` in `tasks.txt`

## Plan

1. **complete a task** (AC1) — inside-out: follows the `add` command in `todo.sh`. Touches
   infrastructure

The enabling refactoring analysis was skipped.

## Refactorings

### r1. name the task line format once

- **Observation:** `add` writes a task as `<id> open`, and `complete` matches that same format again
  to rewrite it
- **Evidence:** `todo.sh` — `add`; `todo.sh` — `complete`
- **Competing explanations:** no change needed, as there are only two commands. Settled because the
  format is one rule, and a third command would copy it again
- **Assumptions:** none
- **Confidence:** high
- **What would change it:** the two formats meaning different things
- **Recommendation:** one function that builds a task line from an id and a state, used by both
  commands
- **Why it matters:** the task line format is changed in two places
- **Risk:** `tasks.txt` must keep the same lines

## Progress

- [x] 1. complete a task
- AC1: met — `test_todo.sh`
- the final design review ran and recorded r1
SPEC

cat > todo.sh <<'TODO'
#!/bin/sh
case "$1" in
  add) echo "$2 open" >> tasks.txt ;;
  complete)
    awk -v id="$2" '$0 == id " open" { print id " done"; next } { print }' tasks.txt > tasks.tmp
    mv tasks.tmp tasks.txt
    ;;
esac
TODO
cat > test_todo.sh <<'TEST'
#!/bin/sh
rm -f tasks.txt

./todo.sh add 1
grep -q "^1 open$" tasks.txt || { echo "FAIL: add"; exit 1; }

./todo.sh add 2
./todo.sh complete 1
grep -q "^1 done$" tasks.txt || { echo "FAIL: complete"; exit 1; }
grep -q "^2 open$" tasks.txt || { echo "FAIL: complete changed another task"; exit 1; }

echo "all passed"
TEST
printf 'tasks.tmp\n' >> .gitignore
git add . && git commit -q -m "feat: complete a task"
