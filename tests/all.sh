#!/usr/bin/env bash

cd "$(dirname "$0")/.." || exit 1
failures=0

run() {
  echo "=== $*"

  if ! "$@"; then
    echo "FAIL - $*"
    failures=$((failures + 1))
  fi
}

run bash tests/hooks.sh
run bash tests/skills.sh
run python3 tests/test_skills.py
run python3 tests/test_evals.py
run claude plugin validate .
run claude plugin validate ./plugins/aido

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures failed"
  exit 1
fi
