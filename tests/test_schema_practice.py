"""Schema design checking tests."""
import unittest
from pathlib import Path

from tools.schema_practice import FOLDER, TASKS, check, verify_reference


class SchemaPracticeTests(unittest.TestCase):
    def test_four_tasks(self):
        self.assertEqual(len(TASKS), 4)

    def test_all_reference_schemas(self):
        self.assertEqual(verify_reference(), 0)

    def test_empty_starters_fail(self):
        for task_id in TASKS:
            with self.subTest(task_id=task_id):
                starter = (FOLDER / "starter" / f"{task_id}.sql").read_text(encoding="utf-8")
                passed, _ = check(task_id, starter)
                self.assertFalse(passed)

    def test_missing_unique_constraint_fails(self):
        bad_sql = "CREATE TABLE accounts(account_id INTEGER PRIMARY KEY,email TEXT NOT NULL,balance_cents INTEGER NOT NULL);"
        passed, _ = check("C01", bad_sql)
        self.assertFalse(passed)

    def test_unscoped_uniqueness_fails(self):
        bad_sql = """
        CREATE TABLE inbox(tenant_id TEXT NOT NULL,event_key TEXT UNIQUE NOT NULL,
                           payload_hash TEXT NOT NULL,status TEXT NOT NULL);
        CREATE TABLE outbox(message_id INTEGER PRIMARY KEY,tenant_id TEXT NOT NULL,
                            event_key TEXT NOT NULL,payload_json TEXT NOT NULL);
        """
        passed, _ = check("C04", bad_sql)
        self.assertFalse(passed)


if __name__ == "__main__":
    unittest.main()
