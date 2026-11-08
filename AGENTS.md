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
- `tests/` — free checks for the hook scripts and the skills; run `tests/hooks.sh`, which needs `jq`,
  `tests/skills.sh` and `tests/test_skills.py`, on every change
- `plugins/aido/evals/` — eval cases that measure the skills' behaviour against plain Claude Code.
  Run the full round from time to time, such as before a release, as `docs/evals.md` describes, and
  commit the results it updates. `tests/test_evals.py` checks the runner for free
- `docs/evals.md` — what the evals are for, how to run and read them, and the current results
- `docs/evals/` — the data behind those results
- `docs/readme/` — the images the README displays
- `docs/assets/` — source images, such as the original mascot

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
- a PR that changes a format the skills write or read, such as the specification structure or a
  PR description section, shows an example of it before and after in its description
- every PR that changes the plugin bumps `version` in
  `plugins/aido/.claude-plugin/plugin.json`, following semantic versioning
- after every change, run `claude plugin validate .` and `claude plugin validate ./plugins/aido`
- when a change is a risky change to how agents behave, in a skill or a guideline, propose one run of
  the matching eval cases as `docs/evals.md` describes, and ask first, because they are billed to an API
  account or count against a subscription's limits. Other changes rely on the free checks and the next
  full round. One run records nothing
- a change to a skill's behaviour with no matching case either gets a new case, or says in its PR that
  it isn't covered
- hook scripts use no shell variables or substitutions, reading stdin with `grep` alone, so that
  the marketplace validator can follow them and hosts need nothing installed. A hook's opt-out may
  read `git config`, and the hook enforces its rule when `git` is missing
- try changes locally with `claude --plugin-dir ./plugins/aido`
