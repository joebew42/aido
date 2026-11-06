#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../implement-todo.sh"

todo_app
spec_with <<'EOF'
# Complete a task

## Context

Tasks can be added but never finished.

## Intent

Let a user complete a task, once, and see that it worked.

## Out of scope

Reopening a task.

## Acceptance criteria

- AC1: completing an open task with `./todo.sh complete <id>` marks it `done` in `tasks.txt`
- AC2: `./todo.sh list` prints the open tasks
- AC3 (manual): the message `./todo.sh complete` prints reads clearly to a person

## Plan

1. **complete a task** (AC1, AC3) — inside-out: follows the `add` command in `todo.sh`. Touches
   infrastructure
2. **list the open tasks** (AC2) — inside-out: follows the `add` command in `todo.sh`. Touches
   infrastructure

The enabling refactoring analysis was skipped.
EOF
