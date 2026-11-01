#!/bin/sh
jq -c '
  select(
    (.tool_input.command // "")
    | test("git[[:space:]]+commit")
      and test("co-authored-by:|generated with \\[claude|noreply@anthropic"; "i")
  )
  | {
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "No Co-Authored-By/Claude references in commit messages (git-workflow.md). Use a subject-line-only message."
      }
    }
'
