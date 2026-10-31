# README.md: the Install section should name this repository

GitHub Issue: https://github.com/joebew42/ai-augumented-engineer/#1

## Context

The Install section of `README.md` tells people to run
`/plugin marketplace add <owner>/<repo>`. The generic placeholder makes them work out and type the
repository themselves instead of copying and pasting the command.

## Goals

- the Install section names this repository, `joebew42/ai-augumented-engineer`, so both install
  commands can be copied and pasted as they are

## Out of scope

- the `<owner>/<repo>` placeholders in `plugins/aiae/skills/pr-review/SKILL.md` — there they stand
  for whichever repository is under review, and must stay generic
- any other change to `README.md`

## Acceptance criteria

- the Install section of `README.md` reads `/plugin marketplace add joebew42/ai-augumented-engineer`
- `README.md` no longer contains `<owner>/<repo>`
- the second install command, `/plugin install aiae@ai-augumented-engineer`, is unchanged

## Plan

This change is documentation only, so no architectural layer applies.

1. `docs:` in `README.md` (`## Install`, line 32), replace
   `/plugin marketplace add <owner>/<repo>` with
   `/plugin marketplace add joebew42/ai-augumented-engineer`, keeping the `augumented` spelling of
   the real repository
2. Check: `grep -n '<owner>/<repo>' README.md` finds nothing, and line 33 is unchanged
3. Run `claude plugin validate .` and `claude plugin validate ./plugins/aiae`

## Design notes

- **Where it belongs:** `README.md:32`, the only place that states the install command;
  `CLAUDE.md` points to `README.md` for installation instead of repeating it
- **Existing behaviour and abstractions to reuse:** none; the marketplace name in
  `.claude-plugin/marketplace.json` (`"name": "ai-augumented-engineer"`) is a different fact from
  the GitHub slug, even though the two share a string
- **Boundaries that must hold:** `README.md:33` (`/plugin install aiae@ai-augumented-engineer`)
  stays as it is; `plugins/aiae/skills/pr-review/SKILL.md` keeps its generic `<owner>/<repo>`
  in the `gh api` paths
- **Other modules or consumers affected:** none; neither `marketplace.json` nor
  `plugins/aiae/.claude-plugin/plugin.json` carries a repository URL
- **Enabling refactorings (planned):** none
- **Deferred:** none
- **Open questions:** none

## Progress

- [x] `docs:` README.md install section names `joebew42/ai-augumented-engineer`
- [x] grep check: no `<owner>/<repo>` left in README.md, line 33 unchanged
- [x] `claude plugin validate .` and `claude plugin validate ./plugins/aiae` pass; their existing
      warnings (no version, LICENSE or icon) were already there and are out of scope
- Final systemic design check: nothing found, Design notes still hold
- **Deferred refactorings:** none
