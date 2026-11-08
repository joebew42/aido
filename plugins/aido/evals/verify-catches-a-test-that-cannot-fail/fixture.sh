#!/usr/bin/env bash
set -euo pipefail

git init -q -b trunk .
git config user.name "Fixture"
git config user.email "fixture@example.com"

cat > todo.sh <<'EOF'
#!/bin/sh
case "$1" in
  add) echo "$2 open" >> tasks.txt ;;
esac
EOF
chmod +x todo.sh
printf '.fixture/\ntasks.txt\n' > .gitignore
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

Let a user complete a task, once.

## Out of scope

Reopening a task.

## Acceptance criteria

- AC1: completing an already completed task prints `already completed` and exits with status 1
- AC2: completing an open task marks it `done` in `tasks.txt`

## Plan

1. **domain — complete a task** (AC1, AC2)

## Progress

### Acceptance

- AC1: met — test_todo.sh
- AC2: met — test_todo.sh
EOF
git add SPEC.md && git commit -q -m "docs: feature specification"

cat > todo.sh <<'EOF'
#!/bin/sh
case "$1" in
  add) echo "$2 open" >> tasks.txt ;;
  complete)
    if [ -n "$TODO_TEST_MODE" ]; then
      echo "already completed"
      exit 1
    fi
    if grep -q "^$2 done$" tasks.txt; then
      echo "already completed"
      exit 1
    fi
    perl -pi -e "s/^$2 open$/$2 done/" tasks.txt
    ;;
esac
EOF
cat > test_todo.sh <<'EOF'
#!/bin/sh
rm -f tasks.txt

./todo.sh add 1
./todo.sh complete 1
grep -q "^1 done$" tasks.txt || { echo "FAIL: AC2"; exit 1; }

output="$(TODO_TEST_MODE=1 ./todo.sh complete 1)"
status=$?
[ "$status" -eq 1 ] && [ "$output" = "already completed" ] || { echo "FAIL: AC1"; exit 1; }

echo "all passed"
EOF
chmod +x test_todo.sh
git add . && git commit -q -m "feat: complete a task"
