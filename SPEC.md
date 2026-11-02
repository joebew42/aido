# Include "aido" in the plugin's display name

## Context

The plugin's `name` is already `aido`, but the name people read is its `displayName`, which is
`AI-Augmented Engineering`. That name does not mention "aido", the name used to install the plugin
and invoke its skills.

## Intent

The plugin's display name includes "aido" and still says what the plugin serves:
`aido: AI-Augmented Engineering`. "aido" comes first, as in `/aido:<skill>`, and the wording is that
of the README's heading "Why aido: AI-Augmented Engineering".

## Out of scope

- the plugin's and the marketplace's `name`, so the install command and `/aido:<skill>` stay as they
  are
- the README, where "AI-Augmented Engineering" names the practice, not the plugin
- the skills and guidelines

## Acceptance criteria

- AC1: `displayName` in `plugins/aido/.claude-plugin/plugin.json` is exactly
  `aido: AI-Augmented Engineering`
- AC2: `name` in `plugins/aido/.claude-plugin/plugin.json` is still `aido`, and
  `.claude-plugin/marketplace.json` is unchanged
- AC3: `version` in `plugins/aido/.claude-plugin/plugin.json` is `2.0.2`
- AC4: `claude plugin validate .` and `claude plugin validate ./plugins/aido` both pass

## Plan

1. **manifest — rename the display name and bump the version** (AC1, AC2, AC3, AC4): in
   `plugins/aido/.claude-plugin/plugin.json`, set `displayName` to `aido: AI-Augmented Engineering`
   and `version` to `2.0.2`, a patch because nothing changes in how the plugin is used; then run both
   validators

The enabling refactoring analysis was skipped.

## Progress

- [x] 1. manifest — rename the display name and bump the version

- AC1: met — a throwaway check read `displayName` from `plugin.json`: `aido: AI-Augmented Engineering`
- AC2: met — the same check read `name`: `aido`, and `git diff main` shows no change to `marketplace.json`
- AC3: met — the same check read `version`: `2.0.2`
- AC4: met — `claude plugin validate .` and `claude plugin validate ./plugins/aido` both passed

Decisions: no test was committed, because a test pinning the display name and version would fail on
every version bump, and `tests/` covers only the hook scripts. The check failed on AC1 and AC3 before
the change and passed after it.

The final Systemic Design Checkpoint was skipped by the user.
