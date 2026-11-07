# Copilot CLI

Use this guidance when running aido in Copilot CLI. The skill's decisions and approval checkpoints
stay the same.

- Resolve every `${CLAUDE_PLUGIN_ROOT}` path against the plugin root identified in the skill. Do not
  rely on an environment variable.
- Use `ask_user` wherever a skill or guideline says `AskUserQuestion`. Keep its questions and
  options, and wait for the user's answer. Only an answer from a person is approval. If asking is
  unavailable or no person answers, stop rather than assuming approval.
- Use `task` for `Agent`, retaining any requirement for a fresh subagent. Omit the model names in the
  skills and use the host's default. When a skill may need to resume the same child, start it with
  `mode: background`, retain its agent ID, and use `read_agent` to get its results.
- Use `skill` for the `Skill` tool. Invoke aido skills by their unqualified names, such as `1-plan`.
  Check that the loaded skill's base directory is in this plugin; if another skill took precedence,
  stop and tell the user.
- Use `write_agent` for `SendMessage` to the same child. If the child cannot be resumed, stop and
  report the question instead of proceeding without the answer.
- In instructions for the user, replace `/aido:<name>` with `/<name>`, such as `/1-plan`.
