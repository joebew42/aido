# Shared by the organize-* cases: a TODO app, and the pieces of a feature that completes a task.

base_app() {
  git init -q -b trunk .
  git config user.name "Fixture"
  git config user.email "fixture@example.com"

  mkdir -p bin lib

  cat > bin/todo <<'EOF'
#!/bin/sh
root="$(dirname "$0")/.."
. "$root/lib/task.sh"
. "$root/lib/task_store.sh"
. "$root/lib/tasks.sh"

case "$1" in
  add) add_task "$2" "$3" ;;
  *) echo "unknown command: $1" >&2; exit 64 ;;
esac
EOF

  cat > lib/task.sh <<'EOF'
new_task() {
  printf '%s|open|%s\n' "$1" "$2"
}
EOF

  cat > lib/task_store.sh <<'EOF'
store_file() {
  echo "${TODO_DB:-tasks.db}"
}

store_append() {
  echo "$1" >> "$(store_file)"
}
EOF

  cat > lib/tasks.sh <<'EOF'
add_task() {
  store_append "$(new_task "$1" "$2")"
}
EOF

  cat > test_todo.sh <<'EOF'
#!/bin/sh
export TODO_DB="$(mktemp)"

./bin/todo add 1 "Pay rent"
grep -q "^1|open|Pay rent$" "$TODO_DB" || { echo "FAIL: add"; exit 1; }

for extra in test_task.sh test_complete.sh test_already_done.sh; do
  [ ! -f "$extra" ] || sh "$extra" || exit 1
done

echo "all passed"
EOF

  chmod +x bin/todo test_todo.sh
  printf '.fixture/\ntasks.db\n' > .gitignore
  git add . && git commit -q -m "feat: add tasks"

  git init -q --bare .fixture/origin.git
  git remote add origin .fixture/origin.git
  git push -q origin trunk
  git remote set-head origin trunk
  git switch -q -c feat-complete-a-task
}

write_domain() {
  cat >> lib/task.sh <<'EOF'

complete_line() {
  printf '%s\n' "$1" | sed 's/|open|/|done|/'
}
EOF
  cat > test_task.sh <<'EOF'
#!/bin/sh
. ./lib/task.sh
[ "$(complete_line '1|open|Pay rent')" = '1|done|Pay rent' ] || { echo "FAIL: complete_line"; exit 1; }
EOF
}

write_store() {
  cat >> lib/task_store.sh <<'EOF'

store_find() {
  grep "^$1|" "$(store_file)"
}

store_replace() {
  sed -i "s/^$1|.*/$2/" "$(store_file)"
}
EOF
}

write_application() {
  cat >> lib/tasks.sh <<'EOF'

complete_task() {
  line="$(store_find "$1")"
  store_replace "$1" "$(complete_line "$line")"
  echo "completed: ${line##*|}"
}
EOF
}

write_guard() {
  sed -i 's/^  line="$(store_find "$1")"$/&\n  case "$line" in *"|done|"*) echo "already completed"; return 1 ;; esac/' lib/tasks.sh
}

write_entry_point() {
  sed -i 's/^  add) add_task "$2" "$3" ;;$/&\n  complete) complete_task "$2" ;;/' bin/todo
}

write_first_acceptance_test() {
  cat > test_complete.sh <<'EOF'
#!/bin/sh
export TODO_DB="$(mktemp)"
./bin/todo add 1 "Pay rent"
[ "$(./bin/todo complete 1)" = "completed: Pay rent" ] || { echo "FAIL: complete"; exit 1; }
grep -q '^1|done|Pay rent$' "$TODO_DB" || { echo "FAIL: not done"; exit 1; }
EOF
}

write_second_acceptance_test() {
  cat > test_already_done.sh <<'EOF'
#!/bin/sh
export TODO_DB="$(mktemp)"
./bin/todo add 1 "Pay rent"
./bin/todo complete 1 >/dev/null
[ "$(./bin/todo complete 1)" = "already completed" ] || { echo "FAIL: already completed"; exit 1; }
EOF
}

# The working commits of a finished feature, in an order neither mode wants.
messy_commits() {
  write_first_acceptance_test
  write_second_acceptance_test
  git add . && git commit -q -m "test: acceptance tests"
  write_entry_point
  git add . && git commit -q -m "feat: entry point"
  write_store
  write_application
  write_guard
  git add . && git commit -q -m "feat: complete a task"
  write_domain
  git add . && git commit -q -m "feat: domain"
}

spec_with() {
  cat > SPEC.md
  git add SPEC.md && git commit -q -m "docs: feature specification"
}
