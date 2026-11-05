# Language

Everything written for a person should be understood on first read: questions and their options,
answers, explanations, summaries and status updates in chat, specifications, PRs, issues and reports.

## How to Write

- **Use short sentences.** Give each one a single idea, and split a sentence that holds several
  conditions.
- **Use concrete words.** Say what happens, and who or what it happens to. "Saving is refused" beats
  "validation handling is applied".
- **Put the main point first.** Start with the answer, the decision or the result, then give the
  reason.
- **Keep only the detail the reader needs.** Leave out what they can't act on, such as file names,
  symbols and the steps you took, unless they asked or it is the point.

## Use Plain Words, Not Workflow Terms

Don't make the reader learn this workflow's vocabulary. When talking to the user, say what a term
means in place of the term: "a conflict with the repository", not "a significant misalignment"; "a
final design review", not a checkpoint's name.

Some words stay, because they are exact or belong to the reader:

- the project's own domain terms, and technical terms the reader already uses
- labels with an exact meaning, which skills read: `AC1`, `(manual)`, `met`, `changed`, `deferred`,
  `unchecked`, `(enabling)`, `inside-out`, `outside-in`, `in-unit`
- names of commands, files and sections, when the reader needs to find them

A rule that asks for specific or technical language, such as `pr-roadmap.md` for roadmap items, still
applies. Say the specific thing, in short sentences.

## Asking Questions

A question must make sense alone, because the dialog may be all the user can see. Name what it is
about, and say what each option does.

## Shorter Must Not Lose Meaning

Cut words, not what the reader needs. A decision still shows its consequence, a report still shows
its evidence, and an acceptance criterion stays specific and checkable.
