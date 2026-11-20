"""Behavioral tests for backend database patterns."""
from __future__ import annotations

import sqlite3
import unittest

from backend.lab import (
    ConflictError, OutOfStock, list_orders, new_database, remaining, submit_order,
)


class BackendLabTests(unittest.TestCase):
    def setUp(self):
        self.db = new_database()

    def tearDown(self):
        self.db.close()

    def create(self, key="e1", tenant="tenant-a", sku="BOOK", units=2,
               amount=5000, date="2026-11-20"):
        return submit_order(self.db, tenant, key, sku, units, amount, date)

    def test_replay_preserves_stock_and_order(self):
        created = self.create()
        replayed = self.create()
        self.assertEqual(created["order_id"], replayed["order_id"])
        self.assertEqual(replayed["status"], "replayed")
        self.assertEqual(remaining(self.db, "tenant-a", "BOOK"), 3)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM outbox").fetchone()[0], 1)

    def test_conflicting_replay_does_not_change_stock(self):
        self.create()
        with self.assertRaises(ConflictError):
            self.create(amount=8000)
        self.assertEqual(remaining(self.db, "tenant-a", "BOOK"), 3)

    def test_out_of_stock_is_atomic(self):
        with self.assertRaises(OutOfStock):
            self.create(units=6)
        self.assertEqual(remaining(self.db, "tenant-a", "BOOK"), 5)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM inbox").fetchone()[0], 0)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM outbox").fetchone()[0], 0)

    def test_tenant_isolation(self):
        self.create()
        self.assertEqual(remaining(self.db, "tenant-b", "BOOK"), 2)
        self.assertEqual(list_orders(self.db, "tenant-b"), [])
        self.assertEqual(len(list_orders(self.db, "tenant-a")), 1)

    def test_same_idempotency_key_is_scoped_per_tenant(self):
        a = self.create()
        b = self.create(tenant="tenant-b", units=1)
        self.assertNotEqual(a["order_id"], b["order_id"])
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM inbox").fetchone()[0], 2)

    def test_keyset_pagination_handles_ties(self):
        self.create(key="e1", units=1)
        self.create(key="e2", units=1)
        self.create(key="e3", units=1)
        page1 = list_orders(self.db, "tenant-a", limit=2)
        self.assertEqual(len(page1), 2)
        cursor = (page1[-1][3], page1[-1][0])
        page2 = list_orders(self.db, "tenant-a", limit=2, cursor=cursor)
        self.assertEqual(len(page2), 1)
        self.assertEqual(len(set(row[0] for row in page1+page2)), 3)

    def test_invalid_limit(self):
        for limit in (0, 101, True, -1):
            with self.subTest(limit=limit), self.assertRaises(ValueError):
                list_orders(self.db, "tenant-a", limit=limit)

    def test_invalid_units(self):
        for units in (0, -1, 2.5, True):
            with self.subTest(units=units), self.assertRaises(ValueError):
                self.create(units=units)

    def test_invalid_money(self):
        for amount in (-1, 1.2, True):
            with self.subTest(amount=amount), self.assertRaises(ValueError):
                self.create(amount=amount)

    def test_bad_tenant_rejected(self):
        with self.assertRaises(ValueError):
            self.create(tenant="tenant-a'; DROP TABLE orders;--")

    def test_outbox_failure_rolls_back_inventory_and_order(self):
        self.db.execute("DROP TABLE outbox")
        self.db.commit()
        with self.assertRaises(sqlite3.OperationalError):
            self.create()
        self.assertEqual(remaining(self.db, "tenant-a", "BOOK"), 5)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM orders").fetchone()[0], 0)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM inbox").fetchone()[0], 0)

    def test_unknown_product_rejected(self):
        with self.assertRaises(OutOfStock):
            self.create(sku="UNKNOWN")

    def test_both_tenants_can_keep_separate_inventory(self):
        self.create(units=3)
        self.create(tenant="tenant-b", units=1)
        self.assertEqual(remaining(self.db, "tenant-a", "BOOK"), 2)
        self.assertEqual(remaining(self.db, "tenant-b", "BOOK"), 1)


if __name__ == "__main__":
    unittest.main()
