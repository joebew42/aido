import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).parent))
import evals

EVALS = Path(__file__).parent.parent / "plugins" / "aido" / "evals"
FINISHED = EVALS / "implement-finishes-the-feature" / "graders"


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
        green = FINISHED / "suite-ends-green.md"

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

    def test_an_edge_case_named_in_capitals_counts_as_an_edge_case(self):
        workspace, watch = self.watch("implement-connects-the-slice-early")
        (workspace / "bin/todo").write_text("complete) complete_task ;;")
        watch.tick()
        (workspace / "lib/tasks.sh").write_text("TASK_ALREADY_COMPLETED=3")
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

    def test_ticking_item_1_before_building_item_2_passes(self):
        workspace, watch = self.watch("implement-records-each-item")
        (workspace / "SPEC.md").write_text("## Progress\n\n- [x] 1. complete a task\n")
        watch.tick()
        (workspace / "todo.sh").write_text('  list) grep " open$" tasks.txt ;;')
        watch.tick()

        self.assertTrue(watch.passed())

    def test_building_item_2_before_ticking_item_1_fails(self):
        workspace, watch = self.watch("implement-records-each-item")
        (workspace / "SPEC.md").write_text("## Plan\n\n1. **complete a task** (AC1)\n")
        (workspace / "todo.sh").write_text('  list) grep " open$" tasks.txt ;;')
        watch.tick()
        (workspace / "SPEC.md").write_text("## Progress\n\n- [x] 1. complete a task\n")
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

    def test_markdown_shows_the_mean_mutation_score_when_an_arm_has_one(self):
        entry = case_entry()
        entry["with"]["mean_mutation_score"] = 0.8

        text = evals.render_report({"a": entry})

        self.assertIn("| Mean mutation score | 0.80 | n/a |\n| Mean cost |", text)

    def test_markdown_leaves_out_the_mutation_score_when_no_arm_has_one(self):
        text = evals.render_report({"a": case_entry()})

        self.assertNotIn("mutation", text)

    def test_a_comparison_names_its_baseline(self):
        entry = case_entry(0.75)
        comparison = {**entry, "current": entry["with"], "baseline": entry["without"], "baseline_ref": "main", "baseline_version": "4.6.0"}
        arms = evals.baseline_arms(Path("current"), Path("baseline"))

        text = evals.render_report({"a": comparison}, arms)

        self.assertIn("Recorded 2026-11-04 on plugin version 4.1.0 against `main` at plugin version 4.6.0, with m, 3 runs per arm.", text)
        self.assertIn("| Measure | This change | Baseline |", text)
        self.assertIn("| Score | 0.75 | 0.50 |", text)

    def test_a_recorded_comparison_keeps_its_baseline_in_its_own_file_and_section(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            document = root / "evals.md"
            document.write_text(f"{evals.RESULTS_START}\n{evals.RESULTS_END}\n<!-- b:start -->\n<!-- b:end -->\n")
            arms = evals.baseline_arms(Path("current"), Path("baseline"))
            runs = [{"case": "a", "arm": arm.name, "valid": True, "score": 1.0, "graders": {}, "cost": 1.0, "turns": 5, "model": "m"}
                    for arm in arms for _ in range(3)]

            results = evals.Results(root / "comparison.json", document, ("<!-- b:start -->", "<!-- b:end -->"), arms)

            with mock.patch("builtins.print"):
                evals.update_report(results, [Path("a")], runs, 3, "4.7.0", {"baseline_ref": "main", "baseline_version": "4.6.0"})

            entry = json.loads(results.path.read_text())["a"]
            self.assertEqual((entry["baseline_ref"], entry["baseline_version"]), ("main", "4.6.0"))
            self.assertEqual(sorted(entry), ["baseline", "baseline_ref", "baseline_version", "current", "models", "plugin_version", "recorded", "runs_per_arm"])
            self.assertIn("against `main` at plugin version 4.6.0", document.read_text().split("<!-- b:start -->")[1])

    def test_results_replace_only_the_generated_section(self):
        document = f"before\n{evals.RESULTS_START}\nold\n{evals.RESULTS_END}\nafter\n"

        updated = evals.replace_results(document, "new")

        self.assertEqual(updated, f"before\n{evals.RESULTS_START}\nnew\n{evals.RESULTS_END}\nafter\n")

    def test_results_can_replace_another_generated_section(self):
        document = f"{evals.RESULTS_START}\nkept\n{evals.RESULTS_END}\n<!-- b:start -->\nold\n<!-- b:end -->\n"

        updated = evals.replace_results(document, "new", ("<!-- b:start -->", "<!-- b:end -->"))

        self.assertEqual(updated, f"{evals.RESULTS_START}\nkept\n{evals.RESULTS_END}\n<!-- b:start -->\nnew\n<!-- b:end -->\n")

    def test_a_document_without_the_markers_is_refused(self):
        with self.assertRaises(ValueError):
            evals.replace_results("no markers here", "new")


class ImplementCases(unittest.TestCase):
    def checks_of(self, name):
        case = EVALS / name
        graders = {path.stem for path in (case / "graders").glob("*.md")}
        return graders | set(evals.shell_checks(case))

    def test_the_order_cases_have_only_their_order_check_so_they_stop_early(self):
        for name in (
            "implement-connects-the-slice-early",
            "implement-grows-an-inside-out-item-by-layer",
            "implement-writes-the-test-first",
            "implement-records-each-item",
        ):
            with self.subTest(name):
                checks = self.checks_of(name)
                has_order_check = (EVALS / name / "order.json").is_file()

                self.assertEqual(checks, set())
                self.assertTrue(has_order_check)

    def test_one_small_case_checks_the_finished_feature(self):
        checks = self.checks_of("implement-finishes-the-feature")

        self.assertEqual(checks, {"suite-ends-green", "behaves-as-specified", "inner-units-have-tests"})

    def test_the_trap_case_checks_the_finished_feature_too(self):
        checks = self.checks_of("implement-respects-a-hidden-helper")

        self.assertEqual(checks, {"suite-ends-green", "behaves-as-specified", "inner-units-have-tests"})


LOOP = EVALS / "implement-loops-over-the-plan"
LOOP_PROGRESS = """
## Progress

- [x] 1. complete a task
- [x] 2. list the open tasks
{acceptance}
- AC1: met — `test_todo.sh`
- AC2: met — `test_todo.sh`
"""


class LoopRecordsEachItem(unittest.TestCase):
    def finished_with(self, acceptance):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        workspace = Path(directory.name)
        subprocess.run(["bash", str(LOOP / "fixture.sh")], cwd=workspace, check=True, capture_output=True)
        for subject in ("feat: complete a task", "feat: list the open tasks"):
            subprocess.run(["git", "commit", "-q", "--allow-empty", "-m", subject], cwd=workspace, check=True)
        with (workspace / "SPEC.md").open("a") as spec:
            spec.write(LOOP_PROGRESS.format(acceptance=acceptance))
        subprocess.run(["git", "commit", "-q", "-am", "docs: update feature specification"], cwd=workspace, check=True)
        return workspace

    def check(self, workspace):
        return subprocess.run(["sh", str(LOOP / "checks" / "each-item-is-recorded.sh")], cwd=workspace, capture_output=True)

    def test_results_under_their_heading_pass(self):
        workspace = self.finished_with("\n### Acceptance\n")

        result = self.check(workspace)

        self.assertEqual(result.returncode, 0)

    def test_results_without_their_heading_fail(self):
        workspace = self.finished_with("")

        result = self.check(workspace)

        self.assertNotEqual(result.returncode, 0)


CLASH = EVALS / "implement-leaves-contradictory-criteria-unresolved"
CLASH_PROGRESS = """
## Progress

- [x] 1. complete a task
- [x] 2. list the open tasks
{acceptance}
- AC1: met — `test_todo.sh`
- AC2: {ac2}
"""


class ClashLeftUnresolved(unittest.TestCase):
    def finished_with(self, acceptance="\n### Acceptance\n", ac2="deferred — it clashes with AC1"):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        workspace = Path(directory.name)
        subprocess.run(["bash", str(CLASH / "fixture.sh")], cwd=workspace, check=True, capture_output=True)
        with (workspace / "SPEC.md").open("a") as spec:
            spec.write(CLASH_PROGRESS.format(acceptance=acceptance, ac2=ac2))
        return workspace

    def check(self, workspace):
        script = CLASH / "checks" / "leaves-the-clash-unresolved.sh"
        return subprocess.run(["sh", str(script)], cwd=workspace, capture_output=True)

    def test_one_criterion_deferred_passes(self):
        workspace = self.finished_with()

        result = self.check(workspace)

        self.assertEqual(result.returncode, 0)

    def test_both_criteria_met_fail(self):
        workspace = self.finished_with(ac2="met — `test_todo.sh`")

        result = self.check(workspace)

        self.assertNotEqual(result.returncode, 0)

    def test_results_without_their_heading_fail(self):
        workspace = self.finished_with(acceptance="")

        result = self.check(workspace)

        self.assertNotEqual(result.returncode, 0)

    def test_a_criterion_reworded_without_the_user_fails(self):
        workspace = self.finished_with()
        spec = workspace / "SPEC.md"
        spec.write_text(spec.read_text().replace("prints only the open tasks", "prints every task"))

        result = self.check(workspace)

        self.assertNotEqual(result.returncode, 0)


RAISED = EVALS / "plan-raises-contradictory-criteria"
REWORDED = EVALS / "plan-rewords-contradictory-criteria"


class ClashReworded(unittest.TestCase):
    def scaffolded(self, case):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        workspace = Path(directory.name)
        subprocess.run(["bash", str(case / "fixture.sh")], cwd=workspace, check=True, capture_output=True)
        return workspace

    def test_starts_from_the_draft_whose_clash_planning_raises(self):
        raised = self.scaffolded(RAISED)

        reworded = self.scaffolded(REWORDED)

        for name in ("SPEC.draft.md", "todo.sh"):
            with self.subTest(name):
                self.assertEqual((reworded / name).read_text(), (raised / name).read_text())

    def test_checks_the_reworded_draft_the_approval_and_the_code(self):
        graders = {path.stem for path in (REWORDED / "graders").glob("*.md")}

        self.assertEqual(graders, {
            "rewords-ac1-to-agree",
            "keeps-the-criteria-ids",
            "approves-no-spec-by-itself",
            "waits-for-approval",
            "leaves-the-code-alone",
        })

    def test_judges_the_rewording_on_the_draft(self):
        for name in ("rewords-ac1-to-agree", "keeps-the-criteria-ids"):
            with self.subTest(name):
                meta, _ = evals.parse_frontmatter((REWORDED / "graders" / f"{name}.md").read_text())

                self.assertEqual(meta["focus"], {"source": "file", "path": "SPEC.draft.md"})


TRAP = EVALS / "implement-respects-a-hidden-helper"
RENAME_SOLUTION = """cat >> lib/task_store.sh <<'EOF'

store_replace() {{
  perl -pi -e "s/^$1\\|.*/$2/" "$(store_file)"
}}
EOF
cat >> lib/tasks.sh <<'EOF'

rename_task() {{
  title={title}
  store_replace "$1" "$1|open|$title"
  echo "renamed: $title"
}}
EOF
perl -pi -e 's/^  add\\) add_task "\\$2" "\\$3" ;;$/$&\\n  rename) rename_task "\\$2" "\\$3" ;;/' bin/todo
"""


class HiddenHelperTrap(unittest.TestCase):
    def solved_with(self, title):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        workspace = Path(directory.name)
        subprocess.run(["bash", str(TRAP / "fixture.sh")], cwd=workspace, check=True, capture_output=True)
        subprocess.run(["bash", "-c", RENAME_SOLUTION.format(title=title)], cwd=workspace, check=True, capture_output=True)
        return workspace

    def test_renaming_through_the_helper_passes_the_hidden_test(self):
        workspace = self.solved_with('"$(task_title "$2")"')

        passed = evals.passes_acceptance(TRAP / "acceptance.sh", workspace)

        self.assertTrue(passed)

    def test_renaming_with_the_title_as_typed_fails_the_hidden_test(self):
        workspace = self.solved_with('"$2"')

        passed = evals.passes_acceptance(TRAP / "acceptance.sh", workspace)

        self.assertFalse(passed)

    def test_the_plan_marks_the_item_inside_out_citing_the_helper(self):
        workspace = self.solved_with('"$2"')

        plan = (workspace / "SPEC.md").read_text().split("## Plan", 1)[1]

        self.assertRegex(plan, r"inside-out: follows .*`task_title`")


class CaseDocumentation(unittest.TestCase):
    def test_docs_list_every_case(self):
        docs = (EVALS.parent.parent.parent / "docs" / "evals.md").read_text()

        missing = [case.parent.name for case in EVALS.glob("*/case.yaml") if f"`{case.parent.name}`" not in docs]

        self.assertEqual(missing, [])

    def test_docs_name_what_each_step_check_guards(self):
        docs = (EVALS.parent.parent.parent / "docs" / "evals.md").read_text()
        section = docs.partition("### What the step checks guard\n")[2].partition("\n### ")[0]

        checks = [json.loads(order.read_text())["name"] for order in EVALS.glob("*/order.json")]
        missing = [check for check in checks if f"`{check}`" not in section]

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

        run = evals.run_case(root / "plugin" / "evals" / "a-case", plugin_arm(root), 0, "m", root / "out")

        self.assertTrue(run["cut_off"])
        self.assertTrue(run["valid"], run["problems"])

    def test_only_the_turn_limit_result_counts_as_cut_off(self):
        cut_off = evals.was_cut_off({"type": "result", "subtype": "error_max_turns"})
        finished = evals.was_cut_off({"type": "result", "subtype": "success"})
        interrupted = evals.was_cut_off({"type": "result", "subtype": "error_during_execution"})

        self.assertEqual((cut_off, finished, interrupted), (True, False, False))


class StoppingAtTheFirstFailure(unittest.TestCase):
    def test_a_failed_check_starts_no_new_runs_and_records_nothing(self):
        root = stand_in_project(self, order=("second", "first"))

        status, summary, latest = run_main(root, "--stop-at-first-failure", "--concurrency", "1")

        self.assertEqual(status, 2)
        self.assertEqual(len(summary["runs"]), 1)
        self.assertFalse(latest.exists())

    def test_without_the_option_every_run_happens(self):
        root = stand_in_project(self, order=("second", "first"))

        _, summary, _ = run_main(root, "--concurrency", "6")

        self.assertEqual(len(summary["runs"]), 6)

    def test_passing_runs_are_all_made_and_recorded(self):
        root = stand_in_project(self)

        status, summary, latest = run_main(root, "--stop-at-first-failure", "--concurrency", "6")

        self.assertEqual(status, 0)
        self.assertEqual(len(summary["runs"]), 6)
        self.assertTrue(latest.exists())


class ChoosingThePlugin(unittest.TestCase):
    def test_runs_use_the_chosen_plugin(self):
        root = stand_in_project(self)
        (root / "out" / "traces").mkdir(parents=True)

        evals.run_case(root / "plugin" / "evals" / "a-case", plugin_arm(root / "a-broken-copy"), 0, "m", root / "out")

        self.assertIn(str(root / "a-broken-copy"), (root / "arguments").read_text().splitlines())

    def test_a_run_of_another_plugin_records_nothing(self):
        root = stand_in_project(self)

        status, summary, latest = run_main(root, "--plugin-dir", str(root / "a-broken-copy"), "--concurrency", "6")

        self.assertEqual(status, 0)
        self.assertEqual(len(summary["runs"]), 6)
        self.assertFalse(latest.exists())


class BaselineCopy(unittest.TestCase):
    def test_holds_the_plugin_as_committed_at_the_ref(self):
        root = stand_in_project(self)
        commit_the_plugin(root)
        (root / "plugin" / ".claude-plugin" / "plugin.json").write_text('{"version": "2.0.0"}')
        directory = Path(tempfile.mkdtemp(dir=root))

        with mock.patch.object(evals, "ROOT", root), mock.patch.object(evals, "PLUGIN", root / "plugin"):
            copy = evals.baseline_copy("HEAD", directory)

        self.assertEqual(json.loads((copy / ".claude-plugin" / "plugin.json").read_text()), {"version": "1.0.0"})
        self.assertTrue((copy / "evals" / "a-case" / "prompt.md").is_file())

    def test_an_unknown_ref_is_refused(self):
        root = stand_in_project(self)
        commit_the_plugin(root)

        with mock.patch.object(evals, "ROOT", root), mock.patch.object(evals, "PLUGIN", root / "plugin"):
            with self.assertRaisesRegex(ValueError, "no-such-ref"):
                evals.baseline_copy("no-such-ref", root)


class ComparingWithABaseline(unittest.TestCase):
    def test_the_second_arm_runs_the_plugin_from_the_baseline_ref(self):
        root = stand_in_project(self)
        commit_the_plugin(root)
        (root / "plugin" / ".claude-plugin" / "plugin.json").write_text('{"version": "2.0.0"}')

        status, summary, _ = run_main(root, "--baseline", "HEAD", "--concurrency", "6")

        self.assertEqual(status, 0, [run["problems"] for run in summary["runs"]])
        self.assertEqual(plugin_versions_seen(root), ["1.0.0"] * 3 + ["2.0.0"] * 3)

    def test_a_full_comparison_is_recorded_in_its_own_section_naming_the_baseline_ref(self):
        root = stand_in_project(self)
        commit_the_plugin(root)

        _, _, latest = run_main(root, "--baseline", "HEAD", "--concurrency", "6")

        document = (root / "docs" / "evals.md").read_text()
        self.assertFalse(latest.exists())
        self.assertEqual(generated_section(document, evals.RESULTS_START, evals.RESULTS_END), "")
        self.assertIn("#### a-case", generated_section(document, evals.COMPARISON_START, evals.COMPARISON_END))
        self.assertIn("`HEAD`", generated_section(document, evals.COMPARISON_START, evals.COMPARISON_END))

    def test_a_comparison_with_fewer_runs_is_not_recorded(self):
        root = stand_in_project(self)
        commit_the_plugin(root)

        run_main(root, "--baseline", "HEAD", "--runs", "2", "--concurrency", "6")

        document = (root / "docs" / "evals.md").read_text()
        self.assertEqual(generated_section(document, evals.COMPARISON_START, evals.COMPARISON_END), "")


HIDDEN_GREETING_TEST = """. lib/greet.sh
greet ann | grep -q "hello ann" && greet ann | grep -q "bye"
"""


SPEC_COMMIT = """git init -q
git config user.name Test
git config user.email test@example.com
echo spec > SPEC.md
git add SPEC.md
git commit -q -m "docs: feature specification"
"""


GREETING = """mkdir -p lib
cat > lib/greet.sh <<'EOF'
greet() {{
{lines}
}}
EOF
"""
OWN_TEST = """cat > test_greet.sh <<'EOF'
. lib/greet.sh
greet ann | grep -q "hello ann"
EOF
"""
HALF_TESTED_FIXTURE = SPEC_COMMIT + GREETING.format(lines='  echo "hello $1"\n  echo "bye"') + OWN_TEST


WORDS = """mkdir -p lib
printf 'HELLO=hello\\nBYE=bye\\n' > lib/words.sh
"""
HIDDEN_WORDS_TEST = """. lib/words.sh
[ "$HELLO" = hello ] && [ "$BYE" = bye ]
"""


class MutantsOfTheAgentsCode(unittest.TestCase):
    def score(self, fixture, hidden_test=HIDDEN_GREETING_TEST, test_command="sh test_greet.sh"):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        workspace = self.workspace = Path(directory.name) / "workspace"
        workspace.mkdir()
        subprocess.run(["bash", "-c", fixture], cwd=workspace, check=True, capture_output=True)
        acceptance = Path(directory.name) / "acceptance.sh"
        acceptance.write_text(hidden_test)
        return evals.mutation_score(workspace, acceptance, test_command)

    def test_no_changed_line_gives_no_score(self):
        score = self.score(SPEC_COMMIT, hidden_test="true\n")

        self.assertIsNone(score)

    def test_a_deleted_line_that_both_tests_notice_is_caught(self):
        fixture = SPEC_COMMIT + WORDS + f"cat > test_words.sh <<'EOF'\n{HIDDEN_WORDS_TEST}EOF\n"

        score = self.score(fixture, hidden_test=HIDDEN_WORDS_TEST, test_command="sh test_words.sh")

        self.assertEqual(score, 1.0)

    def test_a_deleted_line_that_only_the_hidden_test_notices_is_missed(self):
        fixture = SPEC_COMMIT + WORDS + "echo '. lib/words.sh; [ \"$HELLO\" = hello ]' > test_words.sh\n"

        score = self.score(fixture, hidden_test=HIDDEN_WORDS_TEST, test_command="sh test_words.sh")

        self.assertEqual(score, 0.5)

    def test_only_lines_written_since_the_specification_are_broken(self):
        fixture = (
            "git init -q\ngit config user.name Test\ngit config user.email test@example.com\n"
            "mkdir lib\necho HELLO=hello > lib/words.sh\ngit add lib\ngit commit -q -m 'feat: hello'\n"
            "echo spec > SPEC.md\ngit add SPEC.md\ngit commit -q -m 'docs: feature specification'\n"
            "echo BYE=bye >> lib/words.sh\ngit commit -q -am 'feat: bye'\n"
            "echo '. lib/words.sh; [ \"$BYE\" = bye ]' > test_words.sh\n"
        )

        score = self.score(fixture, hidden_test=HIDDEN_WORDS_TEST, test_command="sh test_words.sh")

        self.assertEqual(score, 1.0)

    def test_the_agents_code_is_left_as_it_was(self):
        fixture = SPEC_COMMIT + WORDS + "echo '. lib/words.sh' > test_words.sh\n"

        self.score(fixture, hidden_test=HIDDEN_WORDS_TEST, test_command="sh test_words.sh")

        left = (self.workspace / "lib" / "words.sh").read_text()
        self.assertEqual(left, "HELLO=hello\nBYE=bye\n")

    def test_a_deletion_that_breaks_the_syntax_is_not_counted(self):
        fixture = SPEC_COMMIT + GREETING.format(lines='  echo "hello $1"\n  echo "bye"') + OWN_TEST

        score = self.score(fixture)

        self.assertEqual(score, 0.5)


class MutationScore(unittest.TestCase):
    def test_the_results_show_a_mean_mutation_score_per_arm(self):
        root = stand_in_project(self, extra_files={
            "case.yaml": "name: a-case\ncontext:\n  scaffold_script: fixture.sh\n  test_command: sh test_greet.sh\n",
            "fixture.sh": HALF_TESTED_FIXTURE,
            "acceptance.sh": HIDDEN_GREETING_TEST,
            "prompt.md": "---\nallowed_tools: [Read]\n---\n\nDo it.\n",
        })

        status, summary, latest = run_main(root, "--concurrency", "6")

        self.assertEqual(status, 0, [run["problems"] for run in summary["runs"]])
        entry = json.loads(latest.read_text())["a-case"]
        self.assertEqual((entry["with"]["mean_mutation_score"], entry["without"]["mean_mutation_score"]), (0.5, 0.5))
        self.assertIn("| Mean mutation score | 0.50 | 0.50 |", (root / "docs" / "evals.md").read_text())


class FailuresThatStopARound(unittest.TestCase):
    def test_a_failed_check_in_the_with_aido_arm_counts(self):
        run = {"case": "a", "arm": "with", "valid": True, "graders": {"x": True, "y": False}}

        self.assertTrue(evals.fails_a_check(run))

    def test_a_failed_check_in_the_without_aido_arm_does_not_count(self):
        run = {"case": "a", "arm": "without", "valid": True, "graders": {"x": False}}

        self.assertFalse(evals.fails_a_check(run))

    def test_in_a_comparison_only_the_current_tree_counts(self):
        arms = evals.baseline_arms(Path("current"), Path("baseline"))
        current = {"case": "a", "arm": "current", "valid": True, "graders": {"x": False}}
        baseline = {"case": "a", "arm": "baseline", "valid": True, "graders": {"x": False}}

        counted = (evals.fails_a_check(current, arms), evals.fails_a_check(baseline, arms))

        self.assertEqual(counted, (True, False))

    def test_an_invalid_run_does_not_count(self):
        run = {"case": "a", "arm": "with", "valid": False, "graders": {}}

        self.assertFalse(evals.fails_a_check(run))

    def test_a_case_that_failed_is_left_out_even_when_all_its_runs_happened(self):
        failed = {"case": "a", "arm": "with", "valid": True, "graders": {"x": False}}
        passed = {"case": "b", "arm": "with", "valid": True, "graders": {"x": True}}

        kept = evals.without_failed_cases([failed, passed])

        self.assertEqual(kept, [passed])


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

    def test_the_mean_mutation_score_counts_the_valid_runs_that_have_one(self):
        runs = [
            {"arm": "with", "valid": True, "score": 1.0, "graders": {}, "cost": 0.1, "mutation_score": 1.0},
            {"arm": "with", "valid": True, "score": 1.0, "graders": {}, "cost": 0.1, "mutation_score": 0.5},
            {"arm": "with", "valid": True, "score": 1.0, "graders": {}, "cost": 0.1, "mutation_score": None},
            {"arm": "with", "valid": False, "score": None, "graders": {}, "cost": 0.1, "mutation_score": 0.0},
        ]

        arm = evals.summarise(runs, "with")

        self.assertEqual(arm["mean_mutation_score"], 0.75)

    def test_runs_without_a_mutation_score_have_no_mean(self):
        runs = [{"arm": "with", "valid": True, "score": 1.0, "graders": {}, "cost": 0.1}]

        arm = evals.summarise(runs, "with")

        self.assertNotIn("mean_mutation_score", arm)


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
previous=""
for argument in "$@"; do
  if [ "$previous" = "--plugin-dir" ]; then printf '%s\\n' "$(cat "$argument/.claude-plugin/plugin.json")" >> {root}/plugins-seen; fi
  previous="$argument"
done
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


def commit_the_plugin(root):
    """Makes the stand-in project a repository whose last commit holds the plugin as it is now."""
    git = lambda *arguments: subprocess.run(["git", "-C", str(root), *arguments], check=True, capture_output=True)
    git("init", "-q")
    git("add", "plugin")
    git("-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-q", "-m", "the baseline")


def plugin_versions_seen(root):
    return sorted(json.loads(line)["version"] for line in (root / "plugins-seen").read_text().splitlines())


def generated_section(document, start, end):
    return document[document.index(start) + len(start):document.index(end)].strip()


def plugin_arm(plugin):
    return evals.plugin_arms(plugin)[0]


def run_main(root, *options):
    report = root / "docs" / "evals"
    report.mkdir(parents=True, exist_ok=True)
    (root / "docs" / "evals.md").write_text(f"{evals.RESULTS_START}\n{evals.RESULTS_END}\n{evals.COMPARISON_START}\n{evals.COMPARISON_END}\n")
    argv = ["evals.py", "--output-dir", str(root / "out"), "--report-dir", str(report), *options]
    with mock.patch.object(evals, "ROOT", root), mock.patch.object(evals, "PLUGIN", root / "plugin"), mock.patch.object(sys, "argv", argv):
        with mock.patch("builtins.print"):
            status = evals.main()
    summary = json.loads((root / "out" / "summary.json").read_text())
    return status, summary, report / "latest.json"


class StoppingARun(unittest.TestCase):
    def run_stand_in(self, order=("first", "second"), extra_files=None):
        root = stand_in_project(self, order, extra_files)
        (root / "out" / "traces").mkdir(parents=True)
        return evals.run_case(root / "plugin" / "evals" / "a-case", plugin_arm(root), 0, "m", root / "out")

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
