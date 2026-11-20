"""Unit tests for N+1, safe search, query parameters, and optimistic locking."""
import unittest
from backend.query_patterns import (
    StaleVersion, catalog_sorted, order_counts_n_plus_one,
    order_counts_set_based, prepare_versions, search_catalog,
    update_price_if_current,
)
from tools.run_sql import new_database


class QueryPatternTests(unittest.TestCase):
    def setUp(self):
        self.db = new_database()

    def tearDown(self):
        self.db.close()

    def test_n_plus_one_and_set_based_same_results(self):
        self.assertEqual(order_counts_n_plus_one(self.db), order_counts_set_based(self.db))

    def test_set_based_uses_one_statement(self):
        traces = []
        self.db.set_trace_callback(traces.append)
        order_counts_set_based(self.db)
        self.assertEqual(len(traces), 1)
        traces.clear()
        order_counts_n_plus_one(self.db)
        self.assertGreater(len(traces), 1)
        self.db.set_trace_callback(None)

    def test_catalog_search(self):
        self.assertIn(("P03", "Python Handbook"), search_catalog(self.db, "book"))

    def test_search_escapes_wildcards(self):
        self.assertEqual(search_catalog(self.db, "%"), [])
        self.assertEqual(search_catalog(self.db, "_"), [])

    def test_search_does_not_interpolate_sql(self):
        self.assertEqual(search_catalog(self.db, "' OR 1=1 --"), [])
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM products").fetchone()[0], 9)

    def test_catalog_sort_allowlist(self):
        with self.assertRaises(ValueError):
            catalog_sorted(self.db, "unit_price_cents; DROP TABLE products;")
        results = catalog_sorted(self.db, "price", descending=True, limit=3)
        self.assertEqual(len(results), 3)
        self.assertGreaterEqual(results[0][2], results[-1][2])

    def test_catalog_limit_validation(self):
        with self.assertRaises(ValueError):
            catalog_sorted(self.db, limit=0)

    def test_optimistic_write(self):
        prepare_versions(self.db)
        self.assertEqual(update_price_if_current(self.db, 1, 1, 1400), 2)
        self.assertEqual(self.db.execute(
            "SELECT unit_price_cents,version FROM products WHERE product_id=1"
        ).fetchone(), (1400, 2))

    def test_stale_write_does_not_replace_price(self):
        prepare_versions(self.db)
        update_price_if_current(self.db, 1, 1, 1400)
        with self.assertRaises(StaleVersion):
            update_price_if_current(self.db, 1, 1, 999)
        self.assertEqual(self.db.execute(
            "SELECT unit_price_cents FROM products WHERE product_id=1"
        ).fetchone()[0], 1400)

    def test_invalid_price(self):
        prepare_versions(self.db)
        with self.assertRaises(ValueError):
            update_price_if_current(self.db, 1, 1, -50)


if __name__ == "__main__":
    unittest.main()
