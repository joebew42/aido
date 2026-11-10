#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../handle-review.sh"

feature_branch
push_for_review <<'REVIEW'
# Review of "Complete a task"

## `lib/tasks.sh`, `complete_task`

Could you rename `line` to `task_line`? `line` reads a bit vague here.

## `lib/task_store.sh`

While you're in here, could the store move to a real database? A text file won't scale.

## Review summary

Nice work. One thing for later: completed tasks pile up in the list. It would be good to archive them
after a week, but that's a separate feature.
REVIEW
