#!/bin/sh
# Checks SPEC.md's acceptance criterion through the entry point, with a test the agent never saw.
export TODO_DB="$(mktemp)"
./bin/todo add 1 "Pay rent"

[ "$(./bin/todo complete 1)" = "completed: Pay rent" ] || { echo "AC1: wrong output"; exit 1; }
grep -q '^1|done|Pay rent$' "$TODO_DB" || { echo "AC1: task not done in the store"; exit 1; }
