# Rename the project to aido and make the README more appealing

## Context

Every command in this workflow starts with the plugin's name, so people see and type it constantly.
Today that name is `aiae`: an acronym people have to be told about, hard to say, and easy to
mistype. The project goes by a second, longer name, `ai-augmented-engineer`, so people meet two
names for one thing.

The README undersells the workflow in a similar way. It opens by describing packaging ("a plugin
marketplace with one plugin") rather than what you get. Install only comes after the concepts, and
Quick start after the full skill reference, while reference material gets the same weight as the
core workflow.

## Intent

- the project has one name that is easy to remember and to write: `aido`, as in "AI do", used for
  the plugin, the marketplace, the GitHub repository and the local folder, so `/aiae:1-plan` becomes
  `/aido:1-plan`
- people still learn that `aido` serves AI-Augmented Engineering, and the name's echo of `sudo`
  helps them remember it
- a newcomer reading the README quickly sees what the workflow gives them, what its stages are, and
  how to start
- "AI do" alone stresses the agent, so the README makes clear that the engineer still decides

## Out of scope

- keeping `/aiae:<skill>` working through an alias or a compatibility shim, or explaining how to
  upgrade: the repository is private and its only install is the author's own
- changing what any skill or guideline does
- new visuals, or redrawing the existing diagrams beyond the command names they show
- rewriting the README's text in a new voice: it is reordered and sharpened, and most of the text
  stays
- changing the GitHub repository description, or rewriting git history

## Acceptance criteria

The rename

- AC1: the plugin manifest and its marketplace entry are both named `aido`, and the marketplace
  entry's source is `./plugins/aido`
- AC2: the plugin directory is `plugins/aido/`, and `plugins/aiae/` no longer exists
- AC3: `aiae` appears, in any letter case, only in this specification file: nowhere else in a
  tracked file's content, and in no tracked file's path
- AC4: every `/aido:<name>` reference in the repository names a skill that exists in
  `plugins/aido/skills/`, leaving aside the `/aido:<skill>` placeholder
- AC5: `version` in `plugins/aido/.claude-plugin/plugin.json` is `2.0.0`
- AC6: `claude plugin validate .` and `claude plugin validate ./plugins/aido` both pass
- AC7 (manual): with `claude --plugin-dir ./plugins/aido`, `/aido:1-plan` starts the plan skill
- AC8 (manual): both SVG diagrams show the `/aido:` commands and otherwise look as they did
- AC17: the marketplace in `.claude-plugin/marketplace.json` is named `aido`
- AC18: `ai-augmented-engineer` appears, in any letter case, only in this specification file
- AC19: `displayName` in `plugins/aido/.claude-plugin/plugin.json` is `AI-Augmented Engineering`

The README

- AC9: directly under the title comes the tagline "AI does, you decide.", followed by one sentence
  saying that the agent writes the spec, the code and the PRs, that you approve each step, and that
  it works with any stack
- AC10: the README's content runs in this order: the opening, the five-stage diagram, install and
  first command, how the workflow works and why, then the skill and guideline reference
- AC11: the install instructions use `/plugin marketplace add joebew42/aido` and
  `/plugin install aido@aido`, and name `/aido:1-plan` as the first command to run
- AC12: the README says once that `aido` stands for "AI do", echoes `sudo`, and serves AI-Augmented
  Engineering
- AC13: dropped — the only install is the author's own, so the README needs no upgrade note
- AC14: the five-stage diagram appears only near the top, and the `/aido:1-plan` screenshot stays in
  "You stay in the loop"
- AC15: nothing is lost in the move: the "What is an AI-Augmented Engineer?" section, every skill
  and guideline the README lists today, and its recommended user settings are still there
- AC16 (manual): a newcomer reading the top of the README, down to the install instructions, can
  tell what the workflow gives them and how to start
- AC20: the README's title is `# aido`

## Plan

This repository has no application code, so the items name the part of the plugin they touch rather
than a domain, application or infrastructure layer. It has no test suite either: the automatable
criteria are checked with `git grep`, a small script over the skill names, and `claude plugin validate`.

1. **plugin manifests — rename the plugin, its directory and the marketplace** (AC1, AC2, AC5, AC6,
   AC17, AC19): move `plugins/aiae/` to `plugins/aido/`, set the name, `displayName` and version
   `2.0.0` in `plugin.json`, and update the marketplace name and the plugin's name, source and
   description in `marketplace.json`
2. **skills and guidelines — use the new prefix** (AC3, AC4, AC7): update every `/aiae:<name>`
   reference in the skills, including their `description` lines, and both references in
   `guidelines/specification.md`
3. **diagrams — show the new commands** (AC3, AC8): update the command labels in
   `docs/human-in-the-loop.svg` and `docs/spec-at-the-center.svg`. The names have the same length,
   so the layout holds
4. **repository instructions — describe the new name** (AC3, AC18): update the layout and
   conventions in `CLAUDE.md`
5. **README — use the new names** (AC3, AC4, AC11, AC18, AC20): update the title, every command, the
   install instructions, the paths and the screenshot's alt text, and name `/aido:1-plan` as the
   first command
6. **README — reorder and sharpen** (AC9, AC10, AC12, AC14, AC15, AC16): add the tagline and opening
   sentence, say what `aido` stands for with the `sudo` reminder, move the five-stage diagram to the
   top, then install, then how the workflow works, and put the skill and guideline reference last

The enabling refactoring analysis was skipped.

### After the merge

These steps fall outside the branch, so they carry no acceptance criteria. Until they are done, the
README's install instructions do not work, and `/aiae:<skill>` must stay installed so the workflow
can finish.

1. rename the GitHub repository to `joebew42/aido`, once the author says so
2. point `origin` at the new URL
3. the author moves the local folder to `~/workspace/aido` and starts a new session there
4. the author removes `aiae@ai-augmented-engineer` and its marketplace, then adds the new marketplace
   and installs `aido@aido`

## Progress

All six plan items are implemented. The "After the merge" steps are still to do.

- [x] 1. plugin manifests: rename the plugin, its directory and the marketplace
- [x] 2. skills and guidelines: use the new prefix
- [x] 3. diagrams: show the new commands
- [x] 4. repository instructions: describe the new name
- [x] 5. README: use the new names
- [x] 6. README: reorder and sharpen

The repository has no test suite, so "the check script" below is an uncommitted script that ran
green on the final commit, using `jq`, `git grep`, `grep` and `claude plugin validate`.

- AC1: met — the check script reads the names and source from both manifests
- AC2: met — the check script
- AC3: met — the check script, over tracked content and paths
- AC4: met — the check script found 13 referenced skill names, all in `plugins/aido/skills/`
- AC5: met — the check script
- AC6: met — both `claude plugin validate` commands pass
- AC7: met — confirmed by the user: shown that `--plugin-dir` lists all 13 skills as `aido:*`
- AC8: met — confirmed by the user: shown the diff of 5 same-length labels per SVG; not rendered, as
  this machine has no SVG renderer
- AC9: met — the check script
- AC10: met — the check script, on the order of the section markers
- AC11: met — the check script
- AC12: met — the check script
- AC13: dropped — the only install is the author's own
- AC14: met — the check script
- AC15: met — the check script, on all 13 skills, 9 guidelines, the settings and the section
- AC16: met — confirmed by the user: shown the top of the README down to the install instructions
- AC17: met — the check script
- AC18: met — the check script
- AC19: met — the check script
- AC20: met — the check script

Decisions

- the first-feature list in the README gained a fifth step, `/aido:5-handle-review`, to match the
  five-stage diagram
- Quick start was split: the simple feature became "Your first feature" near the top, and the others
  moved to "Other ways to use it", after the skill list
- "Recommended user settings" became its own section after "Your first feature", so it does not
  interrupt the path from install to first command
- the old opening's point that the skills read conventions from the repository now lives only in
  "Your repository's rules come first"

The user skipped the final Systemic Design Checkpoint. No refactorings were deferred.
