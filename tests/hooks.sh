#!/usr/bin/env bash

root="$(cd "$(dirname "$0")/.." && pwd)"
hooks="$root/plugins/aido/hooks"
failures=0

commit_denial='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"No Co-Authored-By/Claude references in commit messages (git-workflow.md). Use a subject-line-only message."}}'

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

check_command_is_a_plugin_script() {
  local matcher="$1" script="$2"

  local command
  command="$(jq -r --arg matcher "$matcher" \
    '.hooks.PreToolUse[] | select(.matcher == $matcher) | .hooks[].command' "$hooks/hooks.json")"

  check "$matcher hook runs $script by its literal path" "\"\${CLAUDE_PLUGIN_ROOT}/hooks/$script\"" "$command"
}

check_script_is_followable() {
  local script="$1"

  local computed
  computed="$(grep -nE '\$|`|<<|\b(npx|uvx|pip|npm|bunx|pnpm|yarn)\b' "$hooks/$script")"

  check "$script computes nothing and runs no launcher" "" "$computed"
}

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

if [ "$failures" -gt 0 ]; then
  echo "$failures failed"
  exit 1
fi
echo "all passed"
