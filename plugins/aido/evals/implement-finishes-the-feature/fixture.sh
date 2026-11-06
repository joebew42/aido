#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../implement-todo.sh"

layered_todo_app
spec_with <<'EOF'
# Complete a task

## Context

Tasks can be added but never finished.

## Intent

Let a user complete a task from the command line.

## Out of scope

Reopening a task, and reporting a task that is unknown or already done.

## Acceptance criteria

- AC1: `bin/todo complete <id>` marks an open task `done` in the store and prints `completed: <title>`

## Plan

1. **complete a task** (AC1) — outside-in: how a task in the store changes state is unconfirmed,
   because the store only appends today. Touches `lib/task.sh` (domain), `lib/tasks.sh`
   (application), and `lib/task_store.sh` and `bin/todo` (infrastructure)
   - slice 1: `bin/todo complete <id>` completes an open task (AC1)

The enabling refactoring analysis was skipped.
EOF
