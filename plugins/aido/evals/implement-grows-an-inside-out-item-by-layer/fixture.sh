#!/usr/bin/env bash
set -euo pipefail

git init -q -b trunk .
git config user.name "Fixture"
git config user.email "fixture@example.com"

mkdir -p bin lib

cat > bin/todo <<'EOF'
#!/bin/sh
root="$(dirname "$0")/.."
. "$root/lib/task.sh"
. "$root/lib/task_store.sh"
. "$root/lib/tasks.sh"

case "$1" in
  add) add_task "$2" "$3" ;;
  *) echo "unknown command: $1" >&2; exit 64 ;;
esac
EOF

cat > lib/task.sh <<'EOF'
new_task() {
  printf '%s|open|%s\n' "$1" "$2"
}
EOF

cat > lib/task_store.sh <<'EOF'
store_file() {
  echo "${TODO_DB:-tasks.db}"
}

store_append() {
  echo "$1" >> "$(store_file)"
}
EOF

cat > lib/tasks.sh <<'EOF'
add_task() {
  store_append "$(new_task "$1" "$2")"
}
EOF

cat > test_todo.sh <<'EOF'
#!/bin/sh
export TODO_DB="$(mktemp)"

./bin/todo add 1 "Pay rent"
grep -q "^1|open|Pay rent$" "$TODO_DB" || { echo "FAIL: add"; exit 1; }

echo "all passed"
EOF

chmod +x bin/todo test_todo.sh
printf '.fixture/\ntasks.db\n' > .gitignore
git add . && git commit -q -m "feat: add tasks"

git init -q --bare .fixture/origin.git
git remote add origin .fixture/origin.git
git push -q origin trunk
git remote set-head origin trunk

git switch -q -c feat-complete-a-task
cat > SPEC.md <<'EOF'
# Complete a task

## Context

Tasks can be added but never finished.

## Intent

Let a user complete a task from the command line, once.

## Out of scope

Reopening a task.

## Acceptance criteria

- AC1: `bin/todo complete <id>` marks an open task `done` in the store and prints `completed: <title>`
- AC2: completing a task that is already done prints `already completed` and exits with status 1
- AC3: completing an unknown id prints `not found` and exits with status 2

## Plan

1. **complete a task** (AC1, AC2, AC3) — inside-out: follows `add_task` in `lib/tasks.sh` and
   `new_task` in `lib/task.sh`. Touches `lib/task.sh` (domain), `lib/tasks.sh` (application), and
   `lib/task_store.sh` and `bin/todo` (infrastructure)

The enabling refactoring analysis was skipped.
EOF
git add SPEC.md && git commit -q -m "docs: feature specification"
