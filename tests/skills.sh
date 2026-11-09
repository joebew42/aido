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
skills/1-plan/SKILL.md|options **Plan it first** / **Defer** / **No action**
skills/1-plan/SKILL.md|options **Include it** / **Leave it saved**
skills/1-plan/SKILL.md|**Asking about a finding** in `systemic-refactoring.md`
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
skills/2-implement/SKILL.md|Recommend one, as **Asking about a finding** in `systemic-refactoring.md` describes
skills/2-implement/SKILL.md|ask about each finding on its own, as **Asking about a finding** in `systemic-refactoring.md` describes
skills/2-implement/SKILL.md|each option with what it does, and which one is recommended
skills/2-implement/SKILL.md|keeping the option it recommends
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
skills/2-implement/SKILL.md|under `### Acceptance`, the last heading in `## Progress`
skills/2-implement/SKILL.md|with the criteria only they serve as `unchecked` under `### Acceptance`
skills/3-organize-commits/SKILL.md|Once the commits are organized, should I open the pull request?
skills/3-organize-commits/SKILL.md|Always mark **Open the PR in a fresh context** as recommended, whatever `## Progress` says
skills/3-organize-commits/SKILL.md|hand off as the user chose, with no further test run
skills/3-organize-commits/SKILL.md|find the first commit where the run fails, fix it there, and rebuild the commits after it
skills/3-organize-commits/SKILL.md|add a fix commit instead of rewriting history
skills/3-organize-commits/SKILL.md|Then run the relevant tests again, once, on the final commit
guidelines/git-workflow.md|`/aido:3-organize-commits` runs the relevant tests once, on the final commit, instead of at each commit
guidelines/git-workflow.md|it runs no tests for a single commit, not even an outside-in slice's acceptance test
guidelines/git-workflow.md|Linting, the search for old references and the comment clean-up still apply to each of its commits
skills/3-organize-commits/SKILL.md|with the one exception for this skill that it describes
skills/3-organize-commits/SKILL.md|run the relevant tests on the final commit, as the exception in "Before Every Commit" in `git-workflow.md` describes
guidelines/git-workflow.md|A refactoring from `## Refactorings` always gets its own `refactor:` commit, after the feature commits, even when it only reshapes the feature's new code
skills/4-open-pr/SKILL.md|# Open a Pull Request
skills/verify/SKILL.md|Every finding names its evidence
skills/verify/SKILL.md|a change that a refactoring in `## Refactorings` explains is planned, and is not a deviation. It is never evidence that something is met
skills/verify/SKILL.md|are not evidence
guidelines/systemic-refactoring.md|Evidence before action
guidelines/systemic-refactoring.md|**Asking about a finding:**
guidelines/systemic-refactoring.md|A low-confidence finding recommends only **Defer** or **No action**
guidelines/systemic-refactoring.md|a finding classed no action is listed in one line, with no question
guidelines/git-workflow.md|every push needs the user's approval
guidelines/git-workflow.md|### Replying to Review Feedback
guidelines/git-workflow.md|resolveReviewThread(input: {threadId: $threadId})
guidelines/git-workflow.md|A reply is posted only once the user has approved its text
guidelines/git-workflow.md|gh pr comment <NUMBER> --body-file <file>
guidelines/specification.md|An item is done only when its line is ticked
guidelines/specification.md|under a `### Acceptance` heading, the last heading in `## Progress`
guidelines/specification.md|A specification with no results yet has no `### Acceptance` heading
guidelines/specification.md|`- [x] r1. <title>`
guidelines/specification.md|A refactoring's code is never renumbered or reused
guidelines/specification.md|<added by implementation, when the user accepts a refactoring>
guidelines/systemic-refactoring.md|the specification's `## Design notes`, `## Refactorings` and `## Progress`
guidelines/language.md|`(enabling)`, `r1`, `inside-out`
guidelines/language.md|show a short plain-language list of what changed since the user last saw it
guidelines/language.md|The first time a document is shown, show it whole
guidelines/language.md|When the user asks to see the whole document, show it whole
skills/1-plan/SKILL.md|show only `## Plan` and `## Design notes`, not the approved specification
guidelines/systemic-refactoring.md|In chat, a finding is shown as one line: its Change and Why
guidelines/systemic-refactoring.md|**Change** — the smallest useful refactoring - **Why** — what the code shows, and what it costs if it stays
guidelines/systemic-refactoring.md|**Where** — `path` — `Symbol`, one line each - **Confidence** — high, medium or low, as defined below, with its reason when it isn't high - **Risk** —
guidelines/systemic-refactoring.md|These shape the finding and its confidence. They are not written down
guidelines/systemic-refactoring.md|When the user asks for a finding in full, show every field
guidelines/systemic-refactoring.md|A finding recorded in a file keeps every field
skills/assess-architecture/SKILL.md|one line per candidate, with its size
guidelines/language.md|end the last message with a short block labelled `Done`, `Decided` and `Needs you`
guidelines/language.md|Leave out `Done` or `Decided` when it has nothing to say. `Needs you` always stays, and reads "nothing" when nothing needs the user
guidelines/language.md|When the result is a report, show the report unchanged, and let the block list only what needs the user
guidelines/language.md|A skill that another skill started, and that returns to it, adds no block
guidelines/language.md|Give a reason only when it isn't obvious or the user asks
guidelines/language.md|### In Chat
guidelines/language.md|### In a Specification
guidelines/language.md|### In a PR
guidelines/language.md|### In an Issue
guidelines/language.md|### One Item at a Time
guidelines/language.md|the exception to being interrupted once per stage
guidelines/language.md|ask about the first undecided item only, as text, and stop
guidelines/subagents.md|it returns a report and adds no ending block
guidelines/subagents.md|never to edit files, unless the skill's own brief names an exception
skills/verify/SKILL.md|"The Shared Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`
skills/1-plan/SKILL.md|"The Shared Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`
skills/2-implement/SKILL.md|"The Shared Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`
skills/assess-architecture/SKILL.md|"The Shared Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`
skills/1-plan/SKILL.md|"The Design-Check Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`
skills/2-implement/SKILL.md|"The Design-Check Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`
skills/assess-architecture/SKILL.md|"The Design-Check Brief" in `${CLAUDE_PLUGIN_ROOT}/guidelines/subagents.md`
skills/1-plan/SKILL.md|**Index Location and Shape** in `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md`
skills/2-implement/SKILL.md|**Reading the Index** in `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md`
skills/assess-architecture/SKILL.md|**Index Location and Shape** in `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md`
skills/map-architecture/SKILL.md|**Index Location and Shape** in `${CLAUDE_PLUGIN_ROOT}/guidelines/architecture-index.md`
guidelines/systemic-refactoring.md|`<repo-name>` is as **Index Location and Shape** in `architecture-index.md` defines it
guidelines/github-issues.md|## Writing a GitHub Body
guidelines/github-issues.md|These rules apply to every body written for GitHub: a PR, an issue, a comment or a reply
guidelines/github-issues.md|A skill that has already asked about each point skips this step, and starts at "Check for Duplicates"
skills/4-open-pr/SKILL.md|"Writing a GitHub Body" in `${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md`
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
guidelines/tdd.md|Only a contract, a mapping or a DTO grows this way, and only when it relies on no existing code
skills/2-implement/SKILL.md|writing a unit's tests together when it isn't a contract, a mapping or a DTO, or when it relies on existing code
skills/5-handle-review/SKILL.md|and before the push, follow the process
skills/5-handle-review/SKILL.md|triage every comment before asking about any
skills/5-handle-review/SKILL.md|"One Item at a Time" in `${CLAUDE_PLUGIN_ROOT}/guidelines/language.md`
skills/5-handle-review/SKILL.md|options **Should fix** / **Out of scope** / **Park**, with the triage's choice recommended
skills/5-handle-review/SKILL.md|Nothing is changed, opened or posted until every comment is decided
skills/5-handle-review/SKILL.md|"Check for Duplicates" in `${CLAUDE_PLUGIN_ROOT}/guidelines/github-issues.md`
skills/5-handle-review/SKILL.md|"Replying to Review Feedback" in `${CLAUDE_PLUGIN_ROOT}/guidelines/git-workflow.md`
guidelines/specification.md|**Distil it into `<path>`**
guidelines/specification.md|`docs: distil feature specification into <path>`
guidelines/specification.md|the user approves it before it is committed
guidelines/specification.md|The revert still follows, as the last commit
guidelines/specification.md|The distilled text holds no plan, progress, design notes, refactorings or marker line
guidelines/specification.md|with the acceptance criteria only if the user wants them
guidelines/specification.md|the spec file lives outside the root of the host repository
guidelines/specification.md|A spec written outside the root of the host repository has none
guidelines/specification.md|**`FEATURE-SPEC.md` (Recommended)** / **Another path**
guidelines/specification.md|`docs: move feature specification to <path>` commit
guidelines/specification.md|### When the Spec Is Settled
guidelines/specification.md|comes after the branch's `docs: feature specification` commit
guidelines/specification.md|Later commits, such as review fixes, don't reopen it
guidelines/specification.md|No skill asks about the spec when:
guidelines/specification.md|the branch has no spec
guidelines/specification.md|the spec is already settled
guidelines/specification.md|the branch is a main plan branch, whose name contains `main-plan-`
skills/4-open-pr/SKILL.md|"When the Spec Is Settled" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
skills/5-handle-review/SKILL.md|"When the Spec Is Settled" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
skills/4-open-pr/SKILL.md|"Closing the Specification" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
skills/5-handle-review/SKILL.md|"Closing the Specification" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
skills/5-handle-review/SKILL.md|`${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`, to settle the spec
skills/1-plan/SKILL.md|keep a single marker line under the title
guidelines/specification.md|### A Leftover Spec
guidelines/specification.md|A file with neither is the repository's own, and never counts as a leftover
guidelines/specification.md|rule 1's path included
guidelines/specification.md|git log -1 --diff-filter=A --format=%s origin/<default-branch> -- <path>
guidelines/specification.md|the commit that added the file there is `docs: feature specification`
skills/1-plan/SKILL.md|"A Leftover Spec" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
skills/stabilize/SKILL.md|"A Leftover Spec" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
skills/multi-phase-spec-pr/SKILL.md|"A Leftover Spec" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
guidelines/specification.md|Remove it in its own PR, then run this again
skills/3-organize-commits/SKILL.md|"Closing the Specification" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
skills/3-organize-commits/SKILL.md|"When the Spec Is Settled" in `${CLAUDE_PLUGIN_ROOT}/guidelines/specification.md`
skills/5-handle-review/SKILL.md|list in `Needs you` every commit left unpushed, a convention's included
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

! grep -rniE 'auto-memory|allowMemoryWrites' "$plugin/skills" "$plugin/guidelines"
report $? "skills and guidelines leave Claude's memory to the user"

old_fields='^ *- \*\*(Observation|Competing explanations|Assumptions|What would change it|Recommendation|Why it matters)[:*]'
old_format="$(grep -rlE "$old_fields" "$plugin/skills" "$plugin/guidelines" "$plugin/evals" --exclude-dir=results)"
if [ -z "$old_format" ]; then
  report 0 "every finding is recorded in the five fields"
fi
while IFS= read -r file; do
  [ -n "$file" ] || continue
  report 1 "${file#"$plugin"/} records a finding in the five fields"
done <<< "$old_format"

for fixture in "$plugin"/evals/*/fixture.sh; do
  grep -qE '^- AC[0-9]+: (met|changed|deferred|unchecked)' "$fixture" || continue
  awk '
    /^## Progress/ { progress = 1; next }
    progress && /^### Acceptance$/ { heading = 1; next }
    progress && /^- AC[0-9]+: (met|changed|deferred|unchecked)/ { if (!heading) misplaced = 1; next }
    heading && /^$/ { next }
    heading && /^[A-Z_]+$/ { exit }
    heading { misplaced = 1; exit }
    END { exit !heading || misplaced }
  ' "$fixture"
  report $? "${fixture#"$plugin"/evals/} records acceptance results last, under ### Acceptance"
done

search_warnings="$(grep -rlF -- '--search`' "$plugin/skills" "$plugin/guidelines")"
[ "$search_warnings" = "$plugin/guidelines/git-workflow.md" ]
report $? "only git-workflow.md warns against \`gh pr list --search\`"

design_check_copies="$(
  for file in "$plugin"/skills/*/SKILL.md "$plugin"/guidelines/*.md; do
    on_one_line "$file" | grep -qF 'the rules it points to in `code-standards.md`' && echo "$file"
  done
)"
[ "$design_check_copies" = "$plugin/guidelines/subagents.md" ]
report $? "only subagents.md says what a design-check brief copies"

test_run_reasons="$(grep -rlF -- 'tested while they were built' "$plugin/skills" "$plugin/guidelines")"
[ "$test_run_reasons" = "$plugin/guidelines/git-workflow.md" ]
report $? "only git-workflow.md says why organizing commits runs the tests once"

guidelines_into_skills="$(grep -rlE -- 'skills/[a-z0-9-]+/SKILL\.md`|in `/aido:[a-z0-9-]+`|`/aido:[a-z0-9-]+` defines' "$plugin/guidelines")"
[ -z "$guidelines_into_skills" ]
report $? "no guideline points into a skill for a rule"

index_rules_in_skill="$(grep -rlF -- 'skills/map-architecture/SKILL.md' "$plugin/skills")"
[ -z "$index_rules_in_skill" ]
report $? "no skill points into map-architecture for the index rules"

outcome_namers="$(grep -rlE -- 'revert: docs: feature specification|docs: (move|keep|distil) feature specification' "$plugin/skills" "$plugin/guidelines")"
[ "$outcome_namers" = "$plugin/guidelines/specification.md" ]
report $? "only specification.md names the commits that settle the spec"

skip_listers="$(grep -rlF -- 'main plan branch** → ask nothing' "$plugin/skills" "$plugin/guidelines")"
[ -z "$skip_listers" ]
report $? "only specification.md says when no skill asks about the spec"

! grep -rnE -- 'Keep it where it is|docs: keep feature specification|`docs/specs/<feature-slug>\.md`' "$plugin/skills" "$plugin/guidelines"
report $? "no skill keeps the spec in the docs, or offers a docs folder for it"

! grep -rnF -- '**Move it to' "$plugin/skills" "$plugin/guidelines"
report $? "no skill offers to move the spec into the docs unchanged"

wrapping_reasons="$(grep -rlF -- 'a single newline as a line' "$plugin/skills" "$plugin/guidelines")"
[ "$wrapping_reasons" = "$plugin/guidelines/github-issues.md" ]
report $? "only github-issues.md says why GitHub bodies aren't hard-wrapped"

handle_review="$plugin/skills/5-handle-review/SKILL.md"
guidance_line="$(grep -n -m1 -F 'Worth examining' "$handle_review" | cut -d: -f1)"
ending_line="$(grep -n -m1 -F '"Ending a Skill"' "$handle_review" | cut -d: -f1)"
[ -n "$guidance_line" ] && [ -n "$ending_line" ] && [ "$guidance_line" -lt "$ending_line" ]
report $? "5-handle-review gives the review guidance before its ending"

open_pr="$plugin/skills/4-open-pr/SKILL.md"
verify_line="$(grep -n -m1 -E '^## Step [0-9.]+: Offer Verification' "$open_pr" | cut -d: -f1)"
settle_line="$(grep -n -m1 -E '^## Step [0-9.]+: Settle the Specification' "$open_pr" | cut -d: -f1)"
push_line="$(grep -n -m1 -E '^## Step [0-9.]+: Push Changes' "$open_pr" | cut -d: -f1)"
[ -n "$verify_line" ] && [ -n "$settle_line" ] && [ -n "$push_line" ] && [ "$verify_line" -lt "$settle_line" ] && [ "$settle_line" -lt "$push_line" ]
report $? "4-open-pr settles the spec after the verification offer, before the push"

conventions_line="$(grep -n -m1 -F '## Suggest Repository Conventions' "$handle_review" | cut -d: -f1)"
settle_line="$(grep -n -m1 -F '## Settle the Specification' "$handle_review" | cut -d: -f1)"
push_line="$(grep -n -m1 -F '## Push and End' "$handle_review" | cut -d: -f1)"
[ -n "$conventions_line" ] && [ -n "$settle_line" ] && [ -n "$push_line" ] && [ "$conventions_line" -lt "$settle_line" ] && [ "$settle_line" -lt "$push_line" ]
report $? "5-handle-review settles the spec after the review commits, before the push"

marker='> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.'
for file in guidelines/specification.md skills/stabilize/SKILL.md skills/multi-phase-spec-pr/SKILL.md; do
  awk -v marker="$marker" '
    /^# <descriptive title>$/ { title = NR; templates++ }
    title && NR == title + 2 { if ($0 == marker) marked++; title = 0 }
    END { exit !(templates > 0 && templates == marked) }
  ' "$plugin/$file"
  report $? "$file puts the marker line after the title of every spec it writes"
done

[ "$(grep -cF -- "$marker" "$plugin/guidelines/specification.md")" -ge 2 ]
report $? "the leftover check looks for the marker line the template writes"

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

# macOS sed rejects GNU's `sed -i` form and `\n` in a replacement. `perl -pi` works on both.
! grep -rnIE --exclude=skills.sh --exclude-dir=__pycache__ --exclude-dir=results '\bsed -i\b' "$root/tests" "$root/plugins/aido/evals"
report $? "tests and eval fixtures edit files in place with perl -pi"

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures failed"
  exit 1
fi
