# License the project under MIT

GitHub Issue: https://github.com/joebew42/ai-augumented-engineer/#5

## Context

The repository has no license. Without one, nobody else may legally use, copy, modify or
redistribute the workflow, even though it is published as a Claude Code plugin marketplace meant
to be installed and adapted by others.

The issue asks which license fits such a project. The MIT License was chosen: it is short and
permissive, widely approved by companies, and common among Claude Code plugins. Anyone may use,
adapt and redistribute the skills and guidelines as long as they keep the copyright notice.

## Goals

- license the repository under the MIT License
- let plugin tooling show the `aiae` plugin's license

## Out of scope

- a License section in `README.md`
- license headers in individual files
- a `license` field in `.claude-plugin/marketplace.json`
- contribution guidelines or a CLA

## Acceptance criteria

- a `LICENSE` file at the repository root holds the standard MIT License text, with the copyright
  line `Copyright (c) 2026 Joe Bew and contributors`
- `plugins/aiae/.claude-plugin/plugin.json` has `"license": "MIT"`
- `claude plugin validate .` and `claude plugin validate ./plugins/aiae` pass

## Plan

Both changes are repository metadata, outside the delivery, application and domain layers.

1. **Add the MIT `LICENSE` file** — create `LICENSE` at the repository root with the standard MIT
   License text and the copyright line `Copyright (c) 2026 Joe Bew and contributors`
2. **Declare the license in the plugin manifest** — add `"license": "MIT"` to
   `plugins/aiae/.claude-plugin/plugin.json`, after `author`
3. **Validate** — run `claude plugin validate .` and `claude plugin validate ./plugins/aiae`; both
   must pass

The enabling refactoring analysis was skipped.

## Progress

- [x] add the MIT `LICENSE` file — the text matches GitHub's MIT template
- [x] declare `"license": "MIT"` in `plugins/aiae/.claude-plugin/plugin.json`
- [x] validate — `claude plugin validate .` and `claude plugin validate ./plugins/aiae` pass

The repository has no test suite; each step was checked with the two validate commands.
The final Systemic Design Checkpoint was skipped by the user. No deferred refactorings.
