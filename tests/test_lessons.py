"""Lessons are complete, their shown results are current, and every quiz is answerable."""
from pathlib import Path
import json
import re
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import quiz  # noqa: E402

LEVELS = ("basics", "intermediate", "advanced")
SECTIONS = ("## Common mistakes", "## Your turn", "## Quick quiz", "## Summary")


class LessonTests(unittest.TestCase):
    def lessons(self):
        for level in LEVELS:
            yield from sorted((ROOT / level / "lessons").glob("[0-9][0-9]_*.md"))

    def test_ten_lessons_per_level_with_sql(self):
        for level in LEVELS:
            lessons = sorted((ROOT / level / "lessons").glob("[0-9][0-9]_*.md"))
            self.assertEqual(len(lessons), 10, level)
            for md in lessons:
                self.assertTrue(md.with_suffix(".sql").is_file(), md)

    def test_lesson_structure(self):
        for md in self.lessons():
            text = md.read_text(encoding="utf-8")
            self.assertTrue(text.startswith("# "), md)
            self.assertIn("> **You will", text, md)
            self.assertIn("**Time:**", text, md)
            for section in SECTIONS:
                self.assertIn(section, text, f"{md.name}: {section}")
            self.assertGreaterEqual(len(re.findall(r"^## \d\.", text, re.M)), 3, md)
            self.assertGreaterEqual(len(text.split()), 700, f"{md.name} is too short")
            self.assertRegex(text, r"\*\*Next( level)?:\*\*|You've finished the course", md)

    def test_examples_and_generated_files_are_current(self):
        result = subprocess.run([sys.executable, str(ROOT / "tools" / "lessons.py"), "--check"],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_every_lesson_has_a_quiz(self):
        quizzes = quiz.quizzes()
        for md in self.lessons():
            key = f"{md.parent.parent.name}/{md.name[:2]}"
            self.assertIn(key, quizzes, key)
            self.assertGreaterEqual(len(quizzes[key]["questions"]), 3, key)
            self.assertEqual(quizzes[key]["lesson"], md.relative_to(ROOT).as_posix())

    def test_each_question_has_exactly_one_correct_option(self):
        for key, item in quiz.quizzes().items():
            text = (ROOT / item["lesson"]).read_text(encoding="utf-8")
            for number, question in enumerate(item["questions"], 1):
                hits = [c for c in question["options"]
                        if quiz.fingerprint(key, number, c) == question["answer"]]
                self.assertEqual(len(hits), 1, f"{key} Q{number}")
                self.assertIn(question["section"], text, f"{key} Q{number} points to a missing section")

    def test_answers_are_not_always_the_same_letter(self):
        letters = []
        for key, item in quiz.quizzes().items():
            for number, question in enumerate(item["questions"], 1):
                letters += [c for c in question["options"] if quiz.fingerprint(key, number, c) == question["answer"]]
        counts = {letter: letters.count(letter) for letter in set(letters)}
        self.assertLess(max(counts.values()), 0.6 * len(letters), counts)

    def test_quiz_cli(self):
        key = "basics/00"
        q = quiz.quizzes()[key]["questions"][0]
        right = next(c for c in q["options"] if quiz.fingerprint(key, 1, c) == q["answer"])
        wrong = next(c for c in q["options"] if c != right)
        cli = [sys.executable, str(ROOT / "tools" / "quiz.py"), key, "1"]
        self.assertEqual(subprocess.run(cli + [right], capture_output=True).returncode, 0)
        self.assertEqual(subprocess.run(cli + [wrong], capture_output=True).returncode, 1)


if __name__ == "__main__":
    unittest.main()
