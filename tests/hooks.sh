#!/usr/bin/env bash

root="$(cd "$(dirname "$0")/.." && pwd)"
hooks="$root/plugins/aido/hooks"
failures=0

commit_denial='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"No Co-Authored-By/Claude references in commit messages (git-workflow.md). Use a subject-line-only message."}}'
push_approval='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"aido asks for your approval before every push (git-workflow.md)."}}'

check() {
  local name="$1" expected="$2" actual="$3"

  if [ "$actual" == "$expected" ]; then
    echo "ok   - $name"
  else
    echo "FAIL - $name"
    echo "  expected: $expected"
    echo "  actual:   $actual"
    failures=$((failures + 1))
  fi
}

commit_hook_output() {
  jq -n --arg command "$1" '{tool_input: {command: $command}}' | "$hooks/deny-commit-attribution.sh"
}

push_hook_output() {
  jq -n --arg command "$1" '{tool_input: {command: $command}}' | "$hooks/ask-before-push.sh"
}

in_repo_with_config() {
  local key="$1" value="$2" hook="$3" input="$4"

  local repo
  repo="$(mktemp -d)"
  git -C "$repo" init -q
  [ -n "$key" ] && git -C "$repo" config "$key" "$value"
  mkdir "$repo/nested"
  (cd "$repo/nested" && printf '%s' "$input" | "$hooks/$hook" 2>&1)
  rm -rf "$repo"
}

check_command_is_a_plugin_script() {
  local matcher="$1" script="$2"

  local expected="\"\${CLAUDE_PLUGIN_ROOT}/hooks/$script\""

  local command
  command="$(jq -r --arg matcher "$matcher" \
    '.hooks.PreToolUse[] | select(.matcher == $matcher) | .hooks[].command' "$hooks/hooks.json" \
    | grep -Fx "$expected")"

  check "$matcher hook runs $script by its literal path" "$expected" "$command"
}

check_script_is_followable() {
  local script="$1"

  local computed
  computed="$(grep -nE '\$|`|<<|\b(npx|uvx|pip|npm|bunx|pnpm|yarn)\b' "$hooks/$script")"

  check "$script computes nothing and runs no launcher" "" "$computed"
}

output_with_only_grep_on_path() {
  local script="$1" input="$2"

  local bin
  bin="$(mktemp -d)"
  ln -s "$(command -v grep)" "$bin/grep"
  printf '%s' "$input" | env -i PATH="$bin" "$hooks/$script" 2>&1
  rm -rf "$bin"
}

check "commit hook denies with only grep on the path" "$commit_denial" \
  "$(output_with_only_grep_on_path deny-commit-attribution.sh \
    '{"session_id":"abc","tool_name":"Bash","tool_input":{"command":"git commit -m \"noreply@anthropic.com\"","description":"Commit"}}')"

check "commit hook ignores a trailer in another field" "" \
  "$(echo '{"tool_input":{"command":"git commit -m \"feat: add lists\"","description":"git commit without noreply@anthropic.com"}}' \
    | "$hooks/deny-commit-attribution.sh")"
check "commit hook ignores a command named inside another field" "" \
  "$(echo '{"tool_input":{"command":"ls","description":"\"command\":\"git commit noreply@anthropic.com\""}}' \
    | "$hooks/deny-commit-attribution.sh")"
check "commit hook denies a tab between git and commit" "$commit_denial" \
  "$(echo '{"tool_input":{"command":"git\tcommit -m \"noreply@anthropic.com\""}}' \
    | "$hooks/deny-commit-attribution.sh")"

check "commit hook denies a Co-Authored-By trailer" "$commit_denial" \
  "$(commit_hook_output 'git commit -m "feat: add lists

Co-Authored-By: Someone <someone@example.com>"')"
check "commit hook denies a trailer in another letter case" "$commit_denial" \
  "$(commit_hook_output 'git commit -m "feat: add lists co-authored-BY: someone"')"
check "commit hook denies a generated-with line" "$commit_denial" \
  "$(commit_hook_output 'git commit -m "feat: add lists Generated with [Claude Code]"')"
check "commit hook denies the anthropic noreply address" "$commit_denial" \
  "$(commit_hook_output 'git  commit -m "feat: add lists noreply@anthropic.com"')"
check "commit hook allows a plain commit" "" \
  "$(commit_hook_output 'git commit -m "feat: add lists"')"
check "commit hook allows a trailer outside a commit" "" \
  "$(commit_hook_output 'grep -i co-authored-by: README.md')"
check "commit hook allows input without a command" "" \
  "$(echo '{"tool_input":{}}' | "$hooks/deny-commit-attribution.sh")"
check_command_is_a_plugin_script "Bash" "deny-commit-attribution.sh"
check_script_is_followable "deny-commit-attribution.sh"

commit_with_trailer='{"tool_input":{"command":"git commit -m \"noreply@anthropic.com\""}}'
check "commit hook still denies in a repository that has not opted out" "$commit_denial" \
  "$(in_repo_with_config "" "" deny-commit-attribution.sh "$commit_with_trailer")"
check "commit hook allows attribution in a repository that opted out" "" \
  "$(in_repo_with_config aido.allowCommitAttribution true deny-commit-attribution.sh "$commit_with_trailer")"
check "commit hook still denies when the opt-out is false" "$commit_denial" \
  "$(in_repo_with_config aido.allowCommitAttribution false deny-commit-attribution.sh "$commit_with_trailer")"
check "commit hook still denies when the opt-out is not a boolean" "$commit_denial" \
  "$(in_repo_with_config aido.allowCommitAttribution maybe deny-commit-attribution.sh "$commit_with_trailer")"

check "push hook asks with only grep on the path" "$push_approval" \
  "$(output_with_only_grep_on_path ask-before-push.sh \
    '{"session_id":"abc","tool_name":"Bash","tool_input":{"command":"git push origin main","description":"Push"}}')"
check "push hook asks for a plain push" "$push_approval" "$(push_hook_output 'git push origin main')"
check "push hook asks for a force push" "$push_approval" "$(push_hook_output 'git push --force origin main')"
check "push hook asks for a bare push" "$push_approval" "$(push_hook_output 'git push')"
check "push hook asks for a push after other commands" "$push_approval" \
  "$(push_hook_output 'git add . && git commit -m "feat: add lists" && git push origin main')"
check "push hook asks on a later line" "$push_approval" "$(push_hook_output $'git status\ngit push origin main')"
check "push hook asks with a directory option" "$push_approval" "$(push_hook_output 'git -C ../todo-app push origin main')"
check "push hook asks with a quoted directory option" "$push_approval" \
  "$(push_hook_output 'git -C "../todo app" push origin main')"
check "push hook asks with a config option" "$push_approval" "$(push_hook_output 'git -c push.default=current push')"
check "push hook asks with a flag option" "$push_approval" "$(push_hook_output 'git --no-pager push origin main')"
check "push hook asks before a shell separator" "$push_approval" "$(push_hook_output 'git push; echo done')"
check "push hook ignores git stash push" "" "$(push_hook_output 'git stash push -m wip')"
check "push hook ignores a commit" "" "$(push_hook_output 'git commit -m "feat: add lists"')"
check "push hook ignores a longer subcommand" "" "$(push_hook_output 'git pushed')"
check "push hook ignores a push in another field" "" \
  "$(echo '{"tool_input":{"command":"ls","description":"before git push origin main"}}' | "$hooks/ask-before-push.sh")"
check "push hook allows input without a command" "" "$(echo '{"tool_input":{}}' | "$hooks/ask-before-push.sh")"
check "push hook cannot be opted out of" "$push_approval" \
  "$(in_repo_with_config aido.allowPush true ask-before-push.sh '{"tool_input":{"command":"git push"}}')"
check_command_is_a_plugin_script "Bash" "ask-before-push.sh"
check_script_is_followable "ask-before-push.sh"

check "no hook runs on writes, so memory is left to the user" "" \
  "$(jq -r '.hooks.PreToolUse[].matcher | select(test("Write|Edit"))' "$hooks/hooks.json")"

check "compaction hook runs by its literal path, only after a compaction" \
  "\"\${CLAUDE_PLUGIN_ROOT}/hooks/remind-after-compaction.sh\"" \
  "$(jq -r '.hooks.SessionStart[] | select(.matcher == "compact") | .hooks[].command' "$hooks/hooks.json")"
check "compaction hook tells the agent to reload the skill" "1" \
  "$("$hooks/remind-after-compaction.sh" | grep -c 'invoke that skill again')"
check_script_is_followable "remind-after-compaction.sh"

# Without `cwd`, Copilot CLI runs plugin hooks from the plugin directory, so the opt-out's
# `git config` would read the plugin checkout. Copilot documents `cwd` as relative to the
# repository root. Claude Code documents no `cwd` field and runs hooks in the session's directory.
# On both hosts, a Bash command that first changes into another repository is still checked
# against the session's repository. Manual probes when `cwd` was added saw a repository opt-out
# honoured in both hosts, without recording the Copilot version. Nothing here runs a host.
check "every tool hook runs from the session's directory, where its opt-out is read" "" \
  "$(jq -r '.hooks.PreToolUse[].hooks[] | select(.cwd != ".") | .command' "$hooks/hooks.json")"

if [ "$failures" -gt 0 ]; then
  echo "$failures failed"
  exit 1
fi
echo "all passed"
