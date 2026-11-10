# Opening GitHub Issues

How a skill turns the points the user chooses into GitHub issues. Nothing is opened in bulk, or
without the user choosing it.

The skill shows the points, numbered, then supplies:

- the **points**, each with its title and body
- the **label** to look for on each point, if any

## Pick the Issues

Ask "Which of these should become GitHub issues?", as "Asking Questions" in `language.md` describes
for picking from a list.

On none, stop.

A skill that has already asked about each point skips this step, and starts at "Check for
Duplicates" with the points the user chose.

## Check for Duplicates

For each chosen point, search open issues by its key terms and main symbols. When the points come
from a PR, the issue in its `Closes #NUMBER` never counts as a match: merging the PR closes it, and
the point with it.

```sh
gh issue list --state open --search "<terms> in:title,body" --limit 5
```

If one looks like the same problem, show it and `AskUserQuestion`: "#<n> `<title>` looks like the
same problem." — options **Skip** / **Comment on #<n>** (posting the point's body) /
**Open a new issue anyway**.

## Open the Issues

- labels: `gh label list --search <label>`. If the repo has a matching label, such as `refactoring`
  for `refactor`, apply it. Never create a label without asking
- write the body to a temporary file in the scratchpad and run
  `gh issue create --title "<title>" --body-file <file> [--label "<label>"]`
- follow `language.md` and "Writing a GitHub Body" below

## Report the Result

Report each issue opened or commented on, with its URL, and each point skipped, with the issue it
duplicates.

## Writing a GitHub Body

These rules apply to every body written for GitHub: a PR, an issue, a comment or a reply.

- no reference to Claude Code
- don't hard-wrap prose. GitHub shows a single newline as a line break, so fixed-width wrapping makes
  the text choppy. Write one line per paragraph. Code blocks and lists are exempt
