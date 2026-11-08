# Briefing Subagents

A subagent knows only its brief. Each skill that launches one lists what its brief holds, and points
here for the parts every brief shares.

## The Shared Brief

Add these to the skill's own bullets:

- `language.md`, from the same folder as this file, copied in full, so what the subagent returns
  follows it. The sections and labels it is asked for stay as they are, and it returns a report and
  adds no ending block
- never to edit files

## When the Model Is Unavailable

When the model the skill names, such as `fable`, is unavailable or the call is denied, run the same
brief with the session's model. Say so when the skill shows its result.
