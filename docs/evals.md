# Evals

## What they are for

A skill is a set of instructions, so ordinary tests can't tell you whether changing one made the agent
better or worse. An eval can. It gives an agent a small practice project and a task, lets it work
alone, then checks what it did.

Each case runs **with aido** and **without aido**, which answers two questions:

- does aido add anything over plain Claude Code?
- did your change to a skill make the agent's work better or worse?

Evals only cover the situations they have a case for. A good score doesn't prove that aido is good in
general.

## How to run them

You need `python3`, `git` and Claude Code. Each run is a real Claude session, so it is billed to an API
account or counts against a subscription's limits. Dollar figures here are estimates at API rates.

## When to run them

Paid evals cost time and money, so most changes don't need them.

| When | What to run | Rough cost |
| --- | --- | --- |
| Every change | The free checks, below | Free, seconds |
| A risky change to a skill, when you ask for it | One run of the matching case | About $0.50 to $2, a few minutes |
| From time to time, such as before a release | The full round, recorded and committed | About $15 and 15 minutes for the four main `implement-*` cases, and about $40 for every case |
| A risky change to how agents implement, when you ask for it | A comparison with `--baseline main`, recorded and committed | About $22 for the four main `implement-*` cases and $8 for `implement-respects-a-hidden-helper`, because both arms load aido |

The one-run check stops as soon as a check fails with aido:

```bash
python3 tests/evals.py --case implement-connects-the-slice-early --runs 1 --stop-at-first-failure
```

It records nothing. Three runs catch more than one. If a change makes a check pass only half the time,
one run catches it 50% of the time, and three runs 87.5%. So a passing one-run check doesn't clear a
change. The full round is still what you compare against.

The full round needs a higher cost limit:

```bash
python3 tests/evals.py --max-cost-usd 50
```

Run this inside a sandbox or on a disposable machine, because the agents get unrestricted Bash. One way
is to ask Claude Code to run it with its sandbox on. You don't need to change any AppArmor settings.

| Option | Default | What it does |
| --- | --- | --- |
| `--case` | every case | Which cases to run, as a pattern |
| `--runs` | 3 | Runs per arm. Fewer than 3 is a quick check, and isn't recorded |
| `--max-cost-usd` | 5 | Starts no new run past this amount |
| `--concurrency` | 3 | Runs at the same time |
| `--model` | `opus` | The model the agents use |
| `--stop-at-first-failure` | off | Starts no new run once a check fails with aido, exits with status 2, and records no case that failed |
| `--plugin-dir <path>` | off | Runs the "with aido" arm on this copy of the plugin, and records nothing. Use it to check that a case fails when a rule is broken |
| `--baseline <ref>` | off | Runs the second arm on the plugin as committed at this git ref, instead of without aido. With 3 or more valid runs per arm, it records the comparison in [Compared with an earlier version](#compared-with-an-earlier-version), and never in the results with and without aido |
| `--regrade <output-dir>` | off | Judges a run's saved reports again, running no agents. Use it after changing a rubric |

A case with only an order check stops as soon as that check is settled. Any other check needs a
finished run, so its case runs to the end. The checks on finished
work for an outside-in feature are in `implement-finishes-the-feature`. They used to be in each
`implement-*` case that checks an order.

The free checks run with:

```bash
bash tests/all.sh
```

`tests/skills.sh` fails in three cases: a skill or guideline names a section that doesn't exist, a
skill doesn't refer to the ending block, or a listed approval question or evidence rule is removed.
`tests/test_evals.py` checks the runner itself.

| Cases | What they check |
| --- | --- |
| `implement-connects-the-slice-early` | Given an outside-in item, does the agent connect the feature before writing the edge cases? |
| `implement-grows-an-inside-out-item-by-layer` | Given an inside-out item, does the agent grow the domain before the entry point? |
| `implement-finishes-the-feature` | Given a one-slice feature, does the agent finish it with the suite green and its inner units tested, and does it work? |
| `implement-writes-the-test-first` | Does the test change before the code? |
| `implement-respects-a-hidden-helper` | Given an inside-out item whose plan cites a helper that changes task titles in a way its name hides, does the feature respect what the helper does? |
| `plan-names-each-items-mode` | Does each feature item in a plan name its mode and reason, with something to cite or an unknown? |
| `plan-stops-before-code` | Does planning wait for you instead of writing code? |
| `plan-raises-contradictory-criteria` | Given a draft whose two criteria clash for a completed task that is overdue, does planning ask which result holds before approving it? |
| `organize-follows-a-mode-change-in-progress` | When `## Progress` records a change to outside-in, is the history slice-shaped? |
| `organize-shapes-an-inside-out-part` | Is an inside-out part's history inside-out, with its acceptance tests last? |
| `organize-without-a-plan` | With no specification, plan or mode, is the history inside-out? |
| `organize-runs-the-tests-once` | Does organizing the commits run the tests only once, with the history still ending green? |
| `implement-offers-to-organize` | Once every plan item is done, does the agent ask whether to organize the commits, recommend a fresh context, name a deferred criterion, and wait instead of starting? |
| `implement-offers-a-fresh-context` | When you choose a fresh context, does the agent start nothing, tell you to run `/clear` and the next skill, and end with the ending block? |
| `implement-leaves-contradictory-criteria-unresolved` | Given an approved specification whose two criteria clash for a completed task, with nobody answering, does the agent record at most one of them as `met`, reword neither and name the clash? |
| `implement-partial-session-offers-nothing` | With plan items left, does the agent name them, without offering to organize? |
| `implement-records-each-item` | In a single session, does the agent tick item 1 in `## Progress` before it starts on item 2? |
| `implement-loops-over-the-plan` | In loop mode, does each plan item run in its own child, with the orchestrator recording it in `## Progress`? |
| `implement-loop-stops-on-an-unanswered-question` | In loop mode, when nobody answers a child's question, does the loop stop and name the paused item and the items left? |
| `implement-review-records-refactorings` | When the final design review finds a refactoring you accept, does the agent add it to `## Refactorings` without changing code, and name `/aido:2-implement` and `/aido:2-implement loop` as the ways to continue? |
| `implement-loop-runs-a-refactoring` | Does `loop r1` build the refactoring in its own child, tick it in `## Progress`, and offer to organize without a second design review? |
| `organize-offers-the-pr` | Does the agent ask whether to open the PR, name open criteria while still recommending it, and start nothing and push nothing? |
| `organize-offers-the-pr-without-criteria` | With no specification, does the agent still ask, without bringing up criteria? |
| `open-pr-settles-the-spec` | When the spec is still on the branch, does opening the PR ask what happens to it before any push, and push nothing with nobody answering? |
| `verify-catches-a-test-that-cannot-fail` | Does verification notice a test that would pass anyway? |
| `verify-accepts-a-real-test` | Does verification accept good tests, without false alarms? |
| `handle-review-suggests-nothing` | Given a review with only one-off fixes, does the agent suggest no convention and add nothing to `CLAUDE.md` or `AGENTS.md`? |
| `handle-review-asks-about-a-convention-seen-once` | Given a review point worth a convention that only this PR shows, does the agent ask whether to accept it, look in earlier PRs, ignore it or park it, adding nothing before the answer? |
| `handle-review-asks-one-comment-at-a-time` | Given a review with three comments, does the agent ask about one comment at a time, offering to fix it, call it out of scope or park it, with one option recommended, and change nothing before the answers? |

Plain Claude Code isn't expected to suggest conventions after a review. So
`handle-review-suggests-nothing` should pass without aido, and
`handle-review-asks-about-a-convention-seen-once` should fail without it. The first shows that aido
adds no noise. The second shows what it adds. `handle-review-asks-one-comment-at-a-time` is
expected to fail without aido too, since plain Claude Code isn't told to ask about each comment.

Runs have no `AskUserQuestion` tool, because nobody is there to answer. A skill's question shows up as
text in the final message, so a case about a question grades that message.

## How to read the results

The runner prints what moved since the last recorded results, then updates
[Current results](#current-results) below. Commit that update with the change it measures.

```text
Changes since the last report:
  implement-connects-the-slice-early [with]: score 0.50 -> 1.00
  implement-connects-the-slice-early [with] connects-before-the-edge-cases: 0/3 -> 3/3
```

- **A check, such as `3/3`:** how many valid runs passed it. This is the most useful figure
- **Score:** the share of checks passed, averaged over the valid runs
- **With and without aido:** the difference between them is what aido adds on that check
- **This change and Baseline:** in a comparison, the difference is what the change did to aido on that
  check
- **Mean mutation score:** in a case with hidden behaviour tests, the share of one-line breakages of
  the agent's code that its own tests catch. Only breakages the hidden tests catch count, so 1.00 means
  its tests caught every breakage that mattered
- **Mean cost and turns:** what the result cost. Compare cost rather than turns, because an agent
  batching its work takes fewer turns for the same work
- **`stopped early`:** the run ended once its order check was settled, as intended
- **`CUT OFF at its turn limit`:** the run ran out of turns before it finished. It still counts, so read
  a failed check on such a run as "didn't get there", not necessarily as a wrong result
- **`INVALID`:** the environment broke, for example Bash couldn't write. These runs are left out of the
  scores, nothing is recorded, and the command exits with status 2. Fix the environment and run again

Agents behave a little differently each time, and 3 runs is a small sample. Treat a change of one run,
such as `3/3` to `2/3`, as a hint: run it again or read the transcript before you act on it. A move
such as `3/3` to `0/3` is much more likely to be real. Transcripts are saved in
`plugins/aido/evals/results/`, which git ignores.

## Current results

### Recorded by the runner

Generated by `tests/evals.py`, so change this part by running it, not by hand.

<!-- evals:results:start -->
#### implement-connects-the-slice-early

Recorded 2026-11-05 on plugin version 4.4.1 with claude-opus-5-5, 3 runs per arm.

| Measure | With aido | Without aido |
| --- | --- | --- |
| Score | 1.00 | 1.00 |
| connects-before-the-edge-cases | 3/3 | 3/3 |
| Mean cost | $0.94 | $0.24 |
| Mean turns | 28 | 7 |

#### implement-finishes-the-feature

Recorded 2026-11-05 on plugin version 4.4.1 with claude-opus-5-5, 3 runs per arm.

| Measure | With aido | Without aido |
| --- | --- | --- |
| Score | 1.00 | 0.67 |
| behaves-as-specified | 3/3 | 3/3 |
| inner-units-have-tests | 3/3 | 0/3 |
| suite-ends-green | 3/3 | 3/3 |
| Mean cost | $1.80 | $0.23 |
| Mean turns | 27 | 6 |

#### implement-grows-an-inside-out-item-by-layer

Recorded 2026-11-05 on plugin version 4.4.1 with claude-opus-5-5, 3 runs per arm.

| Measure | With aido | Without aido |
| --- | --- | --- |
| Score | 1.00 | 0.00 |
| grows-the-domain-before-the-entry-point | 3/3 | 0/3 |
| Mean cost | $0.95 | $0.20 |
| Mean turns | 32 | 6 |

#### implement-writes-the-test-first

Recorded 2026-11-05 on plugin version 4.4.1 with claude-opus-5-5, 3 runs per arm.

| Measure | With aido | Without aido |
| --- | --- | --- |
| Score | 1.00 | 0.67 |
| test-before-code | 3/3 | 2/3 |
| Mean cost | $0.38 | $0.14 |
| Mean turns | 12 | 6 |

#### verify-accepts-a-real-test

Recorded 2026-11-04 on plugin version 4.1.0 with claude-opus-5-5, 3 runs per arm.

| Measure | With aido | Without aido |
| --- | --- | --- |
| Score | 1.00 | 0.67 |
| verifies-both-criteria | 3/3 | 2/3 |
| Mean cost | $0.59 | $0.21 |
| Mean turns | 11 | 6 |

#### verify-catches-a-test-that-cannot-fail

Recorded 2026-11-04 on plugin version 4.1.0 with claude-opus-5-5, 3 runs per arm.

| Measure | With aido | Without aido |
| --- | --- | --- |
| Score | 1.00 | 0.50 |
| does-not-condemn-the-good-test | 3/3 | 3/3 |
| does-not-trust-the-test | 3/3 | 0/3 |
| Mean cost | $0.59 | $0.19 |
| Mean turns | 11 | 7 |
<!-- evals:results:end -->

Cases not listed here have no recorded results yet.

### Compared with an earlier version

Generated by `tests/evals.py --baseline <ref>`, so change this part by running it, not by hand. Each
case compares the plugin in this tree with the plugin at the named ref.

<!-- evals:comparison:start -->
#### handle-review-asks-about-a-convention-seen-once

Recorded 2026-11-10 on plugin version 5.12.0 against `main` at plugin version 5.10.0, with claude-opus-5-5, 3 runs per arm.

| Measure | This change | Baseline |
| --- | --- | --- |
| Score | 0.67 | 0.50 |
| asks-to-accept-look-ignore-or-park | 1/3 | 0/3 |
| commits-no-convention | 3/3 | 3/3 |
| Mean cost | $0.50 | $0.40 |
| Mean turns | 15 | 14 |

#### implement-connects-the-slice-early

Recorded 2026-11-07 on plugin version 4.7.0 against `main` at plugin version 4.6.0, with claude-opus-5-5, 3 runs per arm.

| Measure | This change | Baseline |
| --- | --- | --- |
| Score | 0.67 | 0.67 |
| connects-before-the-edge-cases | 2/3 | 2/3 |
| Mean cost | $0.94 | $0.90 |
| Mean turns | 34 | 37 |

#### implement-finishes-the-feature

Recorded 2026-11-07 on plugin version 4.7.0 against `main` at plugin version 4.6.0, with claude-opus-5-5, 3 runs per arm.

| Measure | This change | Baseline |
| --- | --- | --- |
| Score | 1.00 | 1.00 |
| behaves-as-specified | 3/3 | 3/3 |
| inner-units-have-tests | 3/3 | 3/3 |
| suite-ends-green | 3/3 | 3/3 |
| Mean mutation score | 1.00 | 1.00 |
| Mean cost | $1.18 | $1.69 |
| Mean turns | 30 | 34 |

#### implement-grows-an-inside-out-item-by-layer

Recorded 2026-11-07 on plugin version 4.7.0 against `main` at plugin version 4.6.0, with claude-opus-5-5, 3 runs per arm.

| Measure | This change | Baseline |
| --- | --- | --- |
| Score | 0.67 | 0.33 |
| grows-the-domain-before-the-entry-point | 2/3 | 1/3 |
| Mean cost | $0.95 | $0.88 |
| Mean turns | 43 | 39 |

#### implement-respects-a-hidden-helper

Recorded 2026-11-07 on plugin version 4.7.0 against `main` at plugin version 4.6.0, with claude-opus-5-5, 3 runs per arm.

| Measure | This change | Baseline |
| --- | --- | --- |
| Score | 1.00 | 1.00 |
| behaves-as-specified | 3/3 | 3/3 |
| inner-units-have-tests | 3/3 | 3/3 |
| suite-ends-green | 3/3 | 3/3 |
| Mean mutation score | 1.00 | 1.00 |
| Mean cost | $0.95 | $1.11 |
| Mean turns | 40 | 36 |

#### implement-writes-the-test-first

Recorded 2026-11-07 on plugin version 4.7.0 against `main` at plugin version 4.6.0, with claude-opus-5-5, 3 runs per arm.

| Measure | This change | Baseline |
| --- | --- | --- |
| Score | 1.00 | 1.00 |
| test-before-code | 3/3 | 3/3 |
| Mean cost | $0.36 | $0.28 |
| Mean turns | 12 | 10 |
<!-- evals:comparison:end -->

### What the shorter runs saved

Measured on 2026-11-05 with claude-opus-5-5, 3 runs per arm.

| Case | Mean cost with aido, before | After | After, share of before |
| --- | --- | --- | --- |
| `implement-connects-the-slice-early` | $2.26 | $0.94 | 42% |
| `implement-grows-an-inside-out-item-by-layer` | $1.78 | $0.95 | 53% |
| `implement-writes-the-test-first` | $0.53 | $0.38 | 72% |

| Round, 3 runs per arm, both arms | Before | After |
| --- | --- | --- |
| The three cases above | $15.96 | $8.60 (54%) |
| The three cases plus `implement-finishes-the-feature` | $15.96 | $14.69 (92%) |

So a check on one order is much cheaper, but the full round is only about 8% cheaper. The new case
costs about $1.80 per run with aido. About $0.66 of that is the final design review, which the case
doesn't check.

The shortened cases still fail when the behaviour breaks. Each ran once against a copy of the plugin whose
rule said the opposite, and its check failed: `connects-before-the-edge-cases`,
`grows-the-domain-before-the-entry-point`, `test-before-code` and `inner-units-have-tests`. That is one
run each, so it is good evidence rather than proof.

### What the step checks guard

A step check passes when the agent follows a step, not when the result is better. Each one stays only
because it guards an outcome:

| Step check | The outcome it guards |
| --- | --- |
| `test-before-code` | Tests that catch breakages of the code, which the mean mutation score measures. A test written after its code may never have failed. Without aido it passed 2/3 |
| `grows-the-domain-before-the-entry-point` | Inner units that have tests of their own, which `inner-units-have-tests` measures. Without aido this check and that outcome were both 0/3 |
| `connects-before-the-edge-cases` | A feature that behaves as specified when the plan is wrong about how the parts fit: the wrong assumption shows at the first slice, before the edge cases build on it. No case has a wrong plan yet, so nothing measures this outcome directly |
| `ticks-item-1-before-item-2` | A specification that shows which items are done when a session is cut off partway. No case cuts a session off, so nothing measures this outcome directly |

So no step check was removed. `connects-before-the-edge-cases` misses edge-case code that doesn't
name its case in lower case. In one run, the agent wired the entry point first, but its first edge case
was a bare `return 1`. In two later runs, it was named `TASK_ALREADY_COMPLETED`, which the check's
`already` doesn't match. Each of these runs then ran out of turns before the check could settle. The
check now ignores case, which catches the second kind, but not a bare `return 1`.

### What the TDD cuts did

Version 4.7.0 cut five steps from `/aido:2-implement` and `tdd.md` that looked like ceremony for an
agent. It was compared with `main`, at version 4.6.0, with claude-opus-5-5 and 3 runs per arm. The
cuts were measured together, not one at a time.

| Cut | Decision |
| --- | --- |
| The real implementation straight away, with no fake value and no triangulation | Kept |
| Each unit's tests set aside its code and are seen failing, instead of watching each test fail | Kept |
| Refactoring once per unit, instead of after every test | Kept |
| No test cycle presented for review, in any mode, instead of only in loop mode | Kept. Widened after the first comparison, and measured in the second |
| An `inside-out` unit's tests written together | Narrowed: only for a contract, a mapping or a DTO that relies on no existing code |

The first comparison, on 2026-11-06, ran while a single session still presented each test cycle. Every
eval run is a single session, so it measured the other four cuts only:

| Case | Outcomes, cuts and `main` | Mean cost with the cuts | `main` |
| --- | --- | --- | --- |
| `implement-connects-the-slice-early` | Its order check: 2/3 and 3/3. The failed run ran out of turns, as above | $0.92 | $0.90 |
| `implement-finishes-the-feature` | All 3/3 in both, mutation score 1.00 in both | $1.55 | $1.46 |
| `implement-grows-an-inside-out-item-by-layer` | Its order check: 3/3 and 1/3 | $0.79 | $0.94 |
| `implement-writes-the-test-first` | Its order check: 3/3 in both | $0.33 | $0.30 |
| `implement-respects-a-hidden-helper`, before narrowing | All 3/3 in both, mutation score 1.00 in both | $1.54 | $1.25 |
| `implement-respects-a-hidden-helper`, after narrowing | All 3/3 in both, mutation score 1.00 in both | $1.17 | $1.40 |

No outcome was worse with the cuts, so none was restored. On the trap case, `main` was right just as
often but 19% cheaper, so writing a unit's tests together was narrowed. Code that already exists may
not do what its name says, and a run after each test is what shows it. With the narrowed rule, the
trap case cost 16% less than `main`. Across the four main cases, the cost was flat: $3.59 against
$3.60. But `implement-finishes-the-feature` ran out of turns in 5 of its 6 runs, so both arms stopped
at the same limit.

The second comparison, on 2026-11-07, ran with every cut, as recorded in
[Compared with an earlier version](#compared-with-an-earlier-version):

| Case | Outcomes, cuts and `main` | Mean cost with the cuts | `main` |
| --- | --- | --- | --- |
| `implement-connects-the-slice-early`, re-run with the check ignoring case | Its order check: 2/3 in both. Each failed run wired the entry point, then ran out of turns before any edge case | $0.94 | $0.90 |
| `implement-finishes-the-feature` | All 3/3 in both, mutation score 1.00 in both. No run ran out of turns | $1.18 | $1.69 |
| `implement-grows-an-inside-out-item-by-layer` | Its order check: 2/3 and 1/3 | $0.95 | $0.88 |
| `implement-writes-the-test-first` | Its order check: 3/3 in both | $0.36 | $0.28 |
| `implement-respects-a-hidden-helper` | All 3/3 in both, mutation score 1.00 in both | $0.95 | $1.11 |

Again no outcome was worse, so no cut was restored. `implement-connects-the-slice-early` first came out
1/3 against 3/3. But both failed runs had wired the entry point first, and the check missed their
`TASK_ALREADY_COMPLETED`. The check now ignores case, and that case alone was run again, for $5.50.

The two cases that run to the end were cheaper with the cuts. `implement-finishes-the-feature`
cost 30% less, $1.18 against $1.69, in 30 turns against 34. It is the first fair figure for it, because
no run stopped at the turn limit. The trap case cost 14% less, $0.95 against $1.11, though in 40 turns
against 36. Across the four main cases, the cuts cost 9% less, $3.43 against $3.75. The cases that stop
once their order check is settled show no clear saving either way.

These are 3 runs per arm. Single runs of `implement-finishes-the-feature` with the cuts cost between
$0.75 and $1.88, so the 30% is a hint that points the same way as the trap case, not proof.

### What the verify results don't show

Plain Claude Code also spotted the test that couldn't fail, in all three runs. It then called the
criterion verified because it had checked the behaviour by hand. So the 3/3 against 0/3 measures how
strictly each one treats evidence, not whether it noticed the problem. Plain Claude Code also tested
beyond the criteria and found real bugs with unusual task names. Verification doesn't look for those,
by design. That is the job of `/code-review`.

## Why not `claude plugin eval`?

The cases follow the format of `claude plugin eval`, the official tool. It can't run the `order.json`,
`acceptance.sh` and `checks/<name>.sh` checks, which only this runner understands. On Ubuntu its
sandbox also failed for us. Bash couldn't start at all under the default AppArmor settings. With those
settings off, every write failed with `Read-only file system`. This runner doesn't use that
sandbox, which is why it needs one of its own around it.
