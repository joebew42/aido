# Shared by the implement-* cases that build on a small TODO script: the app on trunk, and a feature
# branch whose first commit is the specification the case reads from stdin.

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

spec_with() {
  cat > SPEC.md
  git add SPEC.md && git commit -q -m "docs: feature specification"
}
