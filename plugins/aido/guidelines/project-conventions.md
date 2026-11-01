# Project Conventions

This workflow is a set of globally available skills, not tied to any repository. The skills and
guidelines are deliberately stack-agnostic: anything specific to a language, framework, toolchain
or team comes from the repository being worked on (the **host repository**).

Before planning, implementing, reviewing or committing, gather the host repository's conventions
in this order:

1. **Agent instruction files** in the repository the skill is operating in — `CLAUDE.md` and
   `AGENTS.md`. Look at the repository root and in every directory between the root and the files
   being changed; a nested file covers its own subtree. Claude Code loads `CLAUDE.md`
   automatically; read `AGENTS.md` explicitly.
2. **The repository itself**, for anything those files don't cover — `README`, `CONTRIBUTING`,
   manifests and lockfiles, linter and formatter configuration, CI configuration (the commands the
   pipeline runs are the authoritative test and lint commands), and the existing code and tests
   next to the change.
3. **The user** — when a convention still can't be determined and it matters, ask with
   `AskUserQuestion`. Never guess a command that changes state, such as a database migration.

The host repository is **authoritative on every topic it covers**; the nearest agent instruction
file wins over one higher up the tree; the global guidelines fill in whatever is left.

Know these before writing code, and load them once per skill rather than re-discovering them:

- how to run a single test, the tests for one file, and the whole suite
- how to lint, format and type-check
- the test framework, and where test files live and how they are named
- where each architectural layer lives (see "Architecture" in `code-standards.md`)
- the database migration tool: how to create, apply and roll back a migration, and whether a
  generated schema snapshot is committed
- code-generation steps that must run after certain changes
- any project-specific commit scopes, branch naming, PR template, labels or reviewers
- where the feature specification goes, if the repository names it (see "The Specification File" in `specification.md`)

A new rule that only applies to one stack or project belongs in that repository's `CLAUDE.md` or
`AGENTS.md`, never in these global guidelines.
