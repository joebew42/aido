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

- AC1: met — `test_complete.sh`
- AC2: met — `test_already_done.sh`
SPEC
messy_commits
