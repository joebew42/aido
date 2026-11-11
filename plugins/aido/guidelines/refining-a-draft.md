# Refining a Draft

Refining turns an approved draft into a specification ready for the user's approval. Work on
`SPEC.draft.md`, through these steps in order.

## Load the context

1. Load the host repository's conventions as `project-conventions.md` describes
2. If the feature also touches another repository, such as a shared API, models, events or schema,
   read its `CLAUDE.md` and `AGENTS.md` too, when it is available locally
3. Read the code the draft touches, enough to check the draft against it

## Analyse, refine and reword

Go through the draft and fix what you find, in `SPEC.draft.md` itself:

- **gaps** — missing behaviour, edge cases, error cases or acceptance criteria
- **ambiguity** — statements two readers could build differently
- **contradictions** — within the draft, or with how the code works today. A conflict with the
  repository, as "What Counts as Significant" in `repository-alignment.md` defines it, goes to
  "Check the alignment with the repository" below. A lesser one is fixed here
- **scope** — what is in, and what is out
- **wording** — follows `language.md`, in the project's own words (see "don't invent domain
  vocabulary" in `code-standards.md`). Acceptance criteria can be tested

**Ask, don't guess.** When a decision belongs to the user, such as a behaviour the draft leaves open,
a scope choice or a conflict between the draft and the code, ask with `AskUserQuestion`, with the
likely answers as options. Group related questions in one call. Use free text only for open input.

## Rewrite it into the specification structure

The refined draft follows "The Specification Structure" in `specification.md`: Context, Intent, Out
of scope and Acceptance criteria, in that order. It says what and why. How belongs in `## Plan`,
written once the specification is approved.

- move the draft's content into the matching section, in the user's words where they work
- a `## Design decision` stays unchanged, in its place after the acceptance criteria and any
  `## Alignment decisions`. Never ask whether to move or drop it. The user approved it with
  `/aido:deliberate`
- lines and sections a skill wrote after the title, such as the original work, stay unchanged and in
  place, and are never asked about. "The Specification Structure" allows them
- when part of the draft fits no section, such as a design idea, a task list or a question, ask with
  `AskUserQuestion` whether to move it to the plan, turn it into an acceptance criterion, or drop it
- **acceptance criteria are required.** When the draft has none, or they leave part of the Intent
  unchecked, propose them from the Intent and the code you read
- write them as "Acceptance Criteria" in that same guideline describes
- show the proposed criteria, and ask about any you are unsure of. The user approves the list with
  the specification

## Check the alignment with the repository

Run the alignment check on the rewritten draft, as `repository-alignment.md` describes, with the
context already loaded. When it finds a conflict with the repository, ask as "When It Is Significant"
in `repository-alignment.md` describes, with the draft as the specification. Don't ask for the
specification's approval until this is settled.
