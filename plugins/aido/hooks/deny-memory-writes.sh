#!/bin/sh
if git config --type=bool --get aido.allowMemoryWrites 2>/dev/null | grep -qx true
then
  exit 0
fi
if grep -oE '"(file_path|path)"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' \
  | grep -q '/\.claude/projects/.*/memory/'
then
  printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Writing to Claude memory is forbidden here (evolving-guidelines.md: do not use auto-memory). Propose a guideline edit instead."}}'
fi
