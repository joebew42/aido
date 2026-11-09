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

## Plan

1. **complete a task** (AC1, AC2) — inside-out: follows `add_task` in `lib/tasks.sh`. Touches domain,
   application, infrastructure

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. complete a task

### Acceptance

- AC1: met — `test_complete.sh`
- AC2: met — `test_already_done.sh`
SPEC

write_domain
git add . && git commit -q -m "feat: complete a task line"
write_store
git add . && git commit -q -m "feat: find and replace a stored task"
write_application
write_guard
git add . && git commit -q -m "feat: complete a task once"
write_entry_point
git add . && git commit -q -m "feat: add the complete command"
write_first_acceptance_test
write_second_acceptance_test
git add . && git commit -q -m "test: completing a task"
