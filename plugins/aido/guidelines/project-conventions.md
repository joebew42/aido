# Project Conventions

The skills and guidelines work in any repository and any stack. Anything specific to a language,
framework, toolchain or team comes from the repository being worked on, the **host repository**.

Before planning, implementing, reviewing or committing, gather its conventions in this order:

1. **Agent instruction files**: `CLAUDE.md` and `AGENTS.md`, at the repository root and in every
   directory between the root and the files being changed. A nested file covers its own subtree.
   Claude Code loads `CLAUDE.md` itself. Read `AGENTS.md` explicitly.
2. **The repository itself**, for anything those files don't cover: `README`, `CONTRIBUTING`,
   manifests and lockfiles, linter and formatter configuration, CI configuration, and the code and
   tests next to the change. The commands CI runs are the authoritative test and lint commands.
3. **The user**, when a convention that matters still can't be found. Ask with `AskUserQuestion`.
   Never guess a command that changes state, such as a database migration.

The host repository is **authoritative on every topic it covers**. The nearest agent instruction
file wins over one higher up the tree. The global guidelines fill in the rest.

Know these before writing code, and gather them once per skill:

- how to run a single test, the tests for one file, and the whole suite
- how to lint, format and type-check
- the test framework, and where test files live and how they are named
- where each architectural layer lives (see "Architecture" in `code-standards.md`)
- the database migration tool: how to create, apply and roll back a migration, and whether a
  generated schema snapshot is committed
- code-generation steps that must run after certain changes
- any project-specific commit scopes, branch naming, PR template, labels or reviewers
- where the feature specification goes, if the repository names it (see "The Specification File" in `specification.md`)

A rule for one stack or project belongs in that repository's `CLAUDE.md` or `AGENTS.md`, never in
these guidelines.
