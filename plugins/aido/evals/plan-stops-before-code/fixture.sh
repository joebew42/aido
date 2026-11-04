#!/usr/bin/env bash
set -euo pipefail

git init -q -b trunk .
git config user.name "Fixture"
git config user.email "fixture@example.com"

cat > todo.sh <<'EOF'
#!/bin/sh
case "$1" in
  add) echo "$2 open" >> tasks.txt ;;
esac
EOF
chmod +x todo.sh
printf '.fixture/\ntasks.txt\n' > .gitignore
git add . && git commit -q -m "feat: add tasks"

git init -q --bare .fixture/origin.git
git remote add origin .fixture/origin.git
git push -q origin trunk
git remote set-head origin trunk
