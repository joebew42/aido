#!/usr/bin/env bash
set -euo pipefail

git init -q -b trunk .
git config user.name "Fixture"
git config user.email "fixture@example.com"

mkdir -p bin lib

cat > bin/todo <<'EOF'
#!/bin/sh
root="$(dirname "$0")/.."
. "$root/lib/tasks.sh"

case "$1" in
  add) add_task "$2" "$3" ;;
  *) echo "unknown command: $1" >&2; exit 64 ;;
esac
EOF

cat > lib/tasks.sh <<'EOF'
add_task() {
  echo "$1|open|$2" >> "${TODO_DB:-tasks.db}"
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

git switch -q -c feat-complete-sync-and-repeat
cat > SPEC.md <<'EOF'
# Complete, sync and repeat tasks

## Context

Tasks can be added, but not finished, shared with a calendar, or repeated.

## Intent

Let a user complete a task, have it sent to their calendar provider, and repeat a task monthly.

## Out of scope

Reopening a task.

## Acceptance criteria

- AC1: `bin/todo complete <id>` marks an open task `done` in the store
- AC2: a completed task is sent to the calendar provider, whose API nobody here has called yet
- AC3: a rejected sync is reported to the user
- AC4: `bin/todo repeat <id>` schedules the task a month later; what happens at the end of a month is
  not settled
EOF
git add SPEC.md && git commit -q -m "docs: feature specification"
