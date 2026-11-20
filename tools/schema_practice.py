#!/usr/bin/env python3
"""Grade SQL schema design with behavioral constraint tests (SQLite stdlib)."""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sqlite3
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from run_sql import statements

FOLDER = ROOT / "interview" / "schema"
TASKS = {
    "C01": "Customer balances and uniqueness",
    "C02": "Active reservations and partial uniqueness",
    "C03": "Queue constraints and claim index",
    "C04": "Webhook inbox/outbox composite keys",
}


def _rejects(db, statement, params=()):
    try:
        db.execute(statement, params)
    except sqlite3.IntegrityError:
        return
    raise AssertionError(f"Expected constraint to reject: {statement}")


def _grade_c01(db):
    db.execute("INSERT INTO accounts VALUES (1,'a@example.test',0)")
    _rejects(db, "INSERT INTO accounts VALUES (2,'a@example.test',10)")
    _rejects(db, "INSERT INTO accounts VALUES (3,'b@example.test',-5)")
    _rejects(db, "INSERT INTO accounts VALUES (4,NULL,5)")
    _rejects(db, "INSERT INTO accounts(account_id,email) VALUES (5,'c@example.test')")


def _grade_c02(db):
    db.execute("INSERT INTO reservations VALUES (1,'tenant-a','r1','cancelled')")
    db.execute("INSERT INTO reservations VALUES (2,'tenant-a','r1','held')")
    _rejects(db, "INSERT INTO reservations VALUES (3,'tenant-a','r1','confirmed')")
    db.execute("INSERT INTO reservations VALUES (4,'tenant-b','r1','held')")
    db.execute("INSERT INTO reservations VALUES (5,'tenant-a','r2','held')")
    _rejects(db, "INSERT INTO reservations VALUES (6,'tenant-a','r3','invalid')")
    _rejects(db, "INSERT INTO reservations VALUES (7,NULL,'r3','held')")
    db.execute("UPDATE reservations SET status='cancelled' WHERE reservation_id=2")
    db.execute("INSERT INTO reservations VALUES (3,'tenant-a','r1','confirmed')")


def _grade_c03(db):
    db.execute("INSERT INTO jobs(job_id,tenant_id,status,created_at) VALUES (1,'t1','queued','2026-01-01')")
    assert db.execute("SELECT attempt_count FROM jobs WHERE job_id=1").fetchone()[0] == 0, "Default attempts must be zero"
    _rejects(db, "INSERT INTO jobs VALUES (2,'t1','invalid',0,'2026-01-02')")
    _rejects(db, "INSERT INTO jobs VALUES (3,'t1','queued',-1,'2026-01-02')")
    _rejects(db, "INSERT INTO jobs VALUES (4,NULL,'queued',0,'2026-01-02')")
    index_found = False
    for row in db.execute("PRAGMA index_list('jobs')"):
        cols = [item[2] for item in db.execute(
            f"PRAGMA index_info('{row[1]}')"
        ).fetchall()]
        index_found |= (cols[:3] == ["status","created_at","job_id"])
    assert index_found, "Need index on status,created_at,job_id"


def _grade_c04(db):
    db.execute("INSERT INTO inbox VALUES ('t1','event1','h1','accepted')")
    _rejects(db, "INSERT INTO inbox VALUES ('t1','event1','h2','accepted')")
    db.execute("INSERT INTO inbox VALUES ('t2','event1','h1','accepted')")
    _rejects(db, "INSERT INTO inbox VALUES ('t1','event2','h1','unexpected')")
    _rejects(db, "INSERT INTO inbox VALUES (NULL,'event2','h1','accepted')")
    db.execute("INSERT INTO outbox VALUES (1,'t1','event1','{}')")
    _rejects(db, "INSERT INTO outbox VALUES (2,'t1','event1','{}')")
    db.execute("INSERT INTO outbox VALUES (3,'t2','event1','{}')")
    _rejects(db, "INSERT INTO outbox VALUES (4,'t1','unknown','{}')")


TESTS = {"C01": _grade_c01, "C02": _grade_c02, "C03": _grade_c03, "C04": _grade_c04}


def check(task_id: str, source: str) -> tuple[bool, str]:
    if task_id not in TASKS:
        raise ValueError(f"Unknown challenge: {task_id}")
    if len(source) > 20000:
        raise ValueError("SQL too long")
    db = sqlite3.connect(":memory:")
    db.execute("PRAGMA foreign_keys=ON")
    created = 0
    try:
        for statement in statements(source):
            uncommented = re.sub(r"(?m)^\s*--[^\n]*(?:\n|$)", "", statement).strip()
            if not uncommented:
                continue
            if not re.match(r"(?is)^CREATE\s+(TABLE|UNIQUE\s+INDEX|INDEX)\b", uncommented):
                raise ValueError("Only CREATE TABLE and CREATE INDEX statements allowed")
            db.execute(statement)
            created += 1
        if not created:
            raise ValueError("No CREATE statements found")
        TESTS[task_id](db)
        return True, f"PASS {task_id}: constraints and behavior validated"
    except (sqlite3.Error, AssertionError, ValueError) as exc:
        return False, f"FAIL {task_id}: {exc}"
    finally:
        db.close()


def verify_reference() -> int:
    failures = 0
    for task_id in TASKS:
        sql = (FOLDER / "reference" / f"{task_id}.sql").read_text(encoding="utf-8")
        passed, message = check(task_id, sql)
        print(message)
        failures += not passed
    return 1 if failures else 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subs = parser.add_subparsers(dest="action", required=True)
    subs.add_parser("list")
    check_parser = subs.add_parser("check")
    check_parser.add_argument("id", choices=TASKS)
    check_parser.add_argument("file", type=Path)
    subs.add_parser("verify-reference")
    args = parser.parse_args()
    if args.action == "list":
        for task_id, label in TASKS.items():
            print(f"{task_id} | {label}")
        return 0
    if args.action == "verify-reference":
        return verify_reference()
    try:
        content = args.file.read_text(encoding="utf-8")
    except OSError as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    passed, message = check(args.id, content)
    print(message)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
