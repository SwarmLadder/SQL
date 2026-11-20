"""Backend SQL lab: tenant isolation, idempotent checkout, inventory, outbox, keyset pages.

Run: python -m backend.lab
Uses Python stdlib SQLite and fresh, in-memory databases only.
Educational example, not a deployed multi-tenant payments system.
"""
from __future__ import annotations

import hashlib
import json
import re
import sqlite3

SCHEMA = """
PRAGMA foreign_keys=ON;
CREATE TABLE tenants (
    tenant_id TEXT PRIMARY KEY
);
CREATE TABLE inventory (
    tenant_id TEXT NOT NULL REFERENCES tenants(tenant_id),
    sku TEXT NOT NULL,
    available INTEGER NOT NULL CHECK(available>=0),
    PRIMARY KEY(tenant_id, sku)
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id TEXT NOT NULL REFERENCES tenants(tenant_id),
    sku TEXT NOT NULL,
    units INTEGER NOT NULL CHECK(units>0),
    amount_cents INTEGER NOT NULL CHECK(amount_cents>=0),
    created_at TEXT NOT NULL
);
CREATE INDEX idx_orders_tenant_created_id
    ON orders(tenant_id, created_at DESC, order_id DESC);
CREATE TABLE inbox (
    tenant_id TEXT NOT NULL REFERENCES tenants(tenant_id),
    event_key TEXT NOT NULL,
    fingerprint TEXT NOT NULL,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    PRIMARY KEY(tenant_id,event_key)
);
CREATE TABLE outbox (
    outbox_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id TEXT NOT NULL REFERENCES tenants(tenant_id),
    event_key TEXT NOT NULL,
    event_type TEXT NOT NULL,
    payload_json TEXT NOT NULL,
    UNIQUE(tenant_id,event_key)
);
"""


class ConflictError(ValueError):
    """An idempotency key was reused for a different request."""


class OutOfStock(ValueError):
    """Insufficient inventory or unknown product."""


def new_database() -> sqlite3.Connection:
    db = sqlite3.connect(":memory:")
    db.executescript(SCHEMA)
    db.executemany("INSERT INTO tenants VALUES (?)", [("tenant-a",), ("tenant-b",)])
    db.executemany("INSERT INTO inventory VALUES (?,?,?)", [
        ("tenant-a", "BOOK", 5),
        ("tenant-a", "PEN", 3),
        ("tenant-b", "BOOK", 2),
    ])
    db.commit()
    return db


def _key(value: str, field: str) -> None:
    if not isinstance(value, str) or not re.fullmatch(r"[A-Za-z0-9_-]{1,64}", value):
        raise ValueError(f"{field} must be 1–64 alphanumeric, underscore or hyphen characters")


def submit_order(
    db: sqlite3.Connection,
    tenant_id: str,
    event_key: str,
    sku: str,
    units: int,
    amount_cents: int,
    created_at: str,
) -> dict:
    """Atomically reserve stock, create an order, and record inbox/outbox.

    A replay with the same tenant, event key and payload returns the original
    order id; a conflicting replay raises ConflictError.
    """
    for field, value in (("tenant_id", tenant_id), ("event_key", event_key), ("sku", sku)):
        _key(value, field)
    if isinstance(units, bool) or not isinstance(units, int) or units <= 0:
        raise ValueError("units must be a positive integer")
    if isinstance(amount_cents, bool) or not isinstance(amount_cents, int) or amount_cents < 0:
        raise ValueError("amount_cents must be a nonnegative integer")
    if not isinstance(created_at, str) or not re.fullmatch(r"\d{4}-\d{2}-\d{2}", created_at):
        raise ValueError("created_at must use YYYY-MM-DD format")

    payload = json.dumps({
        "tenant_id": tenant_id, "sku": sku, "units": units,
        "amount_cents": amount_cents, "created_at": created_at,
    }, sort_keys=True)
    fingerprint = hashlib.sha256(payload.encode("utf-8")).hexdigest()

    with db:
        # Writers serialize on this SQLite database. Use a dedicated connection
        # without an already-open transaction for this API.
        db.execute("BEGIN IMMEDIATE")
        previous = db.execute(
            "SELECT fingerprint, order_id FROM inbox WHERE tenant_id=? AND event_key=?",
            (tenant_id, event_key),
        ).fetchone()
        if previous is not None:
            if previous[0] != fingerprint:
                raise ConflictError("conflicting request for idempotency key")
            return {"status": "replayed", "order_id": previous[1]}

        updated = db.execute(
            """UPDATE inventory SET available=available-?
               WHERE tenant_id=? AND sku=? AND available>=?""",
            (units, tenant_id, sku, units),
        )
        if updated.rowcount != 1:
            raise OutOfStock("item unavailable or insufficient inventory")

        cursor = db.execute(
            """INSERT INTO orders(tenant_id,sku,units,amount_cents,created_at)
               VALUES (?,?,?,?,?)""",
            (tenant_id, sku, units, amount_cents, created_at),
        )
        order_id = cursor.lastrowid
        db.execute(
            """INSERT INTO inbox(tenant_id,event_key,fingerprint,order_id)
               VALUES (?,?,?,?)""",
            (tenant_id, event_key, fingerprint, order_id),
        )
        db.execute(
            """INSERT INTO outbox(tenant_id,event_key,event_type,payload_json)
               VALUES (?,?,'ORDER_CREATED',?)""",
            (tenant_id, event_key, json.dumps({"order_id": order_id})),
        )
    return {"status": "created", "order_id": order_id}


def list_orders(
    db: sqlite3.Connection,
    tenant_id: str,
    *,
    limit: int = 20,
    cursor: tuple[str, int] | None = None,
) -> list[tuple[int, str, int, str]]:
    """Tenant-scoped, descending keyset pagination; cursor=(date, order_id)."""
    _key(tenant_id, "tenant_id")
    if isinstance(limit, bool) or not isinstance(limit, int) or not 1 <= limit <= 100:
        raise ValueError("limit must be from 1 to 100")
    query = """SELECT order_id,sku,units,created_at FROM orders
               WHERE tenant_id=?"""
    params: list = [tenant_id]
    if cursor is not None:
        if (not isinstance(cursor, tuple) or len(cursor) != 2
                or not isinstance(cursor[0], str)
                or isinstance(cursor[1], bool) or not isinstance(cursor[1], int)):
            raise ValueError("cursor must be a (date, integer order_id) tuple")
        query += """ AND (created_at<? OR (created_at=? AND order_id<?))"""
        params.extend([cursor[0], cursor[0], cursor[1]])
    query += " ORDER BY created_at DESC,order_id DESC LIMIT ?"
    params.append(limit)
    return db.execute(query, params).fetchall()


def remaining(db: sqlite3.Connection, tenant_id: str, sku: str) -> int | None:
    _key(tenant_id, "tenant_id")
    _key(sku, "sku")
    row = db.execute(
        "SELECT available FROM inventory WHERE tenant_id=? AND sku=?",
        (tenant_id, sku),
    ).fetchone()
    return row[0] if row else None


def demo() -> None:
    db = new_database()
    try:
        print(submit_order(db, "tenant-a", "request-01", "BOOK", 2, 5000, "2026-11-20"))
        print(submit_order(db, "tenant-a", "request-01", "BOOK", 2, 5000, "2026-11-20"))
        print("Stock tenant-a:", remaining(db, "tenant-a", "BOOK"))
        print("Stock tenant-b:", remaining(db, "tenant-b", "BOOK"))
        print("Page:", list_orders(db, "tenant-a"))
    finally:
        db.close()


if __name__ == "__main__":
    demo()
