# Multi-Phase PRs

## Multi-Phase PR Context

When a PR is part of a multi-phase feature, the Context section should reference the main plan PR by number (e.g., `#40`) rather than an external ticket. This keeps reviewers within GitHub and gives them direct access to the full feature specification without needing access to an external tracker.

## PR Roadmap Format

Use roadmap sections in PRs that are part of a multi-phase feature.

### Item Format

- **Completed items** — include PR number reference:
  `- [x] <description> (#PR_NUMBER)`

- **Current PR** — mark with "THIS PR" instead of a number:
  `- [x] <description> (**THIS PR**)`

- **Pending items** — no PR references:
  `- [ ] <description>`

### Writing Good Roadmap Descriptions

- use specific, implementation-focused language — state what will be built or changed
- describe what the system will do, not vague outcomes
- include technical details when they clarify the phase (e.g., "API support", "keep completed tasks for 30 days")
- match language and terminology from the main feature specification

**API prefixes** — when the project exposes several APIs and a step changes one of them, prefix
the step with that API's name (e.g. `PublicAPI:`), using the names the project already uses.

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
