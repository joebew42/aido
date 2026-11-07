#!/bin/sh
# Checks SPEC.md's acceptance criterion through the entry point, with a test the agent never saw.
export TODO_DB="$(mktemp)"
./bin/todo add 1 "pay rent"
./bin/todo add 2 "Call the bank"

[ "$(./bin/todo rename 1 "renew passport")" = "renamed: Renew passport" ] || { echo "AC1: wrong output"; exit 1; }
grep -q '^1|open|Renew passport$' "$TODO_DB" || { echo "AC1: title not stored the way add stores it"; exit 1; }
grep -q '^2|open|Call the bank$' "$TODO_DB" || { echo "AC1: another task changed"; exit 1; }
[ "$(grep -c '' "$TODO_DB")" -eq 2 ] || { echo "AC1: the task was added again instead of renamed"; exit 1; }
