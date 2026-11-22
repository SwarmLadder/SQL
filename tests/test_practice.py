"""The practice bank is complete, every reference passes, and wrong answers are caught."""
from pathlib import Path
import json
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import practice  # noqa: E402
import verify_level  # noqa: E402

WRONG = {
    # Plausible mistakes each exercise exists to catch.
    "PB01": "SELECT sku, product_name FROM products ORDER BY sku;",
    "PB02": "SELECT customer_id, full_name FROM customers ORDER BY customer_id;",
    "PB06": "SELECT employee_id, full_name FROM employees WHERE manager_id = NULL ORDER BY 1;",
    "PB07": "SELECT order_id, ordered_at FROM orders ORDER BY ordered_at LIMIT 3;",
    "PB19": "SELECT p.sku, p.product_name FROM products p JOIN order_items i ON i.product_id = p.product_id WHERE i.quantity = 0;",
    "PI02": ("SELECT o.order_id, SUM(i.quantity * i.unit_price_cents), COALESCE(SUM(p.amount_cents), 0) "
             "FROM orders o JOIN order_items i ON i.order_id = o.order_id "
             "LEFT JOIN payments p ON p.order_id = o.order_id WHERE o.status = 'paid' "
             "GROUP BY o.order_id ORDER BY o.order_id;"),
    "PI05": ("SELECT sku, product_name FROM products WHERE product_id NOT IN "
             "(SELECT product_id FROM order_items) ORDER BY sku;"),
    "PI17": ("CREATE TABLE paid_customer_totals AS SELECT o.customer_id, SUM(p.amount_cents) AS lifetime_cents "
             "FROM payments p JOIN orders o ON o.order_id = p.order_id GROUP BY o.customer_id;"),
    "PI19": ("SELECT DISTINCT c.customer_id, c.full_name FROM customers c JOIN orders o "
             "ON o.customer_id = c.customer_id WHERE o.status <> 'paid' ORDER BY 1;"),
    "PA01": "CREATE INDEX idx_payments_method ON payments(method);",
    "PA11": ("CREATE TABLE price_changes(product_id INTEGER, old_price_cents INTEGER, new_price_cents INTEGER); "
             "CREATE TRIGGER t AFTER UPDATE ON products BEGIN INSERT INTO price_changes "
             "VALUES (NEW.product_id, OLD.unit_price_cents, NEW.unit_price_cents); END;"),
    "PA13": ("CREATE VIEW category_revenue_snapshot AS SELECT p.category_id, "
             "SUM(i.quantity * i.unit_price_cents) AS revenue_cents FROM order_items i "
             "JOIN orders o ON o.order_id = i.order_id JOIN products p ON p.product_id = i.product_id "
             "WHERE o.status = 'paid' GROUP BY p.category_id;"),
    "PA14": ("CREATE TABLE coupons(code TEXT UNIQUE, percent_off INTEGER NOT NULL CHECK (percent_off BETWEEN 1 AND 90), "
             "expires_at TEXT NOT NULL); INSERT INTO coupons VALUES ('WELCOME10', 10, '2026-12-31');"),
    "PA17": ("SELECT employee_id, full_name FROM employees WHERE employee_id NOT IN "
             "(SELECT manager_id FROM employees) ORDER BY employee_id;"),
}


class PracticeBankTests(unittest.TestCase):
    def setUp(self):
        self.items = practice.exercises()

    def test_counts_and_ids(self):
        for level, prefix in (("basics", "PB"), ("intermediate", "PI"), ("advanced", "PA")):
            ids = sorted(i["id"] for i in self.items.values() if i["level"] == level)
            self.assertEqual(ids, [f"{prefix}{n:02d}" for n in range(1, len(ids) + 1)], level)
            self.assertGreaterEqual(len(ids), 35, level)

    def test_every_lesson_has_exercises(self):
        lessons = {i["lesson"] for i in self.items.values()}
        for level in ("basics", "intermediate", "advanced"):
            for md in sorted((ROOT / level / "lessons").glob("[0-9][0-9]_*.md")):
                rel = md.relative_to(ROOT).as_posix()
                self.assertIn(rel, lessons, rel)
                graded = [i for i in self.items.values() if i["lesson"] == rel and i["kind"] != "written"]
                self.assertGreaterEqual(len(graded), 2, rel)

    def test_every_exercise_is_complete(self):
        for pid, item in self.items.items():
            self.assertTrue((ROOT / item["lesson"]).is_file(), pid)
            self.assertGreater(len(item["prompt"]), 40, pid)
            if item["kind"] == "written":
                self.assertFalse((ROOT / "practice" / "answers" / f"{pid}.sql").exists(), pid)
                continue
            self.assertEqual(len(item["hints"]), 3, pid)
            answer = (ROOT / "practice" / "answers" / f"{pid}.sql").read_text(encoding="utf-8")
            for hint in item["hints"]:
                self.assertNotEqual(" ".join(hint.split()).rstrip(";"), " ".join(answer.split()).rstrip(";"), pid)
            if item["kind"] == "script":
                self.assertTrue(item.get("verify") or item.get("plan"), pid)

    def test_starters_are_unanswered(self):
        for item in practice.graded():
            text = practice.starter_path(item["id"]).read_text(encoding="utf-8")
            self.assertFalse(practice.has_sql(text), item["id"])
            ok, _ = (False, "") if not practice.has_sql(text) else practice.check(item["id"], text)
            self.assertFalse(ok)

    def test_references_pass_their_own_check(self):
        for item in practice.graded():
            ok, message = practice.check(item["id"], practice.answer_path(item["id"]).read_text(encoding="utf-8"))
            self.assertTrue(ok, f"{item['id']}: {message}")

    def test_wrong_answers_are_rejected(self):
        for pid, sql in WRONG.items():
            ok, message = practice.check(pid, sql)
            self.assertFalse(ok, f"{pid} accepted a wrong answer")
            self.assertNotIn(practice.answer_path(pid).read_text(encoding="utf-8").strip(), message)

    def test_query_exercises_are_read_only(self):
        with self.assertRaises(ValueError):
            practice.check("PB01", "DELETE FROM products;")

    def test_scripts_cannot_attach_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "escape.db"
            with self.assertRaises(ValueError):
                practice.check("PA09", f"ATTACH DATABASE '{target}' AS x;")
            self.assertFalse(target.exists())

    def test_open_transaction_is_reported(self):
        with self.assertRaises(ValueError) as ctx:
            practice.check("PI18", "BEGIN; UPDATE products SET unit_price_cents = 300 WHERE product_id = 2;")
        self.assertIn("transaction", str(ctx.exception))

    def test_runaway_query_is_stopped(self):
        sql = "WITH RECURSIVE r(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM r) SELECT n FROM r LIMIT 3000;"
        with self.assertRaises(ValueError):
            practice.check("PB11", sql)

    def test_untouched_level_is_incomplete(self):
        report = verify_level.verify("basics")
        expected = len(practice.graded("basics")) + 16
        self.assertEqual((report["passed"], report["total"], report["complete"]), (0, expected, False))

    def test_docs_are_generated(self):
        result = subprocess.run([sys.executable, str(ROOT / "tools" / "practice_docs.py"), "--check"],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_cli_check_exit_codes(self):
        cli = [sys.executable, str(ROOT / "tools" / "practice.py"), "check", "PB03"]
        with tempfile.NamedTemporaryFile("w", suffix=".sql", delete=False) as handle:
            handle.write("SELECT DISTINCT status FROM orders ORDER BY status;\n")
        try:
            self.assertEqual(subprocess.run(cli + [handle.name], capture_output=True).returncode, 0)
        finally:
            Path(handle.name).unlink()
        self.assertEqual(subprocess.run(cli, capture_output=True).returncode, 1)  # empty starter


if __name__ == "__main__":
    unittest.main()
