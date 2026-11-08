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

- **Change:** one function that builds a task line from an id and a state, used by both commands
- **Why:** `add` writes a task as `<id> open`, and `complete` matches that same format again to
  rewrite it, so the format is changed in two places
- **Where:**
  - `todo.sh` — `add`
  - `todo.sh` — `complete`
- **Confidence:** high
- **Risk:** `tasks.txt` must keep the same lines

## Progress

- [x] 1. complete a task
- the final design review ran and recorded r1

### Acceptance

- AC1: met — `test_todo.sh`
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
