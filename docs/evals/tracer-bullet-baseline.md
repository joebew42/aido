# Baseline: connecting a feature early

This records how agents build a feature across layers today, so that a change to the TDD guidance,
such as asking for tracer bullets, can be compared against it.

| | |
| --- | --- |
| Recorded | 2026-11-04 |
| Case | `plugins/aido/evals/implement-connects-the-slice-early` |
| Plugin | version 4.1.0, on top of commit `0b5a9da`, with `tdd.md` not yet asking for tracer bullets |
| Claude Code | 2.1.318 |
| Model | `claude-opus-5-5` |
| Runs | 3 per arm, all valid |
| Command | `python3 tests/evals.py --case implement-connects-the-slice-early --runs 3` |

## Results

| Measure | With aido | Without aido |
| --- | --- | --- |
| `connects-before-the-edge-cases`: the entry point has the command before any edge case exists | **0/3** | **0/3** |
| `suite-ends-green`: the agent's own test suite passes | 3/3 | 3/3 |
| Mean cost of a run | $1.89 | $0.26 |
| Mean turns | 38 | 8 |

Each run, in the order recorded:

| Arm | Cost | Turns |
| --- | --- | --- |
| with | $1.79 | 29 |
| with | $1.92 | 21 |
| with | $1.96 | 64 |
| without | $0.28 | 12 |
| without | $0.26 | 5 |
| without | $0.24 | 6 |

## How to compare against it

Change the guidance, then run the command above. The measure to watch is
`connects-before-the-edge-cases`, which today is 0/3 in both arms, and the cost, which should not
rise much for the same result. Treat a change of one run out of three as a hint, and repeat it before
relying on it.

## What it does not show

- **Whether aido is better or worse overall.** This case asks for one narrow behaviour. The aido runs
  also commit their work and run a design check, which it does not score, and that accounts for at
  least part of their cost
- **Whether the code is correct.** The agents wrote the tests in `suite-ends-green`. Later runs add
  `behaves-as-specified`, which runs hidden checks, so it has no baseline figure here
- **Anything beyond this small app.** Three runs of one small shell project are a sample, not a
  measurement of agents in general

## Left out

`entry-point-is-connected` also ran, scoring 1/3 in each arm, but it is not part of this baseline. Its
judge repeatedly failed a script that meets its rubric, so the case no longer uses it.
