# Leave Claude's memory to the user

GitHub Issue: https://github.com/joebew42/aido/issues/83

## Context

The plugin blocks every write to Claude's memory, through a hook with a `git config` opt-out. The
guidelines forbid auto-memory, and the README asks users to turn it off. Feedback says restrictions
like this put people off adopting the workflow. Whether to use memory is a setting for the user's own
configuration.

## Intent

The plugin no longer blocks, forbids or discourages Claude's memory. Users decide in their own
settings. A convention found in a review is still proposed for the host repository's `CLAUDE.md` or
`AGENTS.md`.

## Out of scope

- the hook that blocks AI attribution in commit messages, its opt-out and the README's attribution
  advice stay as they are
- the plugin doesn't turn memory on or recommend it

## Acceptance criteria

- AC1: When an agent writes to Claude's memory directory, no plugin hook denies it.
- AC2: No guideline or skill forbids or mentions auto-memory, or the `aido.allowMemoryWrites` opt-out.
- AC3 (manual): The README neither recommends turning auto-memory off nor lists a memory hook or its
  opt-out.
- AC4: The free checks pass with no memory hook left to test.
- AC5: Reviews still propose new conventions for the host repository's `CLAUDE.md` or `AGENTS.md`.

## Plan

1. **remove the memory hook** (AC1, AC4) — inside-out: a deletion that leaves the remaining hooks
   and their checks in `tests/hooks.sh` as they are. Touches infrastructure
   - delete `plugins/aido/hooks/deny-memory-writes.sh`
   - remove the whole `Write|Edit|MultiEdit` group from `hooks.json`, so no empty hook runs on writes
   - remove every memory check from `tests/hooks.sh`, including "an opt-out covers only its own
     hook": one opt-out is left, so there is nothing to cross
2. **stop forbidding memory in the guidelines** (AC2, AC5) — inside-out: removes one paragraph from
   `evolving-guidelines.md` and keeps its process for `CLAUDE.md` and `AGENTS.md`. Touches domain
   - drop the "Don't use auto-memory for this" paragraph
   - `git-workflow.md`: the opt-out rule names only `aido.allowCommitAttribution`, in the singular
3. **leave memory to the user in the README** (AC3) — inside-out: follows the README's current hook
   table and settings section. Touches documentation
   - the settings advice keeps only attribution, without `autoMemoryEnabled`
   - drop the memory row of the hooks table, and make the opt-out sentence singular
   - bump the plugin version to 5.8.0

## Design notes

- **Where it belongs:** the hooks (`plugins/aido/hooks/`, `tests/hooks.sh`), one paragraph in
  `evolving-guidelines.md`, one rule in `git-workflow.md`, and the README. Nothing moves, and nothing
  new is written.
- **Existing behaviour and abstractions to reuse:** `tests/hooks.sh` — `check`,
  `in_repo_with_config`, `check_command_is_a_plugin_script`, `check_script_is_followable`,
  `output_with_only_grep_on_path` all keep other users, and keep their shape. `tests/skills.sh` — the
  check that only `5-handle-review` loads `evolving-guidelines.md` keeps covering AC5.
- **Boundaries that must hold:** the commit attribution hook, its opt-out and the README attribution
  advice stay. `deny-commit-attribution.sh`, `ask-before-push.sh` and `remind-after-compaction.sh`
  are not edited. `claude plugin validate` must pass on the smaller `hooks.json`.
- **Other modules or consumers affected:** no skill, eval case or eval doc mentions memory. The
  architecture map still lists the memory hook after this change, until it is next refreshed.
- **Enabling refactorings (planned):** none.
- **Deferred:** none.
- **Open questions:** none. No eval case covers the hooks or the memory paragraph, so the PR says
  this change isn't covered by an eval.

## Refactorings

### r1. skip the ignored eval results in the `sed -i` check

- **Change:** add `--exclude-dir=results` to the grep behind "tests and eval fixtures edit files in
  place with perl -pi", as the old five-field check already does.
- **Why:** the check also scans the gitignored local eval traces. A trace holding `sed -i` fails the
  free checks locally, while a clean checkout passes. The two greps skip local traces differently.
- **Where:** `tests/skills.sh` — the `sed -i` check
  `tests/skills.sh` — the `old_format` grep, the shape to follow
- **Confidence:** high
- **Risk:** none for the plugin. Only local traces stop failing the check.

## Progress

- [x] 1. remove the memory hook
  - deleted `deny-memory-writes.sh` and its `Write|Edit|MultiEdit` group in `hooks.json`
  - removed its checks from `tests/hooks.sh`, and added one that no hook runs on writes
- [x] 2. stop forbidding memory in the guidelines
  - dropped the auto-memory paragraph from `evolving-guidelines.md`
  - `git-workflow.md` names only `aido.allowCommitAttribution` as the user's opt-out
  - `tests/skills.sh` checks that no skill or guideline mentions auto-memory or its opt-out
- [x] 3. leave memory to the user in the README
  - the settings advice keeps only attribution; the hooks table drops the memory row; the opt-out
    sentence is singular
  - plugin version bumped to 5.8.0
- Decision: the design note "nothing new is written" no longer holds. Two checks were added, one
  per acceptance criterion: no hook runs on writes (`tests/hooks.sh`), and no skill or guideline
  mentions auto-memory or its opt-out (`tests/skills.sh`)
- the final design review ran and recorded r1
- [x] r1. skip the ignored eval results in the `sed -i` check
  - the check passes with local eval traces present, and still fails on `sed -i` in a file outside
    `results/`

### Acceptance

- AC1: met — `no hook runs on writes, so memory is left to the user` in `tests/hooks.sh`
- AC2: met — `skills and guidelines leave Claude's memory to the user` in `tests/skills.sh`
- AC3: met — confirmed by the user: the README's settings advice, hooks table and opt-out sentence
- AC4: met — `tests/all.sh` passes on a clean checkout of the branch
- AC5: met — `5-handle-review suggests conventions` in `tests/skills.sh`, and `evolving-guidelines.md`
  still names `CLAUDE.md` and `AGENTS.md` as its only targets
