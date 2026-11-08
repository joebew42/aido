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
skills/2-implement/SKILL.md|options **Refactor now** / **Plan it for later** / **Defer** / **No action**
skills/2-implement/SKILL.md|Change no code: each one is built later, like a plan item
skills/2-implement/SKILL.md|"the final design review ran and recorded r1, r2"
skills/2-implement/SKILL.md|it is not offered again
skills/2-implement/SKILL.md|**plan items or refactorings remain**
skills/2-implement/SKILL.md|options **Plan it for later** / **Defer** / **No action**
guidelines/systemic-refactoring.md|fix now and refactor now also collapse into one outcome: **planned**
skills/2-implement/SKILL.md|`loop r<N>`, or `loop r<first>-r<last>`, such as `loop r1-r3`
skills/2-implement/SKILL.md|every plan item not done, then every refactoring not done
skills/2-implement/SKILL.md|a refactoring code `## Refactorings` doesn't have** → don't start the loop, and say why
skills/2-implement/SKILL.md|every unfinished plan item, then every unfinished refactoring
skills/2-implement/SKILL.md|A refactoring from `## Refactorings` has no mode
skills/2-implement/SKILL.md|tick each item that is done, plan item or refactoring
skills/2-implement/SKILL.md|a criterion already recorded as `met`, `changed` or `deferred` keeps that result
skills/2-implement/SKILL.md|**every plan item and refactoring is done**
skills/2-implement/SKILL.md|Once every plan item and refactoring is done
skills/2-implement/SKILL.md|**Item done:** once every unit of a plan item or a refactoring is committed, a single session ticks it in `## Progress`
skills/2-implement/SKILL.md|its units, any mode change, the slices built and the key decisions
skills/2-implement/SKILL.md|commit that before starting the next item
skills/2-implement/SKILL.md|A child puts all this in its results instead, and the orchestrator records it
skills/2-implement/SKILL.md|**Finish `## Progress`**. Each item done is already recorded there
skills/2-implement/SKILL.md|the results of the Acceptance Criteria Check, the units remaining, the deferred refactorings and the final design review's note
skills/3-organize-commits/SKILL.md|Once the commits are organized, should I open the pull request?
skills/3-organize-commits/SKILL.md|Always mark **Open the PR in a fresh context** as recommended, whatever `## Progress` says
skills/3-organize-commits/SKILL.md|Run no tests for a commit made here, not even an outside-in slice's acceptance test
skills/3-organize-commits/SKILL.md|Linting, the search for old references and the comment clean-up still apply to every commit
skills/3-organize-commits/SKILL.md|run the relevant tests once, on the final commit
skills/3-organize-commits/SKILL.md|hand off as the user chose, with no further test run
skills/3-organize-commits/SKILL.md|find the first commit where the run fails, fix it there, and rebuild the commits after it
skills/3-organize-commits/SKILL.md|add a fix commit instead of rewriting history
skills/3-organize-commits/SKILL.md|Then run the relevant tests again, once, on the final commit
guidelines/git-workflow.md|`/aido:3-organize-commits` runs the relevant tests once, on the final commit, instead of at each commit
guidelines/git-workflow.md|A refactoring from `## Refactorings` always gets its own `refactor:` commit, after the feature commits, even when it only reshapes the feature's new code
skills/4-open-pr/SKILL.md|# Open a Pull Request
skills/verify/SKILL.md|Every finding names its evidence
skills/verify/SKILL.md|a change that a refactoring in `## Refactorings` explains is planned, and is not a deviation. It is never evidence that something is met
skills/verify/SKILL.md|are not evidence
guidelines/systemic-refactoring.md|Evidence before action
guidelines/git-workflow.md|every push needs the user's approval
guidelines/specification.md|An item is done only when its line is ticked
guidelines/specification.md|`- [x] r1. <title>`
guidelines/specification.md|A refactoring's code is never renumbered or reused
guidelines/specification.md|<added by implementation, when the user accepts a refactoring>
guidelines/systemic-refactoring.md|the specification's `## Design notes`, `## Refactorings` and `## Progress`
guidelines/language.md|`(enabling)`, `r1`, `inside-out`
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
guidelines/git-workflow.md|finish this skill's own work, including its commits, start nothing, and tell the user to run `/clear`, then the next skill
guidelines/git-workflow.md|The fresh-context option carries the recommendation whenever continuing would, and is not recommended when continuing isn't
skills/stabilize/SKILL.md|keep **Implement in a fresh context**
skills/2-implement/SKILL.md|**Organize in a fresh context**
skills/3-organize-commits/SKILL.md|**Open the PR in a fresh context**
guidelines/tdd.md|In every mode, write the real implementation straight away: no hardcoded value to pass a test, and no test whose only job is to force generalizing one
guidelines/tdd.md|set aside the unit's production changes
guidelines/tdd.md|run its new tests, and confirm each one fails for the right reason. Then restore the changes
guidelines/tdd.md|**REFACTOR**, once per unit, with all tests green
skills/2-implement/SKILL.md|Work through each unit without stopping to present each test cycle, in every mode
guidelines/tdd.md|a unit that is a contract, a mapping or a DTO, and relies on no existing code: write the tests for every behaviour the plan gives it, together, then the code
guidelines/tdd.md|every other unit, in every mode, including an `inside-out` unit that relies on existing code: write **one** test for the next behaviour
skills/2-implement/SKILL.md|Tests are written together only for a contract, a mapping or a DTO that relies on no existing code
EOF_PHRASES

for skill in "$plugin"/skills/*/SKILL.md; do
  name="$(basename "$(dirname "$skill")")"
  if [ "$name" = "5-handle-review" ]; then
    grep -qF 'evolving-guidelines.md' "$skill"
    report $? "5-handle-review suggests conventions"
  else
    ! grep -qF 'evolving-guidelines.md' "$skill"
    report $? "only 5-handle-review suggests conventions, not $name"
  fi
done

skill_names="$(
  for skill in "$plugin"/skills/*/SKILL.md; do
    basename "$(dirname "$skill")"
  done
)"

referencing_files="$(
  find "$plugin/skills" "$plugin/guidelines" "$plugin/evals" "$root/docs/readme" -type f -not -path "$plugin/evals/results/*" 2>/dev/null
  for file in "$root/README.md" "$root/AGENTS.md"; do
    [ -f "$file" ] && echo "$file"
  done
)"

skill_references="$(xargs -r grep -hoI '/aido:[0-9a-z][0-9a-z-]*' <<< "$referencing_files" | sort -u)"

while IFS= read -r reference; do
  [ -n "$reference" ] || continue
  grep -qxF "${reference#/aido:}" <<< "$skill_names"
  report $? "$reference names an existing skill"
done <<< "$skill_references"

for grader in "$plugin"/evals/*/graders/*.md; do
  [ -f "$grader" ] && grep -qx 'tool: Skill' "$grader" || continue
  pattern="$(sed -nE "s/^input_match: '(.*)'\$/\1/p" "$grader")"
  [ -n "$pattern" ] || continue
  grep -qE "$pattern" <<< "$skill_names"
  report $? "${grader#"$plugin"/evals/} matches an existing skill"
done

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures failed"
  exit 1
fi
