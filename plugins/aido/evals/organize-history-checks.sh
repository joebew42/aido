# Shared by the organize-* checks: where in the branch's final history each piece first appears.

commits() {
  git rev-list --reverse origin/trunk..HEAD
}

# Position of the first commit whose tree has the pattern in the paths. Prints nothing if none does.
first_with() {
  pattern="$1"
  shift
  position=0
  for commit in $(commits); do
    position=$((position + 1))
    if git grep -q -E "$pattern" "$commit" -- "$@" 2>/dev/null; then
      echo "$position"
      return
    fi
  done
}

domain() { first_with 'complete_line\(\)' lib/task.sh; }
application() { first_with 'complete_task\(\)' lib/tasks.sh; }
entry_point() { first_with 'complete_task' bin/todo; }
guard() { first_with 'already completed' lib/tasks.sh; }
first_test() { first_with 'completed: Pay rent' test_complete.sh; }
second_test() { first_with 'already completed' test_already_done.sh; }

in_order() {
  previous=0
  for position in "$@"; do
    [ -n "$position" ] && [ "$previous" -le "$position" ] || { echo "out of order: $*"; return 1; }
    previous="$position"
  done
}

suite_ends_green() {
  ./test_todo.sh >/dev/null || { echo "the suite fails at the end"; return 1; }
}

history_is_inside_out() {
  suite_ends_green || return 1
  in_order "$(domain)" "$(application)" "$(entry_point)" "$(guard)" "$(first_test)" "$(second_test)" || return 1
  [ "$(entry_point)" -lt "$(first_test)" ] || { echo "the acceptance tests are not after the code"; return 1; }
}

history_is_slice_shaped() {
  suite_ends_green || return 1
  # first slice, inside-out and closed by its test; only then the second, closed by its test
  in_order "$(domain)" "$(application)" "$(entry_point)" "$(first_test)" || return 1
  [ "$(first_test)" -lt "$(guard)" ] || { echo "the first slice's test is not before the second slice"; return 1; }
  [ "$(guard)" -le "$(second_test)" ] || { echo "the second slice's test is before its code"; return 1; }

  # the first slice's acceptance test passes at the commit that closes it
  closing="$(commits | sed -n "$(first_test)p")"
  tree="$(mktemp -d)"
  git archive "$closing" | tar -x -C "$tree"
  (cd "$tree" && sh test_complete.sh >/dev/null) || { echo "the first slice's test fails at its commit"; return 1; }
}
