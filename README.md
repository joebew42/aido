<div align="center">

<img src="docs/readme/aido-mascot-small.png" alt="aido, a friendly pixel-art robot holding a laptop with a terminal prompt" width="260" />

# aido 🥋

**A spec-driven, test-driven engineering workflow for Claude Code and Copilot CLI.**

Hand your coding agent the whole feature while you stay in the loop! Works with any stack.

[Get started](#get-started) · [How it works](#how-it-works) · [Skills](#skills) ·
[Why aido?](#why-aido)

</div>

```text
┌────────────────────────┐    ┌────────────────────────┐    ┌────────────────────────┐
│ 1 · Plan               │    │ 2 · Implement          │    │ 3 · Organize commits   │ ─┐
│ drafts the spec and    │ ─▶ │ builds it test-first,  │ ─▶ │ shapes a clean,        │  │
│ plans the work         │    │ checks the criteria    │    │ reviewable history     │  │
└────────────────────────┘    └────────────────────────┘    └────────────────────────┘  │
/aido:1-plan                  /aido:2-implement             /aido:3-organize-commits    │
  ┌─────────────────────────────────────────────────────────────────────────────────────┘
  ▼
┌────────────────────────┐    ┌────────────────────────┐
│ 4 · Open PR            │    │ 5 · Handle review      │
│ verifies, pushes and   │ ─▶ │ weighs the feedback,   │
│ opens the pull request │    │ acts on what you pick  │
└────────────────────────┘    └────────────────────────┘
/aido:4-open-pr               /aido:5-handle-review
```

---

## Get started

### Claude Code

```text
/plugin marketplace add joebew42/aido
/plugin install aido@aido
/aido:1-plan
```

### Copilot CLI

Tested with Copilot CLI 1.0.107.

```bash
copilot plugin marketplace add joebew42/aido
copilot plugin install aido@aido
copilot
```

In the Copilot session, start with `/1-plan`. Copilot uses unqualified skill names (`/<skill>`); if
another skill has the same name, remove or rename the conflicting skill before invoking aido.

The workflow diagram and skill tables below use Claude Code names (`/aido:<skill>`). In Copilot CLI,
omit `aido:`.

### Your first feature, in five steps

| | Skill&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | What happens |
| :--: | :--- | :--- |
| **01** | `/aido:1-plan` | Draft and approve the specification and plan in `SPEC.md`. |
| **02** | `/aido:2-implement` | Build the feature test-first, and check every acceptance criterion. |
| **03** | `/aido:3-organize-commits` | Turn the work into a clean, reviewable commit history. |
| **04** | `/aido:4-open-pr` | Offer a verification, push with your approval, and open the pull request. |
| **05** | `/aido:5-handle-review` | Weigh the review feedback and act on the items you pick. |

> **You approve what matters.** aido proposes. It never decides what to build, rewrites history or
> pushes without asking you.

### What planning looks like

Start from a GitHub issue, your own `SPEC.md.draft`, or a conversation where aido interviews you.

<div align="center">
  <img src="docs/readme/plan-asks-for-the-spec.png" alt="aido planning asks whether to start from a GitHub issue, a draft specification, or a conversation" width="760" />
</div>

`/aido:1-plan` checks the draft against your repository and refines it with you. You approve it
three times: the draft, the specification and the plan. A small, clear change can take a lighter
route, where you approve a short specification and plan at once.

Each skill ends by offering the next one, so you don't have to remember the order. It recommends a
fresh context: run `/clear`, then the next skill. That skill picks up from `SPEC.md` and the git
history. Every skill ends with a short note: what it did, what it decided, and what it needs from you.

### Recommended Claude Code settings

The guidelines ask for commits and PRs without AI attribution, and for no auto-memory. A plugin
can't set these itself, so add this to `~/.claude/settings.json`:

```json
{
  "autoMemoryEnabled": false,
  "attribution": { "commit": "", "pr": "" }
}
```

### Recommended Copilot CLI settings

These settings disable Copilot's own memory and automatic commit attribution:

```bash
copilot config memory false
copilot config includeCoAuthoredBy false
```

### What the plugin's hooks enforce

| Hook&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Default | Turn&nbsp;it&nbsp;off&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
| :--- | :--- | :--- |
| Ask for your approval before every `git push` | on | not available |
| Block commit messages containing<br>`Co-Authored-By` trailers | on | `git config aido.allowCommitAttribution true` |
| Block writes to Claude's memory directory | on | `git config aido.allowMemoryWrites true` |

In Claude Code, each opt-out applies to the current repository; add `--global` to apply it everywhere.
These are your settings to make: the skills never set them.

### Copilot CLI limitations

- Hooks run from the plugin directory, so project-local git opt-outs may not be read. A `--global`
  opt-out applies to every repository, including in Claude Code; use it only if that is what you want.
- The memory hook protects Claude's memory directory, not Copilot's memory. Disable Copilot memory
  with the setting above if you do not want it used.
- Copilot does not run the compaction reminder hook. After compaction, invoke the current skill again
  to reload its guidelines.
- Hooks are safeguards, not a security boundary: a host failure or timeout can prevent enforcement.

---

## Why aido?

**Delegate the work, not the judgement.** The agent writes the specification, the tests, the code,
the commits and the pull request. You decide what gets built, and you own the result.

The name **aido** means **"AI do"** and echoes `sudo`: the agent acts on your say-so.

- **Test-driven.** The tests come before the code, and each unit's tests must fail without its code.
- **Engineering practices built in.** Clean architecture, focused tests, deliberate refactoring and
  a tidy history.
- **Your repository's conventions win.** aido follows `CLAUDE.md`, `AGENTS.md` and your code, not a
  naming, testing or architecture scheme of its own.

For more on the idea, see [AI-Augmented Software Engineering](https://www.sei.cmu.edu/ai-augmented-software-engineering/)
from Carnegie Mellon University.

---

## How it works

### One specification connects the whole workflow

`SPEC.md` holds the feature: why (**Context**), what (**Intent**), what not (**Out of scope**), and
numbered **Acceptance criteria** (`AC1`, `AC2`, …). Planning adds how, as a plan. Every later skill
reads it.

<div align="center">
  <img src="docs/readme/spec-at-the-center.svg" alt="SPEC.md at the center: planning writes it, implementation reads and updates it, organizing commits reverts it or moves it into the docs, the PR is written from it, review reads it without changing it, and verification checks the code against it" width="900" />
</div>

### Acceptance criteria stay visible

Every plan item names the criteria it serves. Implementation tests each criterion first, and checks
them all before it finishes. A criterion only you can check is marked `(manual)`. When one isn't
met, you build it, change it or defer it. Deferred ones can become GitHub issues.

### Uncertainty chooses how each part is built

Each plan item names its mode and why, so you can challenge it before any code exists.

| What's unknown | Mode&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | How it is built | History |
| :--- | :--- | :--- | :--- |
| Nothing: it follows existing code or a known contract | `inside-out` | Layer by layer | Inside-out, acceptance tests last |
| How the parts fit, or what an interface should be | `outside-in` | In tracer bullet slices | One group of commits per slice |
| Logic within one unit | `in-unit` | In that unit | As inside-out |

In every mode, "Step Size" in [`tdd.md`](plugins/aido/guidelines/tdd.md) decides how many tests come
before the code. A part is inside-out only if the plan can cite what it follows. When the plan proves
wrong, implementation switches the mode and tells you.

### The repository is part of the conversation

Planning checks the specification against your code, `CLAUDE.md` and `AGENTS.md`. Implementation
checks again in case the default branch moved. On a conflict, aido shows the files and recommends
revising or rejecting the specification. You can still go ahead, and your reason is recorded.

### Verify what was agreed

`/aido:verify` checks a branch or a PR against what was agreed, in a **fresh context**, so the agent
that built it isn't the judge. It changes nothing. A requirement is **verified** only by a test that
passed during the check, or by your confirmation. Otherwise it is **insufficient evidence** or
**unmet**. A PR without a specification is checked against its description and linked issues.

| Tool | Question |
| --- | --- |
| `/aido:verify` | **Did we build what we agreed to build?** |
| `/code-review` (`/review` in Copilot) | **Does the code have defects?** |

---

## Skills

### Single-phase feature

| Skill&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Purpose |
| :--- | :--- |
| `/aido:1-plan` | Draft, refine, and plan a feature into `SPEC.md`. |
| `/aido:2-implement` | Implement the feature using TDD. `loop` (or `loop 7-9`) runs each plan item in a fresh subagent. The final design review adds the refactorings you accept to the spec's `## Refactorings`, as `r1`, `r2`, …. `loop r1` (or `loop r1-r3`) runs them the same way. |
| `/aido:3-organize-commits` | Organize the commit history. |
| `/aido:4-open-pr` | Open a pull request. |
| `/aido:5-handle-review` | Handle PR review feedback. |

### Multi-phase feature

| Skill&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Purpose |
| :--- | :--- |
| `/aido:multi-phase-spec-pr` | Create the specification tracking PR. |
| `/aido:multi-phase-switch` | Switch to the main plan branch. |
| `/aido:multi-phase-sync` | Sync the main plan with progress. |

### Utilities

| Skill&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Purpose |
| :--- | :--- |
| `/aido:verify` | Check a branch or PR against the agreed requirements from a fresh context. |
| `/aido:stabilize` | Take over a PR, remote branch, or local changes created outside this workflow. |
| `/aido:map-architecture` | Build or update a slim map of domain areas and building blocks. |
| `/aido:assess-architecture` | Assess the architecture area by area, and save the refactoring ideas you pick. `/aido:1-plan` offers them when a planned change fits. |
| `/aido:resolve-migration-conflict` | Resolve migration conflicts after a rebase, with any migration tool. |

---

## Other ways to use aido

### Plan a multi-phase feature

1. Write the overall feature specification in `SPEC.md.draft`.
2. Run `/aido:multi-phase-spec-pr` to create the tracking PR.
3. For each phase (or independent phases in parallel), run `/aido:1-plan`, `/aido:2-implement`,
   `/aido:3-organize-commits`, and `/aido:4-open-pr`. Planning can offer parallel worktrees.
4. Run `/aido:multi-phase-sync` to update the main plan and begin the next phase.

### Take over existing work

1. Run `/aido:stabilize` against a PR, remote branch, or local changes.
2. Choose whether to reimplement from scratch or carry the changes over and adjust them.
3. Approve the plan written into `SPEC.md`.
4. Continue with implementation, commit organization, and PR creation.

### Review someone else's PR

Run `/aido:verify <PR number>` to compare it with the agreed requirements. Run `/code-review` to look
for defects. In Copilot CLI, use `/verify <PR number>` and `/review`.

### Resolve a migration conflict

Run `/aido:resolve-migration-conflict` when another PR's database migration was merged while yours
was open.

---

## Engineering guidelines

The skills follow the guidelines in [`plugins/aido/guidelines/`](plugins/aido/guidelines/).

---

## Measuring it

Eval cases compare what agents do with aido, without it, or with an earlier version of it. So a
change to a skill is measured, not judged by feel. See
[how to run and read them, and the current results](docs/evals.md).

---

<div align="center">

**aido 🥋**

</div>
