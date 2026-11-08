# Opening GitHub Issues

How a skill turns points the user picks into GitHub issues. Nothing is opened in bulk, and nothing is
opened without the user choosing it.

The skill first shows the points, numbered, and then supplies:

- the **points**, each with its title and body
- the **label** to look for on each point, if any
- the **issues that do not count as a match**, if any

## Pick the Issues

Ask "Which of these should become GitHub issues?", as "Asking Questions" in `language.md` describes
for picking from a list.

On none, stop.

## Check for Duplicates

For each picked point, search open issues by its key terms and main symbols, leaving out the issues
that do not count as a match:

```sh
gh issue list --state open --search "<terms> in:title,body" --limit 5
```

If one looks like the same problem, show it and `AskUserQuestion`: "#<n> `<title>` looks like the
same problem." — options **Skip** / **Comment on #<n>** (posting the point's body) /
**Open a new issue anyway**.

## Open the Issues

- labels: `gh label list --search <label>`. If the repo has a matching label, such as `refactoring`
  for `refactor`, apply it; never create a label without asking
- write the body to a temporary file in the scratchpad and run
  `gh issue create --title "<title>" --body-file <file> [--label "<label>"]`
- follow `language.md`, and the PR description rules in `/aido:4-open-pr` that apply to any GitHub
  body: no hard-wrapped prose; no reference to Claude Code
