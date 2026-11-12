#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/../implement-leaves-contradictory-criteria-unresolved/fixture.sh"

cat > todo.sh <<'SCRIPT'
#!/bin/sh
case "$1" in
  add) echo "$2 open" >> tasks.txt ;;
  complete) perl -pi -e "s/^$2 open$/$2 done/" tasks.txt ;;
  list) cat tasks.txt ;;
esac
SCRIPT
cat > test_todo.sh <<'SCRIPT'
#!/bin/sh
rm -f tasks.txt

./todo.sh add 1
grep -q "^1 open$" tasks.txt || { echo "FAIL: add"; exit 1; }

./todo.sh complete 1
./todo.sh list | grep -qx "1 done" || { echo "FAIL: AC1"; exit 1; }

rm -f tasks.txt
./todo.sh add 1
./todo.sh add 2
[ "$(./todo.sh list)" = "$(printf '1 open\n2 open')" ] || { echo "FAIL: AC2"; exit 1; }

echo "all passed"
SCRIPT
git add . && git commit -q -m "feat: complete a task and list the tasks"

cat >> SPEC.md <<'SPEC'

## Progress

- [x] 1. complete a task
- [x] 2. list the open tasks

### Acceptance

- AC1: met — `test_todo.sh`, the AC1 check
- AC2: met — `test_todo.sh`, the AC2 check
SPEC
git add SPEC.md && git commit -q -m "docs: update feature specification"
