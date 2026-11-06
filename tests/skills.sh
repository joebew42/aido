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

ending_rule='"Ending a Skill" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md`'

for skill in "$root"/plugins/aido/skills/*/SKILL.md; do
  name="$(basename "$(dirname "$skill")")"

  if tr -s ' \n' ' ' < "$skill" | grep -qF "$ending_rule"; then
    echo "ok   - $name ends with the ending block"
  else
    echo "FAIL - $name ends with the ending block"
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
skills/2-implement/SKILL.md|the range ends before the plan does** → record the items left, name them
skills/3-organize-commits/SKILL.md|Once the commits are organized, should I create the pull request?
skills/verify/SKILL.md|Every finding names its evidence
skills/verify/SKILL.md|are not evidence
guidelines/systemic-refactoring.md|Evidence before action
guidelines/git-workflow.md|every push needs the user's approval
guidelines/language.md|show a short plain-language list of what changed since the user last saw it
guidelines/language.md|The first time a document is shown, show it whole
guidelines/language.md|When the user asks to see the whole document, show it whole
skills/1-plan/SKILL.md|show only `## Plan` and `## Design notes`, not the approved specification
guidelines/systemic-refactoring.md|In chat, a finding is shown as one line: its Recommendation and Why it matters
guidelines/systemic-refactoring.md|When the user asks for a finding in full, show every field
guidelines/systemic-refactoring.md|A finding recorded in a file keeps every field
skills/assess-architecture/SKILL.md|one line per candidate, with its size
guidelines/language.md|end the last message with a short block labelled `Done`, `Decided` and `Needs you`
guidelines/language.md|Leave out `Done` or `Decided` when it has nothing to say. `Needs you` always stays, and reads "nothing" when nothing needs the user
guidelines/language.md|When the result is a report, show the report unchanged, and let the block list only what needs the user
guidelines/language.md|A skill that another skill started, and that returns to it, adds no block
skills/verify/SKILL.md|it returns a report and adds no ending block
skills/1-plan/SKILL.md|it returns a report and adds no ending block
skills/2-implement/SKILL.md|it returns a report and adds no ending block
skills/assess-architecture/SKILL.md|it returns a report and adds no ending block
skills/1-plan/SKILL.md|**Implement in a fresh context**
skills/1-plan/SKILL.md|finish this skill's own work, including its commits, start nothing, and tell the user to run `/clear`, then the next skill
skills/1-plan/SKILL.md|The fresh-context option carries the recommendation whenever continuing would, and is not recommended when continuing isn't
skills/stabilize/SKILL.md|keep **Implement in a fresh context**
skills/2-implement/SKILL.md|**Organize in a fresh context**
skills/3-organize-commits/SKILL.md|**Create the PR in a fresh context**
guidelines/tdd.md|In every mode, write the real implementation straight away: no hardcoded value to pass a test, and no test whose only job is to force generalizing one
guidelines/tdd.md|set aside the unit's production changes
guidelines/tdd.md|run its new tests, and confirm each one fails for the right reason. Then restore the changes
guidelines/tdd.md|**REFACTOR**, once per unit, with all tests green
skills/2-implement/SKILL.md|A child in loop mode doesn't present them
guidelines/tdd.md|a unit that is a contract, a mapping or a DTO, and relies on no existing code: write the tests for every behaviour the plan gives it, together, then the code
guidelines/tdd.md|every other unit, in every mode, including an `inside-out` unit that relies on existing code: write **one** test for the next behaviour
skills/2-implement/SKILL.md|Tests are written together only for a contract, a mapping or a DTO that relies on no existing code
EOF_PHRASES

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures failed"
  exit 1
fi
