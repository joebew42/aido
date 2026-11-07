import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


class StaticChecks(unittest.TestCase):
    def copy_of_the_repository(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        copy = Path(directory.name)
        shutil.copytree(ROOT / "plugins" / "aido" / "skills", copy / "plugins" / "aido" / "skills")
        shutil.copytree(ROOT / "plugins" / "aido" / "guidelines", copy / "plugins" / "aido" / "guidelines")
        shutil.copytree(ROOT / "plugins" / "aido" / "evals", copy / "plugins" / "aido" / "evals", ignore=shutil.ignore_patterns("results"))
        shutil.copytree(ROOT / "docs" / "readme", copy / "docs" / "readme")
        shutil.copy(ROOT / "README.md", copy / "README.md")
        (copy / "tests").mkdir()
        shutil.copy(ROOT / "tests" / "skills.sh", copy / "tests" / "skills.sh")
        return copy

    def run_checks(self, copy):
        return subprocess.run(["bash", str(copy / "tests" / "skills.sh")], capture_output=True, text=True)

    def replace_in(self, path, old, new):
        text = path.read_text()
        self.assertIn(old, text)
        path.write_text(text.replace(old, new))

    def test_the_repository_passes(self):
        result = self.run_checks(self.copy_of_the_repository())

        self.assertEqual(result.returncode, 0, result.stdout)

    def test_a_reference_to_a_missing_section_fails(self):
        copy = self.copy_of_the_repository()
        self.replace_in(copy / "plugins" / "aido" / "guidelines" / "tdd.md", "## The Modes", "## The Ways")

        result = self.run_checks(copy)

        self.assertEqual(result.returncode, 1)
        self.assertIn('FAIL - "The Modes" exists in guidelines/tdd.md', result.stdout)

    def test_a_reference_to_a_missing_file_fails(self):
        copy = self.copy_of_the_repository()
        (copy / "plugins" / "aido" / "guidelines" / "tdd.md").rename(copy / "plugins" / "aido" / "guidelines" / "tests.md")

        result = self.run_checks(copy)

        self.assertEqual(result.returncode, 1)
        self.assertIn('FAIL - "The Modes" exists in guidelines/tdd.md', result.stdout)

    def test_a_removed_approval_question_fails(self):
        copy = self.copy_of_the_repository()
        self.replace_in(copy / "plugins" / "aido" / "skills" / "1-plan" / "SKILL.md", '"Is the plan approved?"', '"Good?"')

        result = self.run_checks(copy)

        self.assertEqual(result.returncode, 1)
        self.assertIn("FAIL - skills/1-plan/SKILL.md keeps: Is the plan approved?", result.stdout)

    def test_a_removed_evidence_rule_fails(self):
        copy = self.copy_of_the_repository()
        skill = copy / "plugins" / "aido" / "skills" / "2-implement" / "SKILL.md"
        self.replace_in(skill, "Never record a criterion as met without its\nevidence.", "Record every criterion.")

        result = self.run_checks(copy)

        self.assertEqual(result.returncode, 1)
        self.assertIn("FAIL - skills/2-implement/SKILL.md keeps: Never record a criterion as met without its evidence", result.stdout)

    def test_a_skill_without_the_ending_block_fails(self):
        copy = self.copy_of_the_repository()
        skill = copy / "plugins" / "aido" / "skills" / "verify" / "SKILL.md"
        self.replace_in(skill, '"Ending a Skill" in', '"Ending" in')

        result = self.run_checks(copy)

        self.assertEqual(result.returncode, 1)
        self.assertIn("FAIL - verify ends with the ending block", result.stdout)

    def test_a_reference_to_a_missing_skill_fails(self):
        copy = self.copy_of_the_repository()
        self.replace_in(copy / "README.md", "`/aido:verify`", "`/aido:check`")

        result = self.run_checks(copy)

        self.assertEqual(result.returncode, 1)
        self.assertIn("FAIL - /aido:check names an existing skill", result.stdout)

    def test_a_skill_grader_matching_no_skill_fails(self):
        copy = self.copy_of_the_repository()
        grader = copy / "plugins" / "aido" / "evals" / "implement-offers-to-organize" / "graders" / "starts-no-organizing.md"
        self.replace_in(grader, "input_match: 'organize-commits'", "input_match: 'tidy-commits'")

        result = self.run_checks(copy)

        self.assertEqual(result.returncode, 1)
        self.assertIn("FAIL - implement-offers-to-organize/graders/starts-no-organizing.md matches an existing skill", result.stdout)


if __name__ == "__main__":
    unittest.main()
