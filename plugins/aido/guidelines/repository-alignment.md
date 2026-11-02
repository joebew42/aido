# Repository Alignment

A specification can be clear and complete and still conflict with the repository it is meant for.
The **alignment check** compares the two, and stops the workflow when the conflict is serious. The
skill that runs the check says when it runs; this guideline says how.

## What the Check Looks At

Compare the specification with the host repository's:

- architecture and design principles
- conventions and patterns
- existing behaviour and domain assumptions
- constraints and dependencies
- existing functionality it could conflict with

Read the host repository's conventions as `project-conventions.md` describes, and the code the
specification touches. Widen only when a conflict points somewhere wider. Every conflict names the
files it rests on, checked against the current code; what only looks inconsistent is not a conflict.

A conflict already listed under `## Alignment decisions` in the specification has been decided: do
not raise it again.

## What Counts as Significant

A misalignment is **significant** when the specification:

- contradicts the repository's agent instruction files (see `project-conventions.md`)
- crosses an architectural boundary (see "The Dependency Rule" in `code-standards.md`, or a boundary
  the repository states itself)
- changes behaviour other code relies on

A specification that does one of these on purpose is still significant: intentional architectural
changes and refactorings are possible, but they need an informed decision.

Any lesser mismatch is ordinary refinement. Fix it, or ask about it like any other question, and do
not stop the workflow for it.

## When It Is Significant

The default is to reject the specification as it stands, and nothing moves forward without an
explicit choice:

1. explain each conflict and its implications, citing the files that show it
2. recommend rejecting or revising the specification
3. ask with `AskUserQuestion`: "This specification conflicts with the repository. How should we
   continue?" — options:
   - **Revise the specification (Recommended)** — agree the change with the user, update the
     specification, and check again what changed
   - **Reject it** — stop here, leaving the specification as it is
   - **Proceed anyway** — ask for the reason, then record the decision as "Alignment Decisions" in
     `specification.md` describes, and continue
