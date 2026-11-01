# Show starting from a conversation in the README screenshot of /aiae:1-plan

## Context

The README shows a screenshot of `/aiae:1-plan` asking where the specification comes from. The
previous PR (#11) added a third answer, starting from a conversation. The README's text already
describes it, but the screenshot still shows only a GitHub issue and writing the draft yourself.

## Intent

The screenshot in the README shows the prompt as it is today, including the option to start from a
conversation, and its alt text describes what the new screenshot shows.

## Out of scope

- changing the README's text other than the image's alt text
- changing the other images in `docs/`
- changing the plugin, so `version` in `plugins/aiae/.claude-plugin/plugin.json` is not bumped

## Acceptance criteria

- AC1: `docs/plan-asks-for-the-spec.png` is identical to the new screenshot
- AC2: the alt text of that image in `README.md` names all three answers: a GitHub issue, a draft
  you write yourself, and a conversation
- AC3: that alt text no longer mentions syncing with `main` or finding no `SPEC.md`, which the new
  screenshot does not show
- AC4 (manual): the README, once rendered, shows the new screenshot in its place below the paragraph
  about `/aiae:1-plan`

## Plan

1. **docs — replace the screenshot** (AC1, AC4): overwrite `docs/plan-asks-for-the-spec.png` with
   `/tmp/claude-1000/-home-joe-workspace-ai-augmented-engineer/f21356af-ac14-402b-85ff-7fbc888a8257/images/1.png`,
   keeping the file name so the README's link still works
2. **docs — update the alt text** (AC2, AC3): rewrite the alt text at `README.md:73` to describe the
   new screenshot, then run `claude plugin validate .` and `claude plugin validate ./plugins/aiae`

The enabling refactoring analysis was skipped.

## Progress

- [x] docs — replace the screenshot
- [x] docs — update the alt text

- AC1: met — one-off check: `cmp` of the new screenshot and `docs/plan-asks-for-the-spec.png` found no difference
- AC2: met — one-off check: `grep` found all three answers in the alt text at `README.md:73`
- AC3: met — one-off check: `grep` found neither phrase in that alt text
- AC4: met — confirmed by the user: the new image and its place in `README.md`

Decisions: the repository has no test suite, so the automatable criteria were checked with one-off
shell checks that failed before the change and passed after it; no test was committed.

Deferred refactorings: none.

The user skipped the final Systemic Design Checkpoint.
