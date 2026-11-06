# Shared by the implement-* cases that build on a small TODO app: the app on trunk, and a feature
# branch whose first commit is the specification the case reads from stdin. `todo_app` is one script,
# and `layered_todo_app` is split into an entry point in `bin/` and its layers in `lib/`. A case that
# changes the layered app on trunk writes `layered_todo_files`, changes them, then runs `publish_trunk`.

todo_app() {
  git init -q -b trunk .
  git config user.name "Fixture"
  git config user.email "fixture@example.com"

  cat > todo.sh <<'EOF'
#!/bin/sh
case "$1" in
  add) echo "$2 open" >> tasks.txt ;;
esac
EOF
  cat > test_todo.sh <<'EOF'
#!/bin/sh
rm -f tasks.txt

./todo.sh add 1
grep -q "^1 open$" tasks.txt || { echo "FAIL: add"; exit 1; }

echo "all passed"
EOF
  chmod +x todo.sh test_todo.sh
  printf '.fixture/\ntasks.txt\n' > .gitignore
  git add . && git commit -q -m "feat: add tasks"

  git init -q --bare .fixture/origin.git
  git remote add origin .fixture/origin.git
  git push -q origin trunk
  git remote set-head origin trunk

  git switch -q -c feat-complete-a-task
}

layered_todo_app() {
  layered_todo_files
  publish_trunk feat-complete-a-task
}

layered_todo_files() {
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

echo "all passed"
EOF

  chmod +x bin/todo test_todo.sh
  printf '.fixture/\ntasks.db\n' > .gitignore
}

publish_trunk() {
  git add . && git commit -q -m "feat: add tasks"

  git init -q --bare .fixture/origin.git
  git remote add origin .fixture/origin.git
  git push -q origin trunk
  git remote set-head origin trunk

  git switch -q -c "$1"
}

spec_with() {
  cat > SPEC.md
  git add SPEC.md && git commit -q -m "docs: feature specification"
}
