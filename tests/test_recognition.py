"""Achievement claims, the level verifier and the recognition file updates."""
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import check_claim  # noqa: E402
import recognition  # noqa: E402
import verify_level  # noqa: E402


class ClaimTests(unittest.TestCase):
    def test_parse_claim(self):
        self.assertEqual(check_claim.parse_claim("level: basics\nname: Ada L.\n"), ("basics", "Ada L."))
        self.assertEqual(check_claim.parse_claim("# hi\nlevel: Advanced # comment\n"), ("advanced", ""))
        for bad in ("level: expert", "name: Ada", "level: basics\nname: <script>"):
            with self.assertRaises(check_claim.ClaimError):
                check_claim.parse_claim(bad)

    def test_allowed_files(self):
        files = ["achievements/claims/ada.md", "practice/starter/PB01.sql", "interview/starter/B01.sql"]
        self.assertEqual(check_claim.validate_files(files, "ada"), "achievements/claims/ada.md")

    def test_rejected_files(self):
        cases = [
            ["achievements/claims/ada.md", "tools/practice.py"],
            ["achievements/claims/ada.md", "practice/answers/PB01.sql"],
            ["achievements/claims/ada.md", "practice/basics.json"],
            ["achievements/claims/someone-else.md"],
            ["achievements/claims/ada.md", "achievements/claims/bob.md"],
            ["practice/starter/PB01.sql"],
        ]
        for files in cases:
            with self.assertRaises(check_claim.ClaimError, msg=files):
                check_claim.validate_files(files, "ada")


class VerifyLevelTests(unittest.TestCase):
    def test_untouched_course_is_incomplete(self):
        report = verify_level.verify("basics")
        self.assertEqual(report["total"], 36)
        self.assertEqual(report["passed"], 0)
        self.assertFalse(report["complete"])

    def test_copied_reference_is_flagged(self):
        with tempfile.TemporaryDirectory() as tmp:
            answer = Path(tmp) / "PB01.sql"
            reference = ROOT / "practice" / "answers" / "PB01.sql"
            answer.write_text("-- mine\n" + reference.read_text(encoding="utf-8").upper(), encoding="utf-8")
            self.assertTrue(verify_level.copied_reference(answer, reference))
            answer.write_text("SELECT sku, product_name FROM products WHERE active <> 0 ORDER BY 1;\n", encoding="utf-8")
            self.assertFalse(verify_level.copied_reference(answer, reference))


class RecognitionFileTests(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp)
        for name in ("ACHIEVEMENTS.md", "CONTRIBUTORS.md"):
            shutil.copy(ROOT / name, self.tmp / name)
        patches = [mock.patch.object(recognition, "ACHIEVEMENTS", self.tmp / "ACHIEVEMENTS.md"),
                   mock.patch.object(recognition, "CONTRIBUTORS", self.tmp / "CONTRIBUTORS.md")]
        for patch in patches:
            patch.start()
            self.addCleanup(patch.stop)

    def test_contributor_added_once(self):
        self.assertTrue(recognition.add_contributor("ada", "https://example.test/pr/1", "Fix | typo"))
        self.assertFalse(recognition.add_contributor("ada", "https://example.test/pr/2", "Again"))
        text = (self.tmp / "CONTRIBUTORS.md").read_text(encoding="utf-8")
        self.assertNotIn("Your name here", text)
        self.assertEqual(text.count("[@ada]"), 1)

    def test_achievement_goes_to_its_level(self):
        self.assertTrue(recognition.add_achievement("ada", "intermediate", "Ada", "https://example.test/pr/3", "2026-11-22"))
        self.assertFalse(recognition.add_achievement("ada", "intermediate", "Ada", "https://example.test/pr/4"))
        text = (self.tmp / "ACHIEVEMENTS.md").read_text(encoding="utf-8")
        intermediate = text.split("## 🥈 Intermediate", 1)[1].split("## 🥇", 1)[0]
        self.assertIn("[@ada]", intermediate)
        self.assertNotIn("Be the first", intermediate)
        self.assertEqual(text.count("Be the first"), 2)


if __name__ == "__main__":
    unittest.main()
