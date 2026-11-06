#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../implement-todo.sh"

layered_todo_files
cat > lib/task.sh <<'EOF'
new_task() {
  printf '%s|open|%s\n' "$1" "$(task_title "$2")"
}

task_title() {
  first="$(printf '%s' "$1" | cut -c1 | tr '[:lower:]' '[:upper:]')"
  printf '%s%s\n' "$first" "$(printf '%s' "$1" | cut -c2-)"
}
EOF
publish_trunk feat-rename-a-task
spec_with <<'EOF'
# Rename a task

## Context

A task keeps the title it was added with.

## Intent

Let a user rename a task from the command line.

## Out of scope

Renaming a task that is unknown, and changing a task's state.

## Acceptance criteria

- AC1: `bin/todo rename <id> <title>` stores the new title the way `add` stores titles, and prints
  `renamed: <the stored title>`

## Plan

1. **rename a task** (AC1) — inside-out: follows `new_task` and its `task_title` helper in
   `lib/task.sh`, and `add_task` in `lib/tasks.sh`. Touches `lib/task.sh` (domain), `lib/tasks.sh`
   (application), and `lib/task_store.sh` and `bin/todo` (infrastructure)

The enabling refactoring analysis was skipped.
EOF
