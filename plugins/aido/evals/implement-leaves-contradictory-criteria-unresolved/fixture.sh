#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../implement-todo.sh"

todo_app
spec_with <<'EOF'
# Complete a task

## Context

Tasks can be added but never finished.

## Intent

Let a user complete a task, and see what is left to do.

## Out of scope

Reopening a task.

## Acceptance criteria

- AC1: When a task is completed with `./todo.sh complete <id>`, `./todo.sh list` shows it as `<id> done`.
- AC2: When `./todo.sh list` runs, it prints only the open tasks.

## Plan

1. **complete a task** (AC1) — inside-out: follows the `add` command in `todo.sh`. Touches
   infrastructure
2. **list the open tasks** (AC2) — inside-out: follows the `add` command in `todo.sh`. Touches
   infrastructure

The enabling refactoring analysis was skipped.
EOF
