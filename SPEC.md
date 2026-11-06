# Measure, then cut the TDD ceremony that doesn't help the agent

GitHub Issue: https://github.com/joebew42/aido/issues/46

## Context

A small study ("TDD in the agent loop: theater or actual value?", Birgitta Böckeler) found that an
agent doing TDD reached about the same quality as one that didn't, at 3 to 8.5 times the tokens.
aido's own evals show a similar gap of 2.7 to 7.8 times plain runs. But they mostly check that the
steps were followed, not that the result is better, so we can't tell which parts of
`/aido:2-implement` earn their cost.

The article also says that small steps give the agent real feedback where the code depends on
something it can't fully see. A test run steers the agent only when it can't predict the result.
That is the case in existing code that behaves differently from how it reads, in real
infrastructure, and in an unclear contract between parts. aido's inside-out mode rests on existing
code, so that is where hidden behaviour is most likely.

## Intent

Cut the TDD steps that look like ceremony for an agent, and measure the cut version against aido as
it is, on outcomes rather than on steps followed. Keep each cut only when the outcomes hold and the
cost drops, and restore any that hurts an outcome. Test the one-test-at-a-time cut on purpose
against a hidden trap, so small steps stay wherever they catch what the agent can't see.

What carries the quality stays: acceptance tests written first from the approved criteria, the
rules for the tests themselves, tests for every unit, connecting the real entry point first in
outside-in, running tests often, the design checkpoint, the final design review and
`/aido:verify`.

## Out of scope

- planning, the specification and its acceptance criteria
- the commit shape `/aido:3-organize-commits` relies on: commits stay per unit
- what carries the quality, listed in the Intent
- measuring each cut alone, unless the comparison shows an outcome drop that needs pinning down

## Acceptance criteria

Measuring two versions of aido

- AC1: When the eval runner is given a baseline git ref, its second arm runs the plugin from that ref
  instead of running without aido.
- AC2: When a baseline comparison has 3 or more valid runs per arm, the runner records it in its own
  generated section of `docs/evals.md`, naming the baseline ref.
- AC3: For each case with hidden behaviour tests, the results show a mean mutation score per arm.
  This is the share of one-line breakages of the agent's code that its own tests catch, counting
  only the breakages the hidden tests catch.
- AC4: A trap case gives the agent an inside-out item whose plan cites an existing helper that
  changes task titles in a way its name hides. Its hidden tests pass only if the helper's behaviour
  is respected.

The cuts

- AC5: When an item is `outside-in` or `in-unit`, implementing writes the real implementation
  straight away, with no fake value and no triangulation.
- AC6: When a unit is done, implementing sets aside its production changes and runs its new tests.
  It confirms that they fail, then restores the changes.
- AC7: Refactoring happens once per unit, on green, rather than after every test. The design
  checkpoint still runs whenever the evidence calls for it.
- AC8: In loop mode, a child doesn't present each test cycle for review. A single session still
  does.
- AC9: In a unit that is a contract, a mapping or a DTO and relies on no existing code, implementing
  writes the tests for the unit's planned behaviours together, then the code. Any other unit, also in
  an `inside-out` item, keeps one test at a time, and tests run after every change.

Deciding from the results

- AC10 (manual): The comparison against `main` ran on the four main `implement-*` cases and the trap
  case, with 3 runs per arm, and the runner recorded it.
- AC11 (manual): No outcome is worse with the cuts: hidden behaviour tests, suite ends green, inner
  units have tests, and mean mutation score. When one is worse, the cut responsible is restored and
  the comparison runs again.
- AC12 (manual): When, on the trap case, aido as it is ends right more often or more cheaply, AC9
  narrows. Tests are written together only for a contract, a mapping or a DTO. Any unit that relies
  on existing code keeps one test at a time.
- AC13: `docs/evals.md` names the outcome that each step check guards: `test-before-code`,
  `grows-the-domain-before-the-entry-point` and `connects-before-the-edge-cases`. A check that
  guards no outcome is removed.
- AC14 (manual): `docs/evals.md` says which cuts were kept and which were restored, with the figures
  behind each decision.

## Plan

1. **refactor: define the eval arms once** (enabling) — `tests/evals.py` names the arms `"with"` and
   `"without"` as literals in 10 places, and decides "the plugin is loaded" from the name. Give each
   arm a name, a report label and a plugin path or none, and loop over the pair. The results and
   `docs/evals/latest.json` stay the same. Touches infrastructure (`tests/evals.py`,
   `tests/test_evals.py`)
2. **refactor: let the runner write a chosen generated section** (enabling) — `replace_results`
   takes its marker pair, with today's as the default. `update_report` takes the JSON file and the
   document instead of deriving them from `--report-dir`. Touches infrastructure
3. **refactor: share the layered TODO app between fixtures** (enabling) — the `bin/` + `lib/` app is
   copied in full in `implement-finishes-the-feature`, `implement-grows-an-inside-out-item-by-layer`
   and `implement-connects-the-slice-early`. Move it into a function in `implement-todo.sh`, next to
   `todo_app`. The fixtures build the same files and commits. Touches infrastructure
4. **compare with a baseline version of aido** (AC1, AC2) — inside-out: follows
   `run_case(..., plugin=)`, which `--plugin-dir` already uses, and the arms from item 1. A
   `--baseline <ref>` option extracts `plugins/aido` at that ref with `git archive` into a temporary
   directory. The second arm runs on it, and its plugin version is read from that copy.
   `--stop-at-first-failure` watches the current tree's arm. The comparison goes through
   `recordable` into its own JSON file and its own generated section of `docs/evals.md`, using item 2,
   and never into the with/without results. Touches infrastructure
5. **mean mutation score** (AC3) — in-unit: which lines to break and how to count them is unsettled.
   The agent's code is its diff from the spec commit in `bin/` and `lib/`, read from git in the
   workspace. Each mutant deletes one changed line. A mutant counts only when the case's
   `acceptance.sh` fails on it, through `passes_acceptance`. It is caught when the case's own test
   command fails, which is a new `context: test_command` key in `case.yaml`. Each run stores the
   score as a number. `summarise` reports `mean_mutation_score` next to `mean_cost`, and the report
   shows it as a row. It runs inside `run_case`, before the workspace is removed. Touches
   infrastructure
6. **trap case `implement-respects-a-hidden-helper`** (AC4) — inside-out: follows the layout of
   `implement-finishes-the-feature`, on the shared app from item 3. `lib/task.sh` gets a title helper
   whose name hides that it changes the title. The plan in the case's `SPEC.md` marks the item
   inside-out, citing the helper. `acceptance.sh` passes only if the helper's change is respected.
   The case keeps `inner-units-have-tests` and `suite-ends-green`, and is listed in the
   `docs/evals.md` case table. Touches infrastructure
7. **apply the five cuts** (AC5, AC6, AC7, AC8, AC9) — inside-out: edits the sections listed under
   "Other modules or consumers affected" below. Fake it and triangulate are removed. A unit's tests
   are written together in inside-out mode, and other modes keep one test at a time with real code.
   "Watch it fail" becomes a check that sets the unit's changes aside. Refactoring happens once per
   unit. Presenting each cycle is dropped in Child Mode. "The Modes" keeps its name. "Step Size" keeps
   its name, or its reference in `2-implement` changes in the same edit. The README's TDD lines follow
   the change. Bump `version` to 4.7.0. Touches `plugins/aido/guidelines/tdd.md`,
   `plugins/aido/skills/2-implement/SKILL.md` and `README.md`
8. **run the comparison and decide** (AC10, AC11, AC12) — inside-out: follows "How to run them" in
   `docs/evals.md`. Ask before running, because it is billed: about $20 to $30. Run `--baseline main`
   on the four main `implement-*` cases and the trap case, 3 runs per arm. Then apply the decision
   rule. A cut that makes an outcome worse is pinned down by reading the transcripts, or by
   re-running with it restored. Then it is restored and the comparison runs again. If small steps
   win on the trap, narrow AC9 in `tdd.md` and `2-implement`
9. **record what was decided** (AC13, AC14) — inside-out: follows the hand-written "What the
   shorter runs saved" section in `docs/evals.md`. Name the outcome each step check guards, or
   remove the check. Record which cuts were kept or restored, with their figures. Touches
   `docs/evals.md`, and the cases of any removed check

## Design notes

- **Where it belongs:** The baseline arm, the mutation score and the second generated section belong
  in `tests/evals.py`, which already owns arms, scoring and recording. Their tests go in
  `tests/test_evals.py`. The trap case goes in `plugins/aido/evals/implement-respects-a-hidden-helper/`.
  The cuts belong in `plugins/aido/guidelines/tdd.md` and `plugins/aido/skills/2-implement/SKILL.md`.
  No other skill or guideline restates the one-test-at-a-time or fake-it rules.
- **Existing behaviour and abstractions to reuse:**
  - `tests/evals.py` — `run_case(plugin=)`, which the arms pass a plugin copy through
  - `tests/evals.py` — `summarise`, which takes the arm name already
  - `tests/evals.py` — `shell_checks`, `passes_acceptance`: the hidden tests decide which mutants
    count
  - `tests/evals.py` — `replace_results`, `recordable`, `changes`, `merge_report`
  - `plugins/aido/evals/implement-todo.sh` — `todo_app`, `spec_with`
  - `tests/test_evals.py` — `stand_in_project`, `run_main`, and
    `ChoosingThePlugin.test_runs_use_the_chosen_plugin`, which shows how to check which copy an arm
    ran on
- **Boundaries that must hold:**
  - `docs/evals/latest.json` and the with/without section stay byte-identical after items 1 and 2,
    guarded by `test_markdown_shows_each_case` and
    `test_results_replace_only_the_generated_section`
  - the comparison never writes the with/without results, and keeps the "3 valid runs per arm" rule
  - `problems` decides the plugin expectation per arm. Both arms load a plugin in a comparison
  - `tests/skills.sh` checks named sections: "The Modes" and "Step Size" in `tdd.md` are referenced
  - `tests/test_skills.py` — `test_a_removed_evidence_rule_fails` matches the exact wrapping of
    "Never record a criterion as met without its evidence." in `2-implement`
  - `tests/test_evals.py` — `ImplementCases.test_one_small_case_checks_the_finished_feature` pins that
    case's three checks, so the mutation score is a number, not a check.
    `CaseDocumentation.test_docs_list_every_case` requires the trap case in `docs/evals.md`
  - commits stay per unit, for `/aido:3-organize-commits`
- **Other modules or consumers affected:**
  - `docs/evals.md`: the options table, "How to read the results", the case table, a second
    generated section and the rough cost
  - `README.md`: lines 133 and 180-182 restate strict TDD and reviewable increments
  - `tdd.md`: the title, "The Red-Green-Refactor Cycle", "Step Size", and `inside-out`
  - `2-implement`: the header, "Acceptance Criteria as Goal Posts", "MANDATORY: One Test at a Time",
    "Child Mode" and "Red Flags to Watch For"
  - `tests/test_evals.py`: fixtures that name the arms
- **Enabling refactorings (planned):** items 1, 2 and 3.
  - Define the eval arms once, so a baseline arm doesn't repeat which arm loads the plugin in ten
    places
  - Let the runner write a chosen generated section, so the comparison never lands in the
    with/without results
  - Share the layered TODO app, so the trap case shows only its helper and plan
- **Deferred:** none. The finding that the runner sees only created files is new behaviour, built in
  item 5 by reading the agent's diff from git. The finding that the one-test rule is repeated inside
  the two edited files needs no action: item 7 edits every place it appears.
- **Open questions:** none blocking. Item 8 needs the user's go-ahead before it spends money.

## Progress

- [x] 1. refactor: define the eval arms once
- [x] 2. refactor: let the runner write a chosen generated section
- [x] 3. refactor: share the layered TODO app between fixtures
- [x] 4. compare with a baseline version of aido
- [x] 5. mean mutation score
- [x] 6. trap case `implement-respects-a-hidden-helper`
- [x] 7. apply the five cuts
- [x] 8. run the comparison and decide
- [x] 9. record what was decided

Acceptance:

- AC1: met — `ComparingWithABaseline.test_the_second_arm_runs_the_plugin_from_the_baseline_ref`
- AC2: met — `ComparingWithABaseline.test_a_full_comparison_is_recorded_in_its_own_section_naming_the_baseline_ref`
  and `test_a_comparison_with_fewer_runs_is_not_recorded`
- AC3: met — `MutationScore.test_the_results_show_a_mean_mutation_score_per_arm`
- AC4: met — `HiddenHelperTrap`: renaming through the helper passes the hidden test, and renaming with
  the title as typed fails it
- AC5, AC6, AC7, AC8, AC9: met — the rules are in `tdd.md` and `2-implement`, pinned by phrases in
  `tests/skills.sh`. Item 8's comparison found no outcome worse with them. Only AC6 was seen in a
  transcript: the agent stashed each unit's code and watched its tests fail
- AC9: changed, as AC12 required — the user agreed the narrowed wording
- AC10: met, confirmed by the user — both comparisons are in `docs/evals.md` and
  `docs/evals/comparison.json`
- AC11: met, confirmed by the user — every outcome was 3/3 in both arms, and the mutation score 1.00
  in both. No cut was restored
- AC12: met, confirmed by the user — on the trap case `main` was cheaper ($1.25 against $1.54), so
  AC9 was narrowed. Rerun with the narrowed rule: 3/3 at $1.17 against $1.40
- AC13: met — `CaseDocumentation.test_docs_name_what_each_step_check_guards`. Each step check guards an
  outcome, so none was removed
- AC14: met, confirmed by the user — "What the TDD cuts did" in `docs/evals.md`

Decisions:

- the comparison's arms are named `current` and `baseline` and labelled "This change" and
  "Baseline". Each entry in `docs/evals/comparison.json` keeps `baseline_ref` and `baseline_version`
- `update_report` takes a `Results` object: the JSON file, the document, the markers and the arms
- a mutant counts only when the script still parses (`sh -n`), so a deletion that breaks the syntax
  doesn't inflate the score. The agent's code includes untracked new files in `bin/` and `lib/`
- the cases' `test_command` runs every `*test*.sh` outside `bin/` and `lib/`, because agents may add
  unit tests in files of their own. Only `implement-finishes-the-feature` and the trap case have
  hidden tests, so only they get a score
- `implement-todo.sh` splits `layered_todo_app` into `layered_todo_files` and `publish_trunk`, so the
  trap case changes `lib/task.sh` before trunk is published
- the trap's helper `task_title` capitalises the first letter. The existing test adds "Pay rent", so
  the effect doesn't show
- the comparison costs more than planned, about $35, because both arms load aido
- in `tdd.md`, the unit's tests are checked to fail before it is refactored, so they guard the
  refactoring. The cycle section is now "The Test-Driven Cycle", and "MANDATORY: One Test at a Time"
  in `2-implement` is now "MANDATORY: Tests Before Code"

- item 8 cost $37.67: $21.60 for the four main cases, $8.36 for the trap and $7.71 for the trap again
  after narrowing AC9
- the cost dropped only in `implement-grows-an-inside-out-item-by-layer` (−16%). It was flat across
  the four main cases ($3.59 against $3.60). Those figures can't show a saving well: three of the
  cases stop once their order check settles, and `implement-finishes-the-feature` hit its 30-turn
  limit in 5 of 6 runs. Measuring the cost fairly needs that case's turn limit raised
- the one failed run with the cuts, in `implement-connects-the-slice-early`, connected in the right
  order but hit its turn limit. Its edge-case code in `lib/task.sh` was `return 1`, which
  `order.json`'s `already|not.found` doesn't match. A gap in the check, which item 9 can weigh up
- the final design review ran. It found one test fixture built twice in `tests/test_evals.py`, which
  was refactored, and two gaps in `docs/evals.md`, which were filled: the mutation score's reading and
  a comparison's cost
- some design notes no longer hold. `run_case` takes an `Arm`, not `plugin=`. The renamed sections are
  in the decision above. The step-size rule is again stated in every place, as the first deferred
  refactoring below says
- the architecture index predates `tests/evals.py`, and its `tdd` and `2-implement` entries still say
  "one test at a time"

Deferred refactorings, parked in `~/.claude/repos/aido/refactoring-opportunities/`:

- **State the step-size rule once** — Observation: the rule is stated in seven places in `tdd.md`,
  `2-implement` and `README.md`, and narrowing it had to change every copy. Evidence:
  `plugins/aido/guidelines/tdd.md` — "Step Size", `plugins/aido/skills/2-implement/SKILL.md` —
  "MANDATORY: Tests Before Code", `README.md` — the modes table. Competing explanations: repetition
  is deliberate for an agent reader; no change needed. Assumptions: agents follow a rule stated once
  as well. Confidence: medium. What would change it: one eval run on the consolidated prose.
  Recommendation: state it once in "Step Size" and point to it. Why it matters: copies can disagree
  after the next change. Risk: agent behaviour. Deferred because it is a risky change that needs a
  paid eval run
- **Let each eval case name where the agent's code is** — Observation: the runner hardcodes `bin/` and
  `lib/` as the agent's code, a fact about one fixture family. Evidence: `tests/evals.py` —
  `AGENT_CODE`, `plugins/aido/evals/implement-finishes-the-feature/case.yaml` —
  `context.test_command`. Competing explanations: both scored cases use that layout on purpose; no
  change needed. Assumptions: another layout will want a score. Confidence: medium. What would change
  it: deciding only the layered app is scored. Recommendation: a `context: agent_code` key read by
  `run_case`. Why it matters: another layout gets no score, silently. Risk: `mutation_score` gains an
  argument. Deferred because nothing needs it yet
