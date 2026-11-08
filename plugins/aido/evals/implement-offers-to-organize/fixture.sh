#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../implement-todo.sh"

todo_app
spec_with <<'EOF'
# Complete a task

## Context

Tasks can be added but never finished.

## Intent

Let a user complete a task, once.

## Out of scope

Reopening a task.

## Acceptance criteria

- AC1: completing an open task with `./todo.sh complete <id>` marks it `done` in `tasks.txt`
- AC2: completing an already completed task prints `already completed` and exits with status 1
- AC3: `./todo.sh list` prints the open tasks

## Plan

1. **complete and list tasks** (AC1, AC2, AC3) — inside-out: follows the `add` command in `todo.sh`.
   Touches infrastructure

The enabling refactoring analysis was skipped.

## Progress

### Acceptance

- AC3: deferred — the list format is not settled
EOF
