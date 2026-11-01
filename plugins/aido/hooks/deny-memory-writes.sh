#!/bin/sh
jq -c '
  select((.tool_input.file_path // "") | test("/\\.claude/projects/.*/memory/"))
  | {
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "Writing to Claude memory is forbidden here (evolving-guidelines.md: do not use auto-memory). Propose a guideline edit instead."
      }
    }
'
