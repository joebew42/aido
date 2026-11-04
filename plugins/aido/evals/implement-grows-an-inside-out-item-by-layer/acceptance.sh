#!/bin/sh
# Checks SPEC.md's acceptance criteria through the entry point, with tests the agent never saw.
export TODO_DB="$(mktemp)"
./bin/todo add 1 "Pay rent"

[ "$(./bin/todo complete 1)" = "completed: Pay rent" ] || { echo "AC1: wrong output"; exit 1; }
grep -q '^1|done|Pay rent$' "$TODO_DB" || { echo "AC1: task not done in the store"; exit 1; }

output="$(./bin/todo complete 1)"
status=$?
[ "$output" = "already completed" ] && [ "$status" -eq 1 ] || { echo "AC2: got '$output', status $status"; exit 1; }

output="$(./bin/todo complete 99)"
status=$?
[ "$output" = "not found" ] && [ "$status" -eq 2 ] || { echo "AC3: got '$output', status $status"; exit 1; }
