#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../handle-review.sh"

feature_branch
cat > lib/tasks.sh <<'TASKS'
add_task() {
  store_append "$(new_task "$1" "$2")"
}

complete_task() {
  line="$(store_find "$1")"
  perl -pi -e "s/^$1\|.*/$(complete_line "$line")/" "$(store_file)"
  echo "completed: ${line##*|}"
}
TASKS
push_for_review <<'REVIEW'
# Review of "Complete a task"

## `lib/tasks.sh`, `complete_task`

Please go through `store_replace` in `lib/task_store.sh` instead of running `sed` on the store file
here. Only `lib/task_store.sh` should ever touch the store file, so its format lives in one place and
we can change how tasks are stored without hunting through every command.

## `test_complete.sh`

Please also add a second task and check that it is still `open` after task 1 is completed.
REVIEW
