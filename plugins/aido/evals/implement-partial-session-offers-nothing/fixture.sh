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
cat > test_todo.sh <<'EOF'
#!/bin/sh
rm -f tasks.txt

./todo.sh add 1
grep -q "^1 open$" tasks.txt || { echo "FAIL: add"; exit 1; }

echo "all passed"
EOF
chmod +x todo.sh test_todo.sh
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

- AC1: completing an open task with `./todo.sh complete <id>` marks it `done` in `tasks.txt`
- AC2: `./todo.sh list` prints the open tasks

## Plan

1. **complete a task** (AC1) — inside-out: follows the `add` command in `todo.sh`. Touches
   infrastructure
2. **list the open tasks** (AC2) — inside-out: follows the `add` command in `todo.sh`. Touches
   infrastructure

The enabling refactoring analysis was skipped.
EOF
git add SPEC.md && git commit -q -m "docs: feature specification"
