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
  `unchecked`, `(enabling)`, `r1`, `inside-out`, `outside-in`, `in-unit`, and the ending block's
  `Done`, `Decided` and `Needs you`
- names of commands, files and sections, when the reader needs to find them

A rule that asks for specific or technical language, such as `pr-roadmap.md` for roadmap items, still
applies. Say the specific thing, in short sentences.

## Asking Questions

A question must make sense alone, because the dialog may be all the user can see. Name what it is
about, and say what each option does.

**An approval also settles the choice that follows it.** Ask both in the same `AskUserQuestion` call,
so the user is interrupted once per stage. The second answer counts only on approval.

## Showing What Changed

When a skill asks the user to approve a document they have already seen, such as a draft, a
specification, a plan or a proposal, show a short plain-language list of what changed since the user
last saw it: "Added AC4: an empty title is refused". Leave out what did not change, because the full
file is on disk. The first time a document is shown, show it whole. When the user asks to see the
whole document, show it whole.

## Interaction Style

- when a question is ambiguous or several approaches are valid, present the options with
  `AskUserQuestion` instead of picking silently
- whenever a skill asks the user to choose between discrete options (yes/no, A/B, "pick one of
  these branches"), use `AskUserQuestion`; keep free-text prompts for genuinely open-ended input —
  IDs, names, links, custom messages, multi-line specifications

## Ending a Skill

When a skill ends, including when it stops early, end the last message with a short block labelled
`Done`, `Decided` and `Needs you`, so the user knows where to look:

```
Done: the plan for sharing a list is committed on `feat-share-lists`.
Decided: a shared list is read-only for now.
Needs you: nothing.
```

- `Done` is what the skill did, `Decided` the choices made along the way, and `Needs you` what the
  user has to do or decide next, such as a command to run
- keep each to a line or two. Leave out `Done` or `Decided` when it has nothing to say. `Needs you`
  always stays, and reads "nothing" when nothing needs the user
- the block comes last in the message. When the skill starts the next skill in this session, show the
  block before starting it
- When the result is a report, show the report unchanged, and let the block list only what needs the
  user, without repeating the report
- A skill that another skill started, and that returns to it, adds no block. The skill that started
  it ends with one

## Shorter Must Not Lose Meaning

Cut words, not what the reader needs. A decision still shows its consequence, a report still shows
its evidence, and an acceptance criterion stays specific and checkable.
