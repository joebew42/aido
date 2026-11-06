#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../implement-todo.sh"

layered_todo_app
spec_with <<'EOF'
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

1. **complete a task** (AC1, AC2, AC3) — outside-in: how a task in the store changes state is
   unconfirmed, because the store only appends today. Touches `lib/task.sh` (domain), `lib/tasks.sh`
   (application), and `lib/task_store.sh` and `bin/todo` (infrastructure)
   - slice 1: `bin/todo complete <id>` completes an open task (AC1)
   - slice 2: completing a task that is already done (AC2)
   - slice 3: completing an unknown id (AC3)

The enabling refactoring analysis was skipped.
EOF
