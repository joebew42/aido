# Multi-Phase PRs

## Multi-Phase PR Context

In a PR that is part of a multi-phase feature, the Context section refers to the main plan PR by
number (e.g. `#40`), not to an external ticket. Reviewers stay in GitHub, one click from the full
feature specification.

## PR Roadmap Format

A PR that is part of a multi-phase feature has a roadmap section.

### Item Format

- **Completed items** — include PR number reference:
  `- [x] <description> (#PR_NUMBER)`

- **Current PR** — mark with "THIS PR" instead of a number:
  `- [x] <description> (**THIS PR**)`

- **Pending items** — no PR references:
  `- [ ] <description>`

### Writing Good Roadmap Descriptions

- say what will be built or changed, in specific words
- describe what the system will do, not a vague outcome
- add technical details when they clarify the phase (e.g. "API support", "keep completed tasks for 30
  days")
- use the words of the main feature specification

**API prefixes** — when the project exposes several APIs and a step changes one, prefix the step
with that API's name as the project already calls it (e.g. `PublicAPI:`).

### Example

```markdown
## Roadmap

- [x] PublicAPI: Add due date and priority fields to the Task type (#12345)
- [x] Keep completed tasks for 30 days instead of deleting them (**THIS PR**)
- [ ] Add API support for filtering tasks by completion state
- [ ] Hide completed tasks from the default TODO list
```

### Common Mistakes

```markdown
- [ ] Let collaborators edit shared lists (#43)  ← Wrong: no PR references on pending items
- [x] Update reminders (**THIS PR**)             ← Too vague: update what about reminders?
- [ ] Add API support                            ← Too vague: support for what?
```
