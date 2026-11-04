#!/bin/sh
if grep -oE '"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' \
  | grep -Eq 'git([[:space:]]|\\[nrt])+(-[^[:space:]]+([[:space:]]+(\\"[^"]*\\"|[^-[:space:]][^[:space:]]*))?[[:space:]]+)*push([[:space:]]|\\[nrt]|[;&|)"])'
then
  printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"aido asks for your approval before every push (git-workflow.md)."}}'
fi
