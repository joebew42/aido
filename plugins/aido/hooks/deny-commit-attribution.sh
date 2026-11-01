#!/bin/sh
if grep -oE '"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' \
  | grep -E 'git([[:space:]]|\\[nrt])+commit' \
  | grep -Eiq 'co-authored-by:|generated with \[claude|noreply@anthropic'
then
  printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"No Co-Authored-By/Claude references in commit messages (git-workflow.md). Use a subject-line-only message."}}'
fi
