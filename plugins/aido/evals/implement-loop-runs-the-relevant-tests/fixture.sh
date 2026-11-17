#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../implement-todo.sh"

todo_app

git switch -q trunk
cat > backup.sh <<'SCRIPT'
#!/bin/sh
cp tasks.txt tasks.txt.bak
SCRIPT
cat > test_backup.sh <<'SCRIPT'
#!/bin/sh
touch .fixture/whole-suite-ran
echo "1 open" > tasks.txt

./backup.sh
grep -q "^1 open$" tasks.txt.bak || { echo "FAIL: backup"; exit 1; }

rm -f tasks.txt tasks.txt.bak
echo "all passed"
SCRIPT
cat > test_all.sh <<'SCRIPT'
#!/bin/sh
for test in ./test_todo.sh ./test_backup.sh; do
  "$test" || exit 1
done
SCRIPT
chmod +x backup.sh test_backup.sh test_all.sh
printf 'tasks.txt.bak\n' >> .gitignore
git add . && git commit -q -m "feat: back up the tasks"
git push -q origin trunk
git switch -q -C feat-complete-a-task trunk

spec_with <<'SPEC'
# Complete a task

## Context

Tasks can be added but never finished.

## Intent

Let a user complete a task, once.

## Out of scope

Reopening a task, and backing up the tasks.

## Acceptance criteria

- AC1: completing an open task with `./todo.sh complete <id>` marks it `done` in `tasks.txt`

## Plan

1. **complete a task** (AC1) — inside-out: follows the `add` command in `todo.sh`. Touches
   infrastructure

The enabling refactoring analysis was skipped.
SPEC
