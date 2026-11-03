# Keep skills and guidelines free of third-party references

## Context

The "Conventions for changes" section of `CLAUDE.md` says that skills and guidelines stay
stack-agnostic and free of company references. It does not mention third-party projects, so a
reference to one is not ruled out.

Taken literally, a wider rule would also catch GitHub and `gh`, which the workflow depends on and
which appear in 10 skill and guideline files.

## Intent

The convention rules out references to both third-party companies and third-party projects, except
for the tools the workflow depends on, such as GitHub.

## Out of scope

- changing any existing reference in the skills and guidelines: `PostgresqlTaskRepository` and
  PostgreSQL in the TODO app examples (`code-standards.md`, `testing-principles.md`,
  `git-workflow.md`) become out of line with the convention, and cleaning them up is separate work
- any other convention in `CLAUDE.md`

## Acceptance criteria

- AC1: the convention in `CLAUDE.md` says skills and guidelines stay free of references to
  third-party companies or projects
- AC2: the convention names the exception for the tools the workflow depends on, with GitHub as the
  example
- AC3: the convention still says skills and guidelines stay stack-agnostic and that examples use a
  TODO app
- AC4: no file under `plugins/aido/` changes, so the plugin's `version` is not bumped
- AC5: `claude plugin validate .` and `claude plugin validate ./plugins/aido` both pass

## Plan

1. **docs — reword the convention in `CLAUDE.md`** (AC1, AC2, AC3, AC4)

   ```markdown
   - skills and guidelines stay stack-agnostic and free of references to third-party companies or
     projects, except the tools the workflow depends on, such as GitHub; examples use a TODO app
   ```

2. **docs — run both marketplace validations** (AC5)

The enabling refactoring analysis was skipped.

## Progress

- [x] docs — reword the convention in `CLAUDE.md`
- [x] docs — run both marketplace validations

Acceptance criteria:

- AC1: met — the reworded line in `CLAUDE.md`, read in the diff; no automated test, as a test pinning this wording would add nothing
- AC2: met — the same line, read in the diff
- AC3: met — the same line, read in the diff
- AC4: met — `git status --short plugins/aido` lists nothing, and `version` is not bumped
- AC5: met — `claude plugin validate .` and `claude plugin validate ./plugins/aido` both pass

Key decisions: no test was added under `tests/`, which only covers the hook scripts.

Deferred refactorings: none. The PostgreSQL references remain out of scope, as the specification says.

The final Systemic Design Checkpoint was skipped by the user.
