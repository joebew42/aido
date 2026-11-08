#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../implement-todo.sh"

layered_todo_app
spec_with <<'SPEC'
# Complete a task

## Context

Tasks can be added but never finished.

## Intent

Let a user complete a task.

## Out of scope

Reopening a task.

## Acceptance criteria

- AC1: `bin/todo complete <id>` marks an open task `done` in the store

## Plan

1. **complete a task** (AC1) — inside-out: follows `add_task` in `lib/tasks.sh`. Touches application,
   infrastructure

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. complete a task
- AC1: met — `test_todo.sh`
SPEC

cat > lib/tasks.sh <<'TASKS'
add_task() {
  store_append "$(new_task "$1" "$2")"
}

complete_task() {
  file="${TODO_DB:-tasks.db}"
  awk -F'|' -v id="$1" 'BEGIN { OFS = "|" } $1 == id && $2 == "open" { $2 = "done" } { print }' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}
TASKS
sed -i 's/^  add) add_task "\$2" "\$3" ;;$/&\n  complete) complete_task "$2" ;;/' bin/todo
cat > test_todo.sh <<'TEST'
#!/bin/sh
export TODO_DB="$(mktemp)"

./bin/todo add 1 "Pay rent"
grep -q "^1|open|Pay rent$" "$TODO_DB" || { echo "FAIL: add"; exit 1; }

./bin/todo complete 1
grep -q "^1|done|Pay rent$" "$TODO_DB" || { echo "FAIL: complete"; exit 1; }

echo "all passed"
TEST
git add . && git commit -q -m "feat: complete a task"
git tag feature-built
