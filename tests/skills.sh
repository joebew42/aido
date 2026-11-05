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

plugin="$root/plugins/aido"

report() {
  if [ "$1" -eq 0 ]; then
    echo "ok   - $2"
  else
    echo "FAIL - $2"
    failures=$((failures + 1))
  fi
}

on_one_line() {
  tr -s ' \n' ' ' < "$1"
}

section_exists() {
  local name="$1" file="$2"
  [ -f "$file" ] || return 1
  grep -qE "^#+ $name( |\$)" "$file" || grep -qE "\*\*$name( |:?\*\*)" "$file"
}

references="$(
  for file in "$plugin"/skills/*/SKILL.md "$plugin"/guidelines/*.md; do
    on_one_line "$file" | grep -oE '("[^"]{3,60}"|\*\*[^*]{3,60}\*\*) in `[^`]+\.md`'
  done | sort -u
)"

while IFS= read -r reference; do
  [ -n "$reference" ] || continue
  name="$(sed -E 's/^("|\*\*)//; s/("|\*\*) in `.*$//' <<< "$reference")"
  target="$(sed -E 's/^.* in `//; s/`$//; s/^\$\{CLAUDE_PLUGIN_ROOT\}\///' <<< "$reference")"
  case "$target" in
    */*) ;;
    *) target="guidelines/$target" ;;
  esac
  section_exists "$name" "$plugin/$target"
  report $? "\"$name\" exists in $target"
done <<< "$references"

while IFS='|' read -r file phrase; do
  on_one_line "$plugin/$file" | grep -qF "$phrase"
  report $? "$file keeps: $phrase"
done <<'EOF_PHRASES'
skills/1-plan/SKILL.md|Is the plan approved?
skills/1-plan/SKILL.md|ready to become `SPEC.md`
skills/1-plan/SKILL.md|Do NOT move to Step 7 without approval
skills/1-plan/SKILL.md|Do NOT implement anything in this skill
skills/2-implement/SKILL.md|Never record a criterion as met without its evidence
skills/2-implement/SKILL.md|Should I run a final design review over the whole feature?
skills/2-implement/SKILL.md|Once implementation is complete, should I organize the commits?
skills/2-implement/SKILL.md|Only the orchestrator writes `SPEC.md`
skills/2-implement/SKILL.md|stop the loop. Report what failed, and the items not yet run
skills/2-implement/SKILL.md|`loop <first>-<last>`, such as `loop 7-9`
skills/2-implement/SKILL.md|Skip those already ticked in `## Progress`, and name them
skills/2-implement/SKILL.md|a range that names an item the plan doesn't have** → don't start the loop, and say why
skills/2-implement/SKILL.md|each with the criteria it serves, and ask nothing
skills/2-implement/SKILL.md|the range ends before the plan does** → name the items left
skills/3-organize-commits/SKILL.md|Once the commits are organized, should I create the pull request?
skills/verify/SKILL.md|Every finding names its evidence
skills/verify/SKILL.md|are not evidence
guidelines/systemic-refactoring.md|Evidence before action
guidelines/git-workflow.md|every push needs the user's approval
EOF_PHRASES

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures failed"
  exit 1
fi
