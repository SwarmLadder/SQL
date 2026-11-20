"""Check the backend SQL interview practice data and grading engine."""
from __future__ import annotations

import sys
from pathlib import Path
import sqlite3
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from interview_practice import BANK, LEVELS, check, execute, questions, sample_db, verify_reference


class InterviewTests(unittest.TestCase):
    def test_48_unique_questions(self):
        index = questions()
        self.assertEqual(len(index), 48)
        for level in LEVELS:
            self.assertEqual(sum(q["level"] == level for q in index.values()), 16)

    def test_reference_queries_execute_on_two_fixtures(self):
        self.assertEqual(verify_reference(), 0)

    def test_correct_candidate_passes(self):
        sql = (BANK / "reference" / "B10.sql").read_text(encoding="utf-8")
        passed, msg = check("B10", sql)
        self.assertTrue(passed, msg)

    def test_bad_candidate_fails(self):
        passed, msg = check("B10", "SELECT 0, 0;")
        self.assertFalse(passed)
        self.assertIn("mismatch", msg)

    def test_wrong_empty_answer_fails_on_edge_fixture(self):
        passed, msg = check("A12", "SELECT order_id, 0 FROM orders WHERE 1=0;")
        self.assertFalse(passed)
        self.assertIn("edge", msg)

    def test_seed_has_no_discrepancies(self):
        ref = (BANK / "reference" / "A12.sql").read_text(encoding="utf-8")
        self.assertEqual(execute(ref), ())
        self.assertEqual(execute(ref, edge=True), ((101, 100),))

    def test_reject_update(self):
        with self.assertRaises(ValueError):
            execute("UPDATE customers SET city='X';")

    def test_reject_multiple_statements(self):
        with self.assertRaises(sqlite3.Error):
            execute("SELECT 1; SELECT 2;")

    def test_readonly_cte(self):
        self.assertEqual(execute("WITH v AS (SELECT 42 AS n) SELECT n FROM v;"), ((42,),))

    def test_empty_starter_rejected(self):
        starter = (BANK / "starter" / "B01.sql").read_text(encoding="utf-8")
        with self.assertRaises(ValueError):
            execute(starter)

    def test_fixture_does_not_change_seed(self):
        with sample_db(False) as db:
            self.assertEqual(db.execute("SELECT COUNT(*) FROM customers").fetchone()[0], 8)
        with sample_db(True) as db:
            self.assertEqual(db.execute("SELECT COUNT(*) FROM customers").fetchone()[0], 9)

if __name__ == "__main__":
    unittest.main()
