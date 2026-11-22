"""The concept map covers every lesson, and prerequisites always come earlier."""
from pathlib import Path
import json
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
ORDER = ("basics", "intermediate", "advanced")


def position(key: str) -> tuple[int, int]:
    level, number = key.split("/")
    return ORDER.index(level), int(number)


class CurriculumTests(unittest.TestCase):
    def setUp(self):
        self.lessons = json.loads((ROOT / "curriculum" / "concepts.json").read_text(encoding="utf-8"))["lessons"]

    def test_every_lesson_is_mapped(self):
        files = {p.relative_to(ROOT).as_posix() for level in ORDER
                 for p in (ROOT / level / "lessons").glob("[0-9][0-9]_*.md")}
        self.assertEqual({item["file"] for item in self.lessons.values()}, files)

    def test_prerequisites_come_first(self):
        for key, item in self.lessons.items():
            for prereq in item["builds_on"]:
                self.assertIn(prereq, self.lessons, key)
                self.assertLess(position(prereq), position(key), f"{key} builds on later {prereq}")

    def test_concepts_introduced_once(self):
        seen = {}
        for key, item in self.lessons.items():
            self.assertTrue(item["introduces"], key)
            for concept in item["introduces"]:
                self.assertNotIn(concept, seen, f"{concept} in {key} and {seen.get(concept)}")
                seen[concept] = key

    def test_level_indexes_are_current(self):
        result = subprocess.run([sys.executable, str(ROOT / "tools" / "level_index.py"), "--check"],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
