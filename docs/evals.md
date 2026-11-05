# Evals

## What they are for

A skill is a set of instructions, so ordinary tests can't tell you whether changing one made the agent
better or worse. An eval can. It gives an agent a small practice project and a task, lets it work
alone, then checks what it did.

Each case runs **with aido** and **without aido**, which answers two questions:

- does aido add anything over plain Claude Code?
- did your change to a skill make the agent's work better or worse?

Evals only cover the situations they have a case for, so a good score doesn't prove that aido is good
in general.

## How to run them

You need `python3`, `git` and Claude Code. Each run is a real Claude session, so it is billed to an API
account or counts against a subscription's limits. Dollar figures here are estimates at API rates.

After changing a skill, run the cases for that skill:

```bash
python3 tests/evals.py --case 'implement-*'
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
| `--regrade <output-dir>` | off | Judges a run's saved reports again, running no agents. Use it after changing a rubric |

So far a run has cost about $2 with aido and about $0.25 without. One case at 3 runs per arm is about
$6, and the $5 default stops it early, so raise the limit for a full run.

To check the runner itself, for free:

```bash
python3 tests/test_evals.py
```

| Cases | What they check |
| --- | --- |
| `implement-connects-the-slice-early` | Given an outside-in item, does the agent connect the feature before writing the edge cases? |
| `implement-grows-an-inside-out-item-by-layer` | Given an inside-out item, does the agent grow the domain before the entry point? |
| `implement-finishes-the-feature` | Given a one-slice feature, does the agent finish it with the suite green and its inner units tested, and does it work? |
| `implement-writes-the-test-first` | Does the test change before the code? |
| `plan-names-each-items-mode` | Does each feature item in a plan name its mode and reason, with something to cite or an unknown? |
| `plan-stops-before-code` | Does planning wait for you instead of writing code? |
| `organize-follows-a-mode-change-in-progress` | When `## Progress` records a change to outside-in, is the history slice-shaped? |
| `organize-shapes-an-inside-out-part` | Is an inside-out part's history inside-out, with its acceptance tests last? |
| `organize-without-a-plan` | With no specification, plan or mode, is the history inside-out? |
| `implement-offers-to-organize` | Once every plan item is done, does the agent ask whether to organize the commits, name a deferred criterion, and wait instead of starting? |
| `implement-partial-session-offers-nothing` | With plan items left, does the agent name them, without offering to organize? |
| `organize-offers-the-pr` | Does the agent ask whether to create the PR, name open criteria, and start nothing and push nothing? |
| `organize-offers-the-pr-without-criteria` | With no specification, does the agent still ask, without bringing up criteria? |
| `verify-catches-a-test-that-cannot-fail` | Does verification notice a test that would pass anyway? |
| `verify-accepts-a-real-test` | Does verification accept good tests, without false alarms? |

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
- **Mean cost and turns:** what the result cost. Compare cost rather than turns, because an agent
  batching its work takes fewer turns for the same work
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

Recorded 2026-11-05 on plugin version 4.4.0 with claude-opus-5-5, 3 runs per arm.

| Measure | With aido | Without aido |
| --- | --- | --- |
| Score | 1.00 | 0.67 |
| behaves-as-specified | 3/3 | 3/3 |
| connects-before-the-edge-cases | 3/3 | 2/3 |
| inner-units-have-tests | 3/3 | 0/3 |
| suite-ends-green | 3/3 | 3/3 |
| Mean cost | $2.26 | $0.30 |
| Mean turns | 23 | 6 |

#### implement-grows-an-inside-out-item-by-layer

Recorded 2026-11-05 on plugin version 4.4.0 with claude-opus-5-5, 3 runs per arm.

| Measure | With aido | Without aido |
| --- | --- | --- |
| Score | 1.00 | 0.67 |
| behaves-as-specified | 3/3 | 3/3 |
| grows-the-domain-before-the-entry-point | 3/3 | 0/3 |
| suite-ends-green | 3/3 | 3/3 |
| Mean cost | $1.78 | $0.25 |
| Mean turns | 32 | 6 |

#### implement-writes-the-test-first

Recorded 2026-11-05 on plugin version 4.4.0 with claude-opus-5-5, 3 runs per arm.

| Measure | With aido | Without aido |
| --- | --- | --- |
| Score | 1.00 | 0.83 |
| does-the-work | 3/3 | 3/3 |
| test-before-code | 3/3 | 2/3 |
| Mean cost | $0.53 | $0.20 |
| Mean turns | 14 | 7 |

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

### What the verify results don't show

Plain Claude Code also spotted the test that couldn't fail, in all three runs. It then called the
criterion verified because it had checked the behaviour by hand. So the 3/3 against 0/3 measures how
strictly each one treats evidence, not whether it noticed the problem. Plain Claude Code also tested
beyond the criteria and found real bugs with unusual task names, which verification doesn't look for
by design. That is the job of `/code-review`.

## Why not `claude plugin eval`?

The cases follow the format of `claude plugin eval`, the official tool. It can't run the `order.json`,
`acceptance.sh` and `checks/<name>.sh` checks, which only this runner understands. On Ubuntu
its sandbox also failed for us: Bash couldn't start at all under the default AppArmor settings, and
with those settings off, every write failed with `Read-only file system`. This runner doesn't use that
sandbox, which is why it needs one of its own around it.
