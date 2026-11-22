"""Ensure every lesson has clear prose and executable SQL."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class CourseStructureTests(unittest.TestCase):
    def test_thirty_complete_lessons(self):
        for level in ("basics", "intermediate", "advanced"):
            directory = ROOT / level / "lessons"
            markdown = sorted(directory.glob("*.md"))
            sql = sorted(directory.glob("*.sql"))
            self.assertEqual(len(markdown), 10, level)
            self.assertEqual({p.stem for p in markdown}, {p.stem for p in sql})

    def test_three_projects_per_level(self):
        for level in ("basics", "intermediate", "advanced"):
            directory = ROOT / level / "projects"
            self.assertEqual(len(list(directory.glob("*.sql"))), 3)

    def test_reference_queries(self):
        for level in ("basics", "intermediate", "advanced"):
            self.assertTrue((ROOT / level / "solutions" / "01_reference_queries.sql").is_file())

    def test_level_support_material(self):
        for level in ("basics", "intermediate", "advanced"):
            for name in ("ASSESSMENT.md", "GLOSSARY.md", "worked_examples/README.md"):
                self.assertTrue((ROOT / level / name).is_file(), f"{level}/{name}")
            examples = sorted((ROOT / level / "worked_examples").glob("[0-9][0-9]_*.md"))
            self.assertEqual(len(examples), 6, level)
            for md in examples:
                self.assertTrue(md.with_suffix(".sql").is_file(), md)

    def test_relative_links_resolve(self):
        import re
        skip = {".git", "node_modules"}
        for md in ROOT.rglob("*.md"):
            if skip & set(md.parts):
                continue
            for target in re.findall(r"\]\(([^)#\s]+)(?:#[^)]*)?\)", md.read_text(encoding="utf-8")):
                if "://" in target or target.startswith("mailto:"):
                    continue
                self.assertTrue((md.parent / target).exists(), f"{md.relative_to(ROOT)} -> {target}")

    def test_exercise_sets(self):
        for level in ("basics", "intermediate", "advanced"):
            content = (ROOT / level / "exercises" / "README.md").read_text(encoding="utf-8")
            self.assertRegex(content, r"Practice · \d+ tasks")
            self.assertIn("<!-- exercises:start -->", content)


if __name__ == "__main__":
    unittest.main()
