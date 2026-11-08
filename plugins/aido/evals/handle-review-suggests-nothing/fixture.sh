#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../handle-review.sh"

feature_branch
push_for_review <<'REVIEW'
# Review of "Complete a task"

## `lib/tasks.sh`, `complete_task`

Could you rename `line` to `task_line`? `line` reads a bit vague here.

## `test_complete.sh`

Please also add a second task and check that it is still `open` after task 1 is completed.
REVIEW
