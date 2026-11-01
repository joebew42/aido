#!/bin/sh
if grep -oE '"file_path"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' \
  | grep -q '/\.claude/projects/.*/memory/'
then
  printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Writing to Claude memory is forbidden here (evolving-guidelines.md: do not use auto-memory). Propose a guideline edit instead."}}'
fi
