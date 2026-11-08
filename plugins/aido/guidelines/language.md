# Language

Write so a person understands it on first read. This covers everything a person reads: questions and
their options, answers, summaries and status updates in chat, specifications, PRs, issues and
reports.

## How to Write

- **Say what happened, then the result.** Start with the answer, the decision or the outcome.
- **Give a reason only when it isn't obvious or the user asks.** Don't explain what the reader can
  already see.
- **Use short sentences.** One idea each. Split a sentence that holds several conditions.
- **Use concrete words.** Say what happens, and to whom. "Saving is refused" beats "validation
  handling is applied".
- **Keep only what the reader needs.** Leave out what they can't act on, such as file names, symbols
  and the steps you took, unless they asked or it is the point.

## Examples

Each pair says the same thing, first wordy, then plain.

### In Chat

Before: "I've gone ahead and completed the implementation of the due date validation. After carefully
reviewing the existing code, I decided to add the check to the `Task` entity, since that's where the
other invariants live, which seemed like the most consistent approach."

After: "Tasks now refuse a due date in the past. The tests pass."

### In a Specification

Before: "AC3: When the user attempts to perform a save operation on a task where the title field has
been left empty or contains only whitespace characters, the system should appropriately handle this
by refusing to persist it."

After: "AC3: When a task's title is blank, saving it is refused."

### In a PR

Before: "This PR introduces a number of changes aimed at improving the overall experience around
sharing lists. Specifically, it adds the ability for list owners to share their lists with other
users, which was requested in the linked issue."

After: "List owners can share a list with other users. A shared list is read-only for them."

### In an Issue

Before: "While working on something else, I noticed that there might potentially be an issue where,
under certain circumstances, completing a task that has already been completed could lead to
unexpected behaviour."

After: "Completing a task twice moves its completion date. It should keep the first date."

## Use Plain Words, Not Workflow Terms

Don't make the reader learn this workflow's words. Say what a term means instead: "a conflict with
the repository", not "a significant misalignment".

These words stay, because they are exact or belong to the reader:

- the project's own domain terms, and technical terms the reader already uses
- labels skills read: `AC1`, `(manual)`, `met`, `changed`, `deferred`, `unchecked`,
  `(enabling)`, `r1`, `inside-out`, `outside-in`, `in-unit`, and the ending block's `Done`,
  `Decided` and `Needs you`
- names of commands, files and sections, when the reader needs to find them

A rule that asks for specific or technical words, such as `pr-roadmap.md` for roadmap items, still
applies. Say the specific thing, in short sentences.

## Asking Questions

- whenever the user chooses between set options (yes/no, A/B, "pick one of these branches"), use
  `AskUserQuestion`. Keep free text for open input: IDs, names, links, custom messages, a
  specification
- when a question is ambiguous or several approaches are valid, offer them with `AskUserQuestion`
  instead of picking one silently
- a question must make sense alone, because the dialog may be all the user can see. Name what it is
  about, and say what each option does

**An approval also settles the choice that follows it.** Ask both in the same `AskUserQuestion` call,
so the user is interrupted once per stage. The second answer counts only on approval.

**Picking from a list.** When the user picks items from a numbered list, ask one `AskUserQuestion`:

- **4 items or fewer** → multi-select, one option per title
- **more than 4** → options **All** / **None** / **By number** (the user types the numbers)

## Showing What Changed

When a skill asks the user to approve a document they have already seen, such as a draft, a
specification, a plan or a proposal, show a short plain-language list of what changed since the user
last saw it: "Added AC4: an empty title is refused". Leave out what did not change: the full file is
on disk. The first time a document is shown, show it whole. When the user asks to see the whole
document, show it whole.

## Ending a Skill

When a skill ends, including when it stops early, end the last message with a short block labelled
`Done`, `Decided` and `Needs you`, so the user knows where to look:

```
Done: the plan for sharing a list is committed on `feat-share-lists`.
Decided: a shared list is read-only for now.
Needs you: nothing.
```

- `Done` is what the skill did. `Decided` is the choices made along the way. `Needs you` is what the
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

Cut words, not what the reader needs. A decision still shows its consequence. A report still shows
its evidence. An acceptance criterion stays specific and checkable.
