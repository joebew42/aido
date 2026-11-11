# Give the draft specification a `.md` extension

> Working specification for this branch. Remove it before merging: revert the `docs: feature specification` commit.

GitHub Issue: https://github.com/joebew42/aido/#101

## Context

The skills refine a draft specification in `SPEC.md.draft` before it becomes `SPEC.md`. Because the
name ends in `.draft`, editors don't recognise it as Markdown, so users switch the language mode by
hand each time they open it.

## Intent

The draft is named after its spec file with `.draft` before its last extension, such as `SPEC.draft.md`,
so editors open it as Markdown. Every skill, guideline and the README use the new name. A draft left
under the old name by an earlier version of aido is renamed, so no work is lost.

## Out of scope

- renaming the spec file itself
- changing what the draft holds, how it is refined, or that it is never committed
- users' own `.gitignore` entries for the old name

## Acceptance criteria

Naming

- AC1: When a skill writes the draft of `SPEC.md`, it writes `SPEC.draft.md`.
- AC2: When the spec file is `FEATURE-SPEC.md`, its draft is `FEATURE-SPEC.draft.md`.
- AC3: When the spec file is `feature.spec.md`, its draft is `feature.spec.draft.md`. With no extension, `.draft` is added at the end.

Drafts under the old name

- AC4: When only the old-named draft exists, such as `SPEC.md.draft`, the skill renames it, tells the user, then acts as with a new-named draft.
- AC5: When both the old-named and the new-named draft exist, the skill keeps both, uses the new one, and tells the user.
- AC6: When an old-named draft sits next to its spec file, it is deleted, as a new-named draft would be.

Documentation

- AC7: The skills, guidelines and README name the draft by its new name, and mention the old name only where they handle it.

Before the pull request

- AC8: When `/aido:3-organize-commits` checks that no draft is left in the working tree, it looks for both names.

## Plan

1. **name the draft and handle old-named drafts, in "The Specification File"** (AC1, AC2, AC3, AC4,
   AC5, AC6) — inside-out: follows the naming sentence and "Never keep a draft next to its spec file"
   in `plugins/aido/guidelines/specification.md`. Touches the guidelines
   - the naming sentence puts `.draft` before the last extension, or at the end when there is none
   - renaming, keeping both and deleting an old-named draft happen while the names are resolved, so
     every skill that resolves the draft gets them without a step of its own
   - `tests/skills.sh` checks the new lines word for word
2. **use `SPEC.draft.md` in the skills, `refining-a-draft.md` and the README** (AC1, AC7) —
   inside-out: follows the stand-in convention ("Skills write `SPEC.md` and …") in `specification.md`.
   Touches the skills, guidelines and README
   - replace every `SPEC.md.draft`, including the `mv` commands, the questions and the `deliberate`
     description
   - reword `deliberate`'s "writes only" line, so renaming an old draft isn't ruled out
   - update the lines `tests/skills.sh` checks, and add a check that only `specification.md` names
     the old draft name
3. **look for both draft names before the pull request** (AC8) — inside-out: follows the "no draft is
   left in the working tree" checklist line in `plugins/aido/skills/3-organize-commits/SKILL.md`.
   Touches the skills
4. **bump the plugin version to 6.1.0** — old drafts are renamed, so no user loses work: a minor
   change. Touches `plugins/aido/.claude-plugin/plugin.json`

The PR shows the draft name before and after, and says AC4 to AC6 have no eval case.

## Design notes

- **Where it belongs:** "The Specification File" in `plugins/aido/guidelines/specification.md`. It
  defines the draft's name, the stand-in `SPEC.md.draft`, and deleting a draft next to its spec file.
  The old-name handling goes there too, as part of resolving the names
- **Existing behaviour and abstractions to reuse:** the "Resolve `SPEC.md` and `SPEC.md.draft`
  first" line every draft-handling skill opens with; `1-plan` Step 1 "only `SPEC.md.draft` exists",
  which a renamed draft flows into unchanged; "Never keep a draft next to its spec file", which AC6
  extends
- **Boundaries that must hold:** `/aido:verify` resolves only the spec file and changes nothing, so
  it never renames a draft. The draft is never committed. Lines `tests/skills.sh` checks change with
  their skills
- **Other modules or consumers affected:** `plugins/aido/skills/{1-plan,2-implement,3-organize-commits,4-open-pr,5-handle-review,deliberate,multi-phase-plan,stabilize}/SKILL.md`;
  `plugins/aido/guidelines/refining-a-draft.md`; `README.md`; `tests/skills.sh` (lines 111, 112,
  220, 221, 251)
- **Enabling refactorings (planned):** none
- **Deferred:** none
- **Open questions:** none

## Progress

- [x] 1. name the draft and handle old-named drafts, in "The Specification File"
  - the naming sentence, with `SPEC.md`, `FEATURE-SPEC.md` and `feature.spec.md` as examples
  - "A Draft Under the Old Name": delete next to the spec file, rename when alone, keep both when both
    exist; a skill that changes no files renames nothing
  - the stand-in `SPEC.draft.md` changed here too, since it is part of the name's definition
- [x] 2. use `SPEC.draft.md` in the skills, `refining-a-draft.md` and the README
  - every `SPEC.md.draft` replaced; `deliberate` now allows renaming or deleting a draft
  - `tests/skills.sh` checks the new lines, and that only `specification.md` names the old name
- [x] 3. look for both draft names before the pull request
  - the old-name check now also allows `3-organize-commits`, which handles that name
- [x] 4. bump the plugin version to 6.1.0

The final design review was skipped.

### Acceptance

- AC1: met — `tests/skills.sh`: `specification.md` keeps "`SPEC.draft.md` for `SPEC.md`, …"
- AC2: met — `tests/skills.sh`: the same line names `FEATURE-SPEC.draft.md` for `FEATURE-SPEC.md`
- AC3: met — `tests/skills.sh`: the same line names `feature.spec.draft.md`, and "A spec file with no
  extension gets `.draft` at the end"
- AC4: met — `tests/skills.sh`: "**only the old name exists** → rename it …" (instruction text only,
  no eval case)
- AC5: met — `tests/skills.sh`: "**both names exist** → keep both …" (instruction text only, no eval
  case)
- AC6: met — `tests/skills.sh`: "**the spec file exists** → delete the draft under either name …"
  (instruction text only, no eval case)
- AC7: met — `tests/skills.sh`: "only specification.md and 3-organize-commits name the draft's old name"
- AC8: met — `tests/skills.sh`: `3-organize-commits` keeps "no draft is left in the working tree,
  under either name"
