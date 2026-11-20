"""Interview-ready SQL patterns on the sample e-commerce database.

Run with: python -m backend.query_patterns
The SQLite database is in memory; demonstrations never modify real files.
"""
from __future__ import annotations

import sqlite3
from tools.run_sql import new_database


class StaleVersion(ValueError):
    """The row was changed or removed since the caller last read it."""


def order_counts_n_plus_one(db: sqlite3.Connection) -> list[tuple[int, int]]:
    """Anti-pattern: 1 query to list customers, N more to count each user's orders."""
    ids = [row[0] for row in db.execute(
        "SELECT customer_id FROM customers ORDER BY customer_id"
    )]
    return [
        (cid, db.execute(
            "SELECT COUNT(*) FROM orders WHERE customer_id=?", (cid,)
        ).fetchone()[0])
        for cid in ids
    ]


def order_counts_set_based(db: sqlite3.Connection) -> list[tuple[int, int]]:
    """Equivalent work in one query; preserves customers with no orders."""
    return db.execute("""
        SELECT c.customer_id, COUNT(o.order_id) AS order_count
        FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
        GROUP BY c.customer_id ORDER BY c.customer_id
    """).fetchall()


def search_catalog(db: sqlite3.Connection, term: str) -> list[tuple[str, str]]:
    """Substring search; escape LIKE wildcard characters and bind the value."""
    if not isinstance(term, str) or len(term) > 64:
        raise ValueError("term must be text of at most 64 characters")
    literal = (term.strip().replace("!", "!!")
               .replace("%", "!%").replace("_", "!_"))
    return db.execute(
        """SELECT sku,product_name FROM products
           WHERE LOWER(product_name) LIKE LOWER(?) ESCAPE '!'
           ORDER BY sku""",
        ("%" + literal + "%",),
    ).fetchall()


def catalog_sorted(
    db: sqlite3.Connection,
    sort_by: str = "name",
    descending: bool = False,
    limit: int = 10,
) -> list[tuple[str, str, int]]:
    """Dynamic identifiers are allowlisted, not interpolated from raw user input."""
    fields = {"name": "product_name", "price": "unit_price_cents"}
    if sort_by not in fields:
        raise ValueError("invalid sort field")
    if not isinstance(descending, bool):
        raise ValueError("descending must be bool")
    if isinstance(limit, bool) or not isinstance(limit, int) or not 1 <= limit <= 100:
        raise ValueError("limit must be 1 to 100")
    direction = "DESC" if descending else "ASC"
    query = (f"SELECT sku,product_name,unit_price_cents FROM products "
             f"ORDER BY {fields[sort_by]} {direction},sku ASC LIMIT ?")
    return db.execute(query, (limit,)).fetchall()


def prepare_versions(db: sqlite3.Connection) -> None:
    """Add a version field as a simple additive schema-migration example."""
    with db:
        db.execute("ALTER TABLE products ADD COLUMN version INTEGER NOT NULL DEFAULT 1")


def update_price_if_current(
    db: sqlite3.Connection, product_id: int, expected_version: int, price_cents: int
) -> int:
    """Optimistic concurrency: reject stale writes without overwriting changes."""
    if (any(isinstance(x, bool) or not isinstance(x, int)
            for x in (product_id, expected_version, price_cents))
            or expected_version < 1 or price_cents < 0):
        raise ValueError("invalid product id, version, or price")
    with db:
        result = db.execute("""
            UPDATE products
            SET unit_price_cents=?, version=version+1
            WHERE product_id=? AND version=?
        """, (price_cents, product_id, expected_version))
        if result.rowcount != 1:
            raise StaleVersion("record changed or not found")
    return expected_version + 1


def demo() -> None:
    db = new_database()
    try:
        statements = []
        db.set_trace_callback(statements.append)
        slow = order_counts_n_plus_one(db)
        naive_queries = len(statements)
        statements.clear()
        fast = order_counts_set_based(db)
        batch_queries = len(statements)
        db.set_trace_callback(None)
        assert slow == fast
        print(f"Same results: {len(slow)} customers; N+1: {naive_queries} queries; set-based: {batch_queries} query")
        print("Safe search:", search_catalog(db, "book"))
        prepare_versions(db)
        print("New version:", update_price_if_current(db, 1, 1, 1400))
    finally:
        db.close()


if __name__ == "__main__":
    demo()
