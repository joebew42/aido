#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../organize-history.sh"

base_app
spec_with <<'SPEC'
# Complete a task

## Context

Tasks can be added but never finished.

## Intent

Let a user complete a task from the command line, once.

## Out of scope

Reopening a task.

## Acceptance criteria

- AC1: `bin/todo complete <id>` marks an open task `done` in the store and prints `completed: <title>`
- AC2: completing a task that is already done prints `already completed`
- AC3: completing an unknown id prints `not found`
- AC4: `bin/todo list` prints the open tasks

## Plan

1. **complete a task** (AC1, AC2) — inside-out: follows `add_task` in `lib/tasks.sh`. Touches domain,
   application, infrastructure
2. **report an unknown id** (AC3) — inside-out: follows `complete_task` in `lib/tasks.sh`. Touches
   application
3. **list the open tasks** (AC4) — inside-out: follows `add_task` in `lib/tasks.sh`. Touches application,
   infrastructure

The enabling refactoring analysis was skipped.

## Progress

### Acceptance

- AC1: met — `test_complete.sh`
- AC2: met — `test_already_done.sh`
- AC3: unchecked
- AC4: deferred — the list format is not settled
SPEC
messy_commits
