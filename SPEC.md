# Pass the Anthropic marketplace validation

## Context

Publishing aido as a plugin in the Anthropic plugin marketplace fails validation on `main` at
cc8bf11: 1 blocking issue, 3 warnings and 9 policy holds.

- **Blocking, `COMMAND_SCRIPT_NOT_FOLLOWED`, `HOOK_OUTPUT_UNINSPECTED`** — the two `PreToolUse`
  hooks in `plugins/aido/hooks/hooks.json` are inline shell one-liners with `$(jq …)` substitutions,
  which the validator cannot read. It follows a command only when it names a plain shell script by
  a literal `${CLAUDE_PLUGIN_ROOT}/<file>` path, and that script computes no path: no shell variables
  other than `CLAUDE_PLUGIN_ROOT`, no substitutions, no wildcard or brace patterns
- **`ICON_MISSING`** — the plugin has no icon. It needs a square PNG or JPEG, 512 to 2048 px on each
  side and under 2 MB. The file can become the listing icon only once, the first time the plugin is
  saved or submitted in the developer portal
- **`NAME_CONFUSABLE`** — "aido" is one or two characters from several listings (aide, aino, aiso,
  alto, ando and others). None of them is connected to aido

## Intent

Clear the blocking issue and the warnings that can be cleared from the repository, so the plugin can
be submitted to the marketplace, with both hooks behaving as they do today.

## Out of scope

- renaming the plugin: aido stays, and the name holds are left for the reviewer to decide
- submitting the plugin in the developer portal, which the user does
- changing what the hooks enforce
- clearing every hook finding at any cost: `COMMAND_SCRIPT_NOT_FOLLOWED` and
  `HOOK_OUTPUT_UNINSPECTED` may remain as holds, because the validator may still leave the scripts
  to a reviewer, and that is acceptable

## Acceptance criteria

- AC1: the commit-message hook denies a `git commit` command containing `Co-Authored-By:`,
  `Generated with [Claude` or `noreply@anthropic`, in any letter case
- AC2: the commit-message hook produces no output for any other Bash command
- AC3: the memory hook denies a Write, Edit or MultiEdit whose `file_path` is under
  `.claude/projects/*/memory/`
- AC4: the memory hook produces no output for any other `file_path`, or when there is none
- AC5: each command in `plugins/aido/hooks/hooks.json` is a literal
  `${CLAUDE_PLUGIN_ROOT}/<file>` path to a plain shell script inside the plugin
- AC6: those scripts use no shell variables, substitutions, wildcard or brace patterns,
  here-documents, package launchers or package installs
- AC7: the plugin has a square PNG icon of 512 to 2048 px on each side and under 2 MB, at
  `plugins/aido/.claude-plugin/icon.png`
- AC8 (manual): the user confirms the icon looks right for a permanent listing icon
- AC9 (manual): re-running the marketplace validation reports no blocking issue and no
  `ICON_MISSING`; the `NAME_CONFUSABLE` holds are expected to remain
- AC10: `claude plugin validate .` and `claude plugin validate ./plugins/aido` pass
- AC11: `version` in `plugins/aido/.claude-plugin/plugin.json` is bumped

## Plan

All of this is infrastructure: the plugin's packaging.

1. **infrastructure — move the commit-message hook into a script** (AC1, AC2, AC5, AC6) —
   `plugins/aido/hooks/deny-commit-attribution.sh`, executable, doing its work in a single `jq`
   filter over stdin, so the shell needs no variables. `hooks.json` runs it by its
   `${CLAUDE_PLUGIN_ROOT}` path. `tests/hooks.sh`, outside the plugin, feeds sample tool inputs to
   the script and checks its output, driving the change test-first
2. **infrastructure — move the memory hook into a script** (AC3, AC4, AC5, AC6) —
   `plugins/aido/hooks/deny-memory-writes.sh`, in the same way, with cases added to `tests/hooks.sh`
3. **infrastructure — add the icon** (AC7, AC8) — generate a square 512 px PNG of the README's 🥋
   emoji on a transparent background, at `plugins/aido/.claude-plugin/icon.png`, checked by
   `tests/icon.sh`. The generator is not committed. Show it to the user for confirmation
4. **infrastructure — record the change** (AC10, AC11) — bump `version` to 2.0.1, a patch because
   the behaviour does not change; add the hook scripts, the icon and `tests/hooks.sh` to "Layout" in
   `CLAUDE.md`; run both `claude plugin validate` commands
5. **manual — re-run the marketplace validation** (AC9) — the user re-runs it on the pushed branch,
   and we adjust the scripts if it still blocks

The enabling refactoring analysis was skipped.

## Progress

- [x] commit-message hook moved into a script
- [x] memory hook moved into a script
- [x] icon added
- [x] version bumped and the change recorded in `CLAUDE.md`
- [ ] marketplace validation re-run by the user

Acceptance criteria:

- AC1: met — `tests/hooks.sh`, "commit hook denies" cases
- AC2: met — `tests/hooks.sh`, "commit hook allows" cases
- AC3: met — `tests/hooks.sh`, "memory hook denies a write under a project's memory directory"
- AC4: met — `tests/hooks.sh`, "memory hook allows" cases
- AC5: met — `tests/hooks.sh`, "runs … by its literal path" cases
- AC6: met — `tests/hooks.sh`, "computes nothing and runs no launcher" cases, which also reject `$`
  inside the `jq` filters
- AC7: met — `tests/icon.sh`
- AC8: met — confirmed by the user: the 🥋 emoji from Noto Color Emoji, on a transparent background
  chosen after a preview on light and dark; its edges are soft, upscaled from about 136 px
- AC9: unchecked — waiting for the user to re-run the marketplace validation on the pushed branch
- AC10: met — both `claude plugin validate` commands pass
- AC11: met — `version` is 2.0.1

Key decisions:

- both scripts matched the original inline hooks on 18 edge-case inputs, in a one-off comparison
  that is not committed
- `tests/icon.sh` was added beyond the plan, to check AC7
- "Conventions for changes" in `CLAUDE.md` gained a line on how hook scripts are written, beyond the
  plan
- the `jq` filters still contain braces and regex wildcards inside single quotes, which are not shell
  patterns; whether the validator agrees is what AC9 shows
- the final Systemic Design Checkpoint was skipped by the user
