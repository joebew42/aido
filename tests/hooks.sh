#!/usr/bin/env bash

root="$(cd "$(dirname "$0")/.." && pwd)"
hooks="$root/plugins/aido/hooks"
failures=0

commit_denial='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"No Co-Authored-By/Claude references in commit messages (git-workflow.md). Use a subject-line-only message."}}'
memory_denial='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Writing to Claude memory is forbidden here (evolving-guidelines.md: do not use auto-memory). Propose a guideline edit instead."}}'

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

memory_hook_output() {
  jq -n --arg file_path "$1" '{tool_input: {file_path: $file_path}}' | "$hooks/deny-memory-writes.sh"
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
check "memory hook denies with only grep on the path" "$memory_denial" \
  "$(output_with_only_grep_on_path deny-memory-writes.sh \
    '{"session_id":"abc","tool_name":"Write","tool_input":{"file_path":"/home/me/.claude/projects/todo-app/memory/notes.md","content":"x"}}')"

check "commit hook ignores a trailer in another field" "" \
  "$(echo '{"tool_input":{"command":"git commit -m \"feat: add lists\"","description":"git commit without noreply@anthropic.com"}}' \
    | "$hooks/deny-commit-attribution.sh")"
check "commit hook ignores a command named inside another field" "" \
  "$(echo '{"tool_input":{"command":"ls","description":"\"command\":\"git commit noreply@anthropic.com\""}}' \
    | "$hooks/deny-commit-attribution.sh")"
check "commit hook denies a tab between git and commit" "$commit_denial" \
  "$(echo '{"tool_input":{"command":"git\tcommit -m \"noreply@anthropic.com\""}}' \
    | "$hooks/deny-commit-attribution.sh")"
check "memory hook ignores a memory path in another field" "" \
  "$(echo '{"tool_input":{"file_path":"/tmp/notes.md","content":"\"file_path\":\"/home/me/.claude/projects/todo-app/memory/notes.md\""}}' \
    | "$hooks/deny-memory-writes.sh")"

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

check "memory hook denies a write under a project's memory directory" "$memory_denial" \
  "$(memory_hook_output '/home/me/.claude/projects/todo-app/memory/notes.md')"
check "memory hook allows a write to a project's other files" "" \
  "$(memory_hook_output '/home/me/.claude/projects/todo-app/notes.md')"
check "memory hook allows a memory directory outside Claude's projects" "" \
  "$(memory_hook_output '/home/me/todo-app/memory/notes.md')"
check "memory hook allows input without a file path" "" \
  "$(echo '{"tool_input":{}}' | "$hooks/deny-memory-writes.sh")"
check_command_is_a_plugin_script "Write|Edit|MultiEdit" "deny-memory-writes.sh"
check_script_is_followable "deny-memory-writes.sh"

commit_with_trailer='{"tool_input":{"command":"git commit -m \"noreply@anthropic.com\""}}'
check "commit hook still denies in a repository that has not opted out" "$commit_denial" \
  "$(in_repo_with_config "" "" deny-commit-attribution.sh "$commit_with_trailer")"
check "commit hook allows attribution in a repository that opted out" "" \
  "$(in_repo_with_config aido.allowCommitAttribution true deny-commit-attribution.sh "$commit_with_trailer")"
check "commit hook still denies when the opt-out is false" "$commit_denial" \
  "$(in_repo_with_config aido.allowCommitAttribution false deny-commit-attribution.sh "$commit_with_trailer")"
check "commit hook still denies when the opt-out is not a boolean" "$commit_denial" \
  "$(in_repo_with_config aido.allowCommitAttribution maybe deny-commit-attribution.sh "$commit_with_trailer")"

memory_write='{"tool_input":{"file_path":"/home/me/.claude/projects/todo-app/memory/notes.md"}}'
check "memory hook still denies in a repository that has not opted out" "$memory_denial" \
  "$(in_repo_with_config "" "" deny-memory-writes.sh "$memory_write")"
check "memory hook allows writes in a repository that opted out" "" \
  "$(in_repo_with_config aido.allowMemoryWrites true deny-memory-writes.sh "$memory_write")"
check "an opt-out covers only its own hook" "$memory_denial" \
  "$(in_repo_with_config aido.allowCommitAttribution true deny-memory-writes.sh "$memory_write")"

if [ "$failures" -gt 0 ]; then
  echo "$failures failed"
  exit 1
fi
echo "all passed"
