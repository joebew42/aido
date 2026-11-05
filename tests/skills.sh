#!/usr/bin/env bash

root="$(cd "$(dirname "$0")/.." && pwd)"
failures=0

language_rule='Load `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md` and follow it in everything you write for a person.'

for skill in "$root"/plugins/aido/skills/*/SKILL.md; do
  name="$(basename "$(dirname "$skill")")"

  if grep -qxF "$language_rule" "$skill"; then
    echo "ok   - $name loads the language rule"
  else
    echo "FAIL - $name loads the language rule"
    failures=$((failures + 1))
  fi
done

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures failed"
  exit 1
fi
