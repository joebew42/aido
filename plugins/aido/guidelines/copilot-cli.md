# Running in Copilot CLI

This file applies only in GitHub Copilot CLI. In Claude Code, ignore it.

The skills and guidelines are written for Claude Code. Read them through the mapping below. Their
steps, questions and approvals stay the same.

## Paths

`${CLAUDE_PLUGIN_ROOT}` is not replaced here. It stands for the plugin root: the folder two levels
above the base directory the `skill` tool reports for an aido skill, holding `guidelines/` and
`skills/`. Read every `${CLAUDE_PLUGIN_ROOT}/...` path from there.

## Skills

The user runs a skill as `/aido:<name>`, as in Claude Code. To invoke one with the `Skill` tool, call
the `skill` tool with `<name>` alone, such as `1-plan`. Any words after the name, such as `item 3`,
are part of the request you then follow.

## Tools

- `AskUserQuestion` is `ask_user`. Ask each question as one field of the form: its options become
  the choices, a multi-select question becomes a multi-select field, and the recommended option is
  the default. Questions asked together stay in one form.
- `Agent` is `task`, with the `general-purpose` agent and no `model`. Model names in the skills, such
  as `fable`, are Claude Code's, so act as "When the Model Is Unavailable" in `subagents.md`
  describes. Brief the child with what the skill lists and add no instructions of your own: the child
  follows its skill, and returns any question it can't ask.
- When a skill may send a child a message later with `SendMessage`, start that child with `task` in
  `mode: "background"`, and keep its agent ID. When it finishes, read its result with `read_agent`.
  Send the answer with `write_agent` to the same agent ID, then read its next result the same way.

## Approvals

Only a person's answer is approval: a choice in an `ask_user` form or a reply they write. A declined
or cancelled form, an automatic continuation, or no answer is not. When asking is unavailable, such
as in Autopilot, with `--no-ask-user` or in a prompt run, stop where the skill would ask: show the
question and its options, and end your turn. Never choose an option for the user, not even the
recommended one.

aido's hook asks before every `git push`. When the push is denied or the prompt can't be shown,
report it and stop. Never push another way.

## After a Compaction

Copilot runs no reminder after compacting the conversation. If earlier turns were replaced by a
summary while you work under an aido skill, invoke that skill again, read again the guidelines it
names, and carry on from where the work stands, without repeating settled steps or questions.
