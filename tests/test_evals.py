import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).parent))
import evals

EVALS = Path(__file__).parent.parent / "plugins" / "aido" / "evals"
SLICE = EVALS / "implement-connects-the-slice-early" / "graders"
TEST_FIRST = EVALS / "implement-writes-the-test-first" / "graders"


def line(**fields):
    return json.dumps(fields, separators=(",", ":"))


def write(path):
    return line(type="tool_use", name="Write", input={"file_path": path, "content": 'echo "all passed"'})


def edit(path):
    return line(type="tool_use", name="Edit", input={"replace_all": False, "file_path": path, "old_string": "a", "new_string": "b"})


def read(path):
    return line(type="tool_use", name="Read", input={"file_path": path})


GREEN = line(type="tool_result", content="all passed\n", is_error=False, tool_use_id="t")
SOURCE = line(type="tool_result", content='7\techo "all passed"\n', tool_use_id="t")


def trace(*lines):
    return "\n".join(lines)


def event(*blocks, role="user"):
    return json.dumps({"type": role, "message": {"role": role, "content": list(blocks)}})


def bash_result(content, is_error=False):
    return {"type": "tool_result", "content": content, "is_error": is_error, "tool_use_id": "t"}


INIT_WITH = json.dumps({"type": "system", "subtype": "init", "slash_commands": ["aido:2-implement", "debug"], "model": "m"})
INIT_WITHOUT = json.dumps({"type": "system", "subtype": "init", "slash_commands": ["debug"], "model": "m"})
RESULT = json.dumps({"type": "result", "result": "done", "total_cost_usd": 0.25, "is_error": False})
BASH_USE = event({"type": "tool_use", "id": "t", "name": "Bash", "input": {"command": "ls"}}, role="assistant")


class Frontmatter(unittest.TestCase):
    def test_reads_scalars_quotes_lists_and_maps(self):
        meta, body = evals.parse_frontmatter(
            "---\nmax_turns: 40\npath: \"**/SPEC.md\"\npattern: 'a\\\\b''c'\n"
            "allowed_tools: [Read, Bash]\nfocus: { source: file, path: bin/todo }\nexists: false\n---\n\nThe body\n"
        )

        self.assertEqual(meta["max_turns"], 40)
        self.assertEqual(meta["path"], "**/SPEC.md")
        self.assertEqual(meta["pattern"], "a\\\\b'c")
        self.assertEqual(meta["allowed_tools"], ["Read", "Bash"])
        self.assertEqual(meta["focus"], {"source": "file", "path": "bin/todo"})
        self.assertIs(meta["exists"], False)
        self.assertEqual(body, "The body")


class RegexGraders(unittest.TestCase):
    def grade(self, path, text):
        meta, _ = evals.parse_frontmatter(path.read_text())
        return evals.grade_regex(meta, evals.Run(trace=text, last_message="", workspace=None))

    def test_suite_green_needs_real_test_output(self):
        green = SLICE / "suite-ends-green.md"

        self.assertTrue(self.grade(green, GREEN))
        self.assertTrue(self.grade(green, line(type="tool_result", content="Pay rent\nall passed")))
        self.assertTrue(self.grade(green, line(type="tool_result", content="all passed\n2ef18f5 docs: update")))
        self.assertFalse(self.grade(green, SOURCE))
        self.assertFalse(self.grade(green, line(type="text", text="it should print `all passed`. Done.")))
        self.assertFalse(self.grade(green, line(type="tool_result", content="FAIL: not all passed yet")))

    def test_not_contains_inverts_the_match(self):
        meta = {"pattern": "secret", "match": "not_contains", "target": "trace"}

        self.assertTrue(evals.grade_regex(meta, evals.Run(trace="clean", last_message="", workspace=None)))
        self.assertFalse(evals.grade_regex(meta, evals.Run(trace="a secret", last_message="", workspace=None)))


class OrderOfWork(unittest.TestCase):
    def watch(self, case):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        workspace = Path(self.directory.name)
        (workspace / "bin").mkdir()
        (workspace / "lib").mkdir()
        return workspace, evals.OrderWatch(workspace, json.loads((EVALS / case / "order.json").read_text()))

    def test_connecting_first_then_adding_the_edge_cases_passes(self):
        workspace, watch = self.watch("implement-connects-the-slice-early")
        (workspace / "bin/todo").write_text("complete) complete_task ;;")
        watch.tick()
        (workspace / "lib/tasks.sh").write_text("echo already_completed")
        watch.tick()

        self.assertTrue(watch.passed())

    def test_building_the_edge_cases_before_connecting_fails(self):
        workspace, watch = self.watch("implement-connects-the-slice-early")
        (workspace / "lib/tasks.sh").write_text("echo already_completed")
        watch.tick()
        (workspace / "bin/todo").write_text("complete) complete_task ;;")
        watch.tick()

        self.assertFalse(watch.passed())

    def test_writing_everything_at_once_is_not_connecting_first(self):
        workspace, watch = self.watch("implement-connects-the-slice-early")
        (workspace / "bin/todo").write_text("complete) complete_task ;; already) exit 1 ;;")
        watch.tick()

        self.assertFalse(watch.passed())

    def test_never_connecting_fails(self):
        workspace, watch = self.watch("implement-connects-the-slice-early")
        (workspace / "bin/todo").write_text("add) add_task ;;")
        watch.tick()
        (workspace / "lib/tasks.sh").write_text("echo already_completed")
        watch.tick()

        self.assertFalse(watch.passed())

    def test_changing_the_test_before_the_code_passes(self):
        workspace, watch = self.watch("implement-writes-the-test-first")
        (workspace / "test_todo.sh").write_text("./todo.sh complete 1")
        watch.tick()
        (workspace / "todo.sh").write_text("complete) ;;")
        watch.tick()

        self.assertTrue(watch.passed())

    def test_changing_the_code_before_the_test_fails(self):
        workspace, watch = self.watch("implement-writes-the-test-first")
        (workspace / "todo.sh").write_text("complete) ;;")
        watch.tick()
        (workspace / "test_todo.sh").write_text("./todo.sh complete 1")
        watch.tick()

        self.assertFalse(watch.passed())


class Acceptance(unittest.TestCase):
    def test_passes_only_when_the_script_succeeds(self):
        with tempfile.TemporaryDirectory() as directory:
            workspace = Path(directory)
            good = workspace / "good.sh"
            good.write_text("exit 0\n")
            bad = workspace / "bad.sh"
            bad.write_text("exit 1\n")

            self.assertTrue(evals.passes_acceptance(good, workspace))
            self.assertFalse(evals.passes_acceptance(bad, workspace))

    def test_a_case_names_its_checks_after_their_files(self):
        with tempfile.TemporaryDirectory() as directory:
            case = Path(directory)
            (case / "acceptance.sh").write_text("exit 0\n")
            (case / "checks").mkdir()
            (case / "checks" / "history-is-slice-shaped.sh").write_text("exit 0\n")

            self.assertEqual(
                evals.shell_checks(case),
                {
                    "behaves-as-specified": case / "acceptance.sh",
                    "history-is-slice-shaped": case / "checks" / "history-is-slice-shaped.sh",
                },
            )

    def test_a_case_without_checks_has_none(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assertEqual(evals.shell_checks(Path(directory)), {})


def case_entry(with_score=0.5, without_score=0.5, graders="1/2", runs=3):
    arm = lambda score: {"valid_runs": runs, "invalid_runs": 0, "score": score, "graders": {"check": graders}, "mean_cost": 1.0, "mean_turns": 10}
    return {"recorded": "2026-11-04", "plugin_version": "4.1.0", "models": ["m"], "runs_per_arm": runs,
            "with": arm(with_score), "without": arm(without_score)}


class Report(unittest.TestCase):
    def test_a_recorded_case_replaces_its_entry_and_keeps_the_others(self):
        previous = {"a": case_entry(0.1), "b": case_entry(0.2)}

        merged = evals.merge_report(previous, {"a": case_entry(0.9)})

        self.assertEqual(merged["a"]["with"]["score"], 0.9)
        self.assertEqual(merged["b"]["with"]["score"], 0.2)

    def test_changes_name_only_what_moved(self):
        previous = {"a": case_entry(0.5, graders="1/3")}
        current = {"a": case_entry(1.0, graders="3/3"), "new": case_entry()}

        changes = evals.changes(previous, current)

        self.assertIn("a [with]: score 0.50 -> 1.00", changes)
        self.assertIn("a [with] check: 1/3 -> 3/3", changes)
        self.assertIn("new: no earlier report", changes)
        self.assertFalse([line for line in changes if "without" in line and "score" in line])

    def test_nothing_moved_means_no_changes(self):
        self.assertEqual(evals.changes({"a": case_entry()}, {"a": case_entry()}), [])

    def test_only_a_full_and_valid_run_of_a_case_may_be_recorded(self):
        runs = [{"case": "a", "arm": arm, "valid": True} for arm in ("with", "without") for _ in range(3)]

        self.assertTrue(evals.recordable(runs, runs_per_arm=3))
        self.assertFalse(evals.recordable(runs[:1], runs_per_arm=1))
        self.assertFalse(evals.recordable([*runs[:-1], {"case": "a", "arm": "without", "valid": False}], runs_per_arm=3))
        self.assertFalse(evals.recordable(runs[:-1], runs_per_arm=3))

    def test_markdown_shows_each_case(self):
        text = evals.render_report({"a": case_entry(0.75)})

        self.assertIn("#### a", text)
        self.assertIn("| check | 1/2 | 1/2 |", text)
        self.assertIn("| Score | 0.75 | 0.50 |", text)

    def test_results_replace_only_the_generated_section(self):
        document = f"before\n{evals.RESULTS_START}\nold\n{evals.RESULTS_END}\nafter\n"

        updated = evals.replace_results(document, "new")

        self.assertEqual(updated, f"before\n{evals.RESULTS_START}\nnew\n{evals.RESULTS_END}\nafter\n")

    def test_a_document_without_the_markers_is_refused(self):
        with self.assertRaises(ValueError):
            evals.replace_results("no markers here", "new")


class CaseDocumentation(unittest.TestCase):
    def test_docs_list_every_case(self):
        docs = (EVALS.parent.parent.parent / "docs" / "evals.md").read_text()

        missing = [case.parent.name for case in EVALS.glob("*/case.yaml") if f"`{case.parent.name}`" not in docs]

        self.assertEqual(missing, [])


class JudgeVerdict(unittest.TestCase):
    def test_the_last_line_decides_after_the_reasoning(self):
        reply = "FAIL: it says AC3 is deferred, so the rubric is met.\n\nPASS\n"

        passed = evals.judge_passed(reply)

        self.assertTrue(passed)

    def test_a_pass_in_the_reasoning_does_not_count(self):
        reply = "PASS looked likely, but the question is never asked.\n\nFAIL\n"

        passed = evals.judge_passed(reply)

        self.assertFalse(passed)

    def test_markdown_around_the_verdict_is_ignored(self):
        reply = "The rubric is met.\n\n**PASS**"

        passed = evals.judge_passed(reply)

        self.assertTrue(passed)

    def test_a_reply_with_no_verdict_fails(self):
        passed = evals.judge_passed("")

        self.assertFalse(passed)


class Regrade(unittest.TestCase):
    def test_judges_saved_reports_again_and_keeps_the_other_checks(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            case = root / "case-a"
            (case / "graders").mkdir(parents=True)
            (case / "graders" / "judged.md").write_text("---\ntype: llm\n---\n\nThe rubric\n")
            (case / "graders" / "matched.md").write_text("---\ntype: regex\npattern: nothing\n---\n")
            (case / "graders" / "file.md").write_text("---\ntype: llm\nfocus: { source: file, path: x }\n---\n\nThe rubric\n")
            saved = root / "trace.jsonl"
            saved.write_text(json.dumps({"type": "result", "result": "the report"}))
            run = {"case": "case-a", "valid": True, "trace": str(saved), "score": 0.25,
                   "graders": {"judged": False, "matched": True, "file": True, "order": False}}
            seen = []

            def judge(meta, rubric, graded):
                seen.append(graded.last_message)
                return True

            evals.regrade_run(run, root, judge)

            self.assertEqual(seen, ["the report"])
            self.assertEqual(run["graders"], {"judged": True, "matched": True, "file": True, "order": False})
            self.assertEqual(run["score"], 0.75)

    def test_an_invalid_run_stays_unscored(self):
        run = {"case": "a", "valid": False, "graders": {}, "score": None, "trace": "missing"}

        evals.regrade_run(run, Path("nowhere"), lambda *_: True)

        self.assertIsNone(run["score"])


class ToolUsedGrader(unittest.TestCase):
    def test_counts_matching_calls_between_min_and_max(self):
        text = trace(
            event({"type": "tool_use", "name": "Edit", "input": {"file_path": "/w/todo.sh"}}, role="assistant"),
            event({"type": "tool_use", "name": "Edit", "input": {"file_path": "/w/other.sh"}}, role="assistant"),
        )
        run = evals.Run(trace=text, last_message="", workspace=None)

        self.assertTrue(evals.grade_tool_used({"tool": "Edit", "input_match": "todo", "min": 1}, run))
        self.assertFalse(evals.grade_tool_used({"tool": "Edit", "input_match": "todo", "min": 0, "max": 0}, run))
        self.assertTrue(evals.grade_tool_used({"tool": "Write", "min": 0, "max": 0}, run))


class FileExistsGrader(unittest.TestCase):
    def test_only_files_created_during_the_run_count(self):
        with tempfile.TemporaryDirectory() as directory:
            workspace = Path(directory)
            (workspace / "old.md").write_text("x")
            before = evals.snapshot(workspace)
            (workspace / "SPEC.md").write_text("x")
            run = evals.Run(trace="", last_message="", workspace=workspace, created=evals.snapshot(workspace) - before)

            self.assertTrue(evals.grade_file_exists({"path": "**/SPEC.md"}, run))
            self.assertFalse(evals.grade_file_exists({"path": "**/SPEC.md", "exists": False}, run))
            self.assertFalse(evals.grade_file_exists({"path": "**/old.md"}, run))


class Validity(unittest.TestCase):
    def healthy(self, init=INIT_WITH):
        return trace(init, BASH_USE, event(bash_result("ok")), RESULT)

    def test_a_healthy_run_has_no_problems(self):
        self.assertEqual(evals.problems(self.healthy(), with_plugin=True, needs_bash=True), [])

    def test_a_run_without_the_expected_plugin_state_is_invalid(self):
        self.assertTrue(evals.problems(self.healthy(INIT_WITHOUT), with_plugin=True, needs_bash=True))
        self.assertTrue(evals.problems(self.healthy(INIT_WITH), with_plugin=False, needs_bash=True))

    def test_the_sandbox_failures_we_have_seen_make_a_run_invalid(self):
        for failure in (
            "Exit code 1\napply-seccomp: write /proc/self/setgroups: Permission denied",
            "Exit code 1\nmktemp: Read-only file system (os error 30)",
            "bwrap: No permissions to create a new namespace",
        ):
            text = trace(INIT_WITH, BASH_USE, event(bash_result(failure, is_error=True)), RESULT)

            self.assertTrue(evals.problems(text, with_plugin=True, needs_bash=True), failure)

    def test_a_failing_test_is_not_an_environment_problem(self):
        text = trace(INIT_WITH, BASH_USE, event(bash_result("FAIL: AC1", is_error=True)), BASH_USE, event(bash_result("ok")), RESULT)

        self.assertEqual(evals.problems(text, with_plugin=True, needs_bash=True), [])

    def test_a_case_needing_bash_must_see_it_succeed(self):
        text = trace(INIT_WITH, BASH_USE, event(bash_result("FAIL", is_error=True)), RESULT)

        self.assertTrue(evals.problems(text, with_plugin=True, needs_bash=True))
        self.assertEqual(evals.problems(trace(INIT_WITH, RESULT), with_plugin=True, needs_bash=False), [])

    def test_a_run_with_no_result_is_invalid(self):
        self.assertTrue(evals.problems(trace(INIT_WITH, BASH_USE, event(bash_result("ok"))), with_plugin=True, needs_bash=True))

    def test_a_sandbox_failure_quoted_by_the_agent_alone_does_not_count(self):
        said = event({"type": "text", "text": "No Read-only file system here"}, role="assistant")

        self.assertEqual(evals.problems(trace(INIT_WITH, said, BASH_USE, event(bash_result("ok")), RESULT), with_plugin=True, needs_bash=True), [])


class CutOffRuns(unittest.TestCase):
    def test_a_run_ending_at_its_turn_limit_is_shown_as_cut_off(self):
        run = {"valid": True, "score": 0.5, "cost": 1.0, "cut_off": True, "stopped": False, "problems": []}

        state = evals.describe_run(run)

        self.assertEqual(state, "score 0.50 CUT OFF at its turn limit $1.00")

    def test_a_stopped_run_says_so(self):
        run = {"valid": True, "score": 1.0, "cost": 0.5, "cut_off": False, "stopped": True, "problems": []}

        state = evals.describe_run(run)

        self.assertEqual(state, "score 1.00 stopped early $0.50")

    def test_an_invalid_run_names_its_problems(self):
        run = {"valid": False, "score": None, "cost": 0.0, "cut_off": False, "stopped": False, "problems": ["a", "b"]}

        state = evals.describe_run(run)

        self.assertEqual(state, "INVALID: a; b $0.00")

    def test_a_run_that_hits_its_turn_limit_is_marked_as_cut_off(self):
        no_bash = "---\nallowed_tools: [Read]\n---\n\nDo it.\n"
        root = stand_in_project(self, extra_files={"acceptance.sh": "true\n", "prompt.md": no_bash}, ending="error_max_turns")
        (root / "out" / "traces").mkdir(parents=True)

        run = evals.run_case(root / "plugin" / "evals" / "a-case", "with", 0, "m", root / "out")

        self.assertTrue(run["cut_off"])
        self.assertTrue(run["valid"], run["problems"])

    def test_only_the_turn_limit_result_counts_as_cut_off(self):
        cut_off = evals.was_cut_off({"type": "result", "subtype": "error_max_turns"})
        finished = evals.was_cut_off({"type": "result", "subtype": "success"})
        interrupted = evals.was_cut_off({"type": "result", "subtype": "error_during_execution"})

        self.assertEqual((cut_off, finished, interrupted), (True, False, False))


class Summary(unittest.TestCase):
    def test_invalid_runs_are_left_out_of_the_score_and_counted(self):
        runs = [
            {"arm": "with", "valid": True, "score": 1.0, "graders": {"a": True}, "cost": 0.1},
            {"arm": "with", "valid": True, "score": 0.0, "graders": {"a": False}, "cost": 0.1},
            {"arm": "with", "valid": False, "score": 1.0, "graders": {"a": True}, "cost": 0.1},
        ]

        arm = evals.summarise(runs, "with")

        self.assertEqual(arm["valid_runs"], 2)
        self.assertEqual(arm["invalid_runs"], 1)
        self.assertEqual(arm["score"], 0.5)
        self.assertEqual(arm["graders"], {"a": "1/2"})


def stand_in_project(test, order=("first", "second"), extra_files=None, ending="success"):
    """A plugin folder with one case, and a `claude` on PATH that writes the case's two files in order."""
    directory = tempfile.TemporaryDirectory()
    test.addCleanup(directory.cleanup)
    root = Path(directory.name)
    case = root / "plugin" / "evals" / "a-case"
    (case / "graders").mkdir(parents=True)
    (case / "prompt.md").write_text("---\nallowed_tools: [Bash]\n---\n\nDo it.\n")
    (case / "case.yaml").write_text("name: a-case\ncontext:\n  scaffold_script: fixture.sh\n")
    (case / "fixture.sh").write_text("true\n")
    (case / "order.json").write_text(json.dumps({
        "name": "first-before-second",
        "before": {"paths": ["first"], "contains": "x"},
        "after": {"paths": ["second"], "contains": "x"},
    }))
    for name, content in (extra_files or {}).items():
        (case / name).parent.mkdir(exist_ok=True)
        (case / name).write_text(content)
    manifest = root / "plugin" / ".claude-plugin" / "plugin.json"
    manifest.parent.mkdir()
    manifest.write_text('{"version": "1.0.0"}')
    interrupted = json.dumps({"type": "result", "subtype": "error_during_execution", "total_cost_usd": 0.5})
    finished = json.dumps({"type": "result", "subtype": ending, "total_cost_usd": 9})
    with_plugin = json.dumps({"type": "system", "subtype": "init", "slash_commands": ["aido:2-implement"], "model": "m"})
    without_plugin = json.dumps({"type": "system", "subtype": "init", "slash_commands": [], "model": "m"})
    stand_in = root / "bin" / "claude"
    stand_in.parent.mkdir()
    stand_in.write_text(f"""#!/bin/sh
printf '%s\\n' "$@" >> {root}/arguments
trap 'echo {json.dumps(interrupted)}; exit 0' INT
case "$*" in
  *--plugin-dir*) echo {json.dumps(with_plugin)} ;;
  *) echo {json.dumps(without_plugin)} ;;
esac
echo x > {order[0]}
sleep 0.5
echo x > {order[1]}
sleep 2 &
wait $!
echo {json.dumps(finished)}
""")
    stand_in.chmod(0o755)
    path = mock.patch.dict(os.environ, {"PATH": f"{stand_in.parent}:{os.environ['PATH']}"})
    path.start()
    test.addCleanup(path.stop)
    return root


def run_main(root, *options):
    report = root / "docs" / "evals"
    report.mkdir(parents=True, exist_ok=True)
    (root / "docs" / "evals.md").write_text(f"{evals.RESULTS_START}\n{evals.RESULTS_END}\n")
    argv = ["evals.py", "--output-dir", str(root / "out"), "--report-dir", str(report), *options]
    with mock.patch.object(evals, "PLUGIN", root / "plugin"), mock.patch.object(sys, "argv", argv):
        with mock.patch("builtins.print"):
            status = evals.main()
    summary = json.loads((root / "out" / "summary.json").read_text())
    return status, summary, report / "latest.json"


class StoppingARun(unittest.TestCase):
    def run_stand_in(self, order=("first", "second"), extra_files=None):
        root = stand_in_project(self, order, extra_files)
        (root / "out" / "traces").mkdir(parents=True)
        return evals.run_case(root / "plugin" / "evals" / "a-case", "with", 0, "m", root / "out")

    def test_a_run_with_only_an_order_check_stops_once_it_is_settled(self):
        run = self.run_stand_in()

        self.assertTrue(run["stopped"])
        self.assertTrue(run["valid"], run["problems"])
        self.assertEqual(run["graders"], {"first-before-second": True})

    def test_the_wrong_order_stops_too_and_fails_the_check(self):
        run = self.run_stand_in(order=("second", "first"))

        self.assertTrue(run["stopped"])
        self.assertTrue(run["valid"], run["problems"])
        self.assertEqual(run["graders"], {"first-before-second": False})

    def test_a_stopped_run_reports_what_it_cost_so_far(self):
        run = self.run_stand_in()

        self.assertEqual(run["cost"], 0.5)

    def test_a_stopped_runs_cost_counts_towards_the_limit(self):
        root = stand_in_project(self)

        _, summary, _ = run_main(root, "--max-cost-usd", "0.4", "--concurrency", "1")

        self.assertEqual(len(summary["runs"]), 1)
        self.assertEqual(summary["cost"], 0.5)

    def test_a_case_with_a_shell_check_runs_to_the_end(self):
        run = self.run_stand_in(extra_files={"checks/needs-the-end.sh": "true\n"})

        self.assertFalse(run["stopped"])
        self.assertEqual(run["cost"], 9)

    def test_a_case_with_a_grader_runs_to_the_end(self):
        grader = "---\ntype: regex\npattern: nothing\nmatch: not_contains\n---\n"

        run = self.run_stand_in(extra_files={"graders/needs-the-end.md": grader})

        self.assertFalse(run["stopped"])
        self.assertEqual(run["cost"], 9)

    def test_a_case_with_an_acceptance_script_runs_to_the_end(self):
        run = self.run_stand_in(extra_files={"acceptance.sh": "true\n"})

        self.assertFalse(run["stopped"])


if __name__ == "__main__":
    unittest.main()
