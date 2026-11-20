"""Dataset sanity checks for SQL lessons."""
import sqlite3
import sys
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from run_sql import new_database, statements


class DatasetTests(unittest.TestCase):
    def setUp(self):
        self.db = new_database()

    def tearDown(self):
        self.db.close()

    def test_expected_counts(self):
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM customers").fetchone()[0], 8)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM orders").fetchone()[0], 11)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM products").fetchone()[0], 9)

    def test_paid_order_totals_match_payments(self):
        rows = self.db.execute("""
            WITH item_totals AS (
              SELECT order_id, SUM(quantity * unit_price_cents) AS amount
              FROM order_items GROUP BY order_id
            ),
            payment_totals AS (
              SELECT order_id, SUM(amount_cents) AS amount
              FROM payments GROUP BY order_id
            )
            SELECT o.order_id
            FROM orders AS o
            LEFT JOIN item_totals AS i ON i.order_id = o.order_id
            LEFT JOIN payment_totals AS p ON p.order_id = o.order_id
            WHERE o.status = 'paid' AND (i.amount IS NULL OR p.amount IS NULL OR i.amount <> p.amount)
        """).fetchall()
        self.assertEqual(rows, [])

    def test_foreign_keys(self):
        self.assertEqual(self.db.execute("PRAGMA foreign_key_check").fetchall(), [])

    def test_incomplete_sql_rejected(self):
        with self.assertRaises(ValueError):
            list(statements("SELECT * FROM customers"))


if __name__ == "__main__":
    unittest.main()
