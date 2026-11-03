# Working on this repository

This repository is a Claude Code plugin marketplace. See `README.md` for what it offers and how to
install it.

## Layout

- `.claude-plugin/marketplace.json` — the marketplace `aido`, listing one plugin
- `plugins/aido/.claude-plugin/plugin.json` — the `aido` plugin manifest
- `plugins/aido/skills/<name>/SKILL.md` — the skills, invoked as `/aido:<name>`
- `plugins/aido/guidelines/` — the guidelines the skills load
- `plugins/aido/.claude-plugin/icon.png` — the plugin's marketplace icon
- `plugins/aido/hooks/hooks.json` — the plugin's hooks, each running a script next to it
- `tests/` — checks for the hook scripts; run `tests/hooks.sh`, which needs `jq`
- `docs/` — the diagrams in the README

## Conventions for changes

- skills and guidelines stay stack-agnostic and free of references to third-party companies or
  projects, except the tools the workflow depends on, such as GitHub; examples use a TODO app
- inside a `SKILL.md`, refer to bundled files as `${CLAUDE_PLUGIN_ROOT}/guidelines/...` or
  `${CLAUDE_PLUGIN_ROOT}/skills/...` — Claude Code substitutes the path when it loads the skill.
  Guidelines are read as plain files, where no substitution happens, so they refer to each other
  by file name
- refer to skills by their full name, `/aido:<name>`
- a `CLAUDE.md` inside the plugin is not loaded; anything the skills need must be in a skill or a
  guideline they load
- every PR that changes the plugin bumps `version` in
  `plugins/aido/.claude-plugin/plugin.json`, following semantic versioning
- after every change, run `claude plugin validate .` and `claude plugin validate ./plugins/aido`
- hook scripts use no shell variables or substitutions, reading stdin with `grep` alone, so that
  the marketplace validator can follow them and hosts need nothing installed
- try changes locally with `claude --plugin-dir ./plugins/aido`
