#!/usr/bin/env bash
set -euo pipefail

git init -q -b trunk .
git config user.name "Fixture"
git config user.email "fixture@example.com"

cat > todo.sh <<'EOF'
#!/bin/sh
# tasks.txt holds one task per line: <title>|<due date, YYYY-MM-DD>|<open or done>
case "$1" in
  add) echo "$2|$3|open" >> tasks.txt ;;
  done) sed "s/^$2|\(.*\)|open\$/$2|\1|done/" tasks.txt > tasks.tmp && mv tasks.tmp tasks.txt ;;
  list) cut -d'|' -f1 tasks.txt ;;
esac
EOF
chmod +x todo.sh
printf '.fixture/\ntasks.txt\ntasks.tmp\n' > .gitignore
git add . && git commit -q -m "feat: add, complete and list tasks"

git init -q --bare .fixture/origin.git
git remote add origin .fixture/origin.git
git push -q origin trunk
git remote set-head origin trunk

cat > SPEC.draft.md <<'EOF'
# Colour the task list

## Context

`todo.sh list` prints every task in the same colour, so nothing stands out.

## Intent

The list shows at a glance which tasks need attention and which are finished.

## Out of scope

- choosing the colours

## Acceptance criteria

- AC1: When a task's due date has passed, `todo.sh list` shows it in red.
- AC2: When a task is due today, `todo.sh list` shows it in bold.
- AC3: When a task is completed, `todo.sh list` shows it in grey.
EOF
