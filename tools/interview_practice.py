#!/usr/bin/env python3
"""Offline SQL interview practice checker (Python stdlib + SQLite)."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sqlite3
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from run_sql import new_database

BANK = ROOT / "interview"
LEVELS = ("basics", "intermediate", "advanced")


def questions() -> dict[str, dict]:
    index = {}
    for level in LEVELS:
        entries = json.loads((BANK / f"{level}.json").read_text(encoding="utf-8"))
        for item in entries:
            question_id = item["id"]
            if item["level"] != level or question_id in index:
                raise ValueError(f"Invalid or repeated question {question_id}")
            if not (BANK / "reference" / f"{question_id}.sql").is_file():
                raise ValueError(f"Missing reference query {question_id}")
            if not (BANK / "starter" / f"{question_id}.sql").is_file():
                raise ValueError(f"Missing starter query {question_id}")
            index[question_id] = item
    return index


def sample_db(edge: bool = False) -> sqlite3.Connection:
    """A new private in-memory DB, with a second test fixture for edge cases."""
    db = new_database()
    if edge:
        db.executescript("""
            INSERT INTO customers VALUES
                (9,'Iris Test','iris@example.test','Bucharest','2026-07-01');
            INSERT INTO categories VALUES (5,'Gifts');
            INSERT INTO products VALUES (10,'P10',4,'Sample Coupon',250,1);
            INSERT INTO teams VALUES (4,'Operations');
            INSERT INTO employees VALUES (9,'Ivana',1,11000000,1);
            INSERT INTO orders VALUES (112,8,'2026-10-01','paid');
            INSERT INTO order_items VALUES (112,2,2,250);
            INSERT INTO payments VALUES (9,112,500,'card','2026-10-01');
            INSERT INTO orders VALUES (113,4,'2026-04-06','pending');
            INSERT INTO order_items VALUES (113,1,1,1200);
            UPDATE payments SET amount_cents = amount_cents - 100
              WHERE payment_id = 1;
        """)
    db.execute("PRAGMA query_only=ON")
    return db


def sanitize(sql: str) -> None:
    if len(sql) > 20000:
        raise ValueError("Query is too long (limit: 20,000 characters)")
    # Ignore ordinary single-line SQL comments before the first token.
    text = re.sub(r"(?m)^\s*--[^\n]*(?:\n|$)", "", sql).strip()
    if not re.match(r"(?is)^(SELECT|WITH)\b", text):
        raise ValueError("Submit one read-only SELECT or WITH ... SELECT query")
    if not sqlite3.complete_statement(sql):
        raise ValueError("End your SQL query with a semicolon")


def execute(sql: str, *, edge: bool = False) -> tuple[tuple, ...]:
    sanitize(sql)
    db = sample_db(edge)
    # Not a security sandbox: run only SQL you trust on your local machine.
    try:
        db.set_progress_handler(lambda: 1, 1000000)
        cursor = db.execute(sql)
        if cursor.description is None:
            raise ValueError("Query must return rows")
        rows = cursor.fetchmany(2001)
        if len(rows) > 2000:
            raise ValueError("Result exceeds 2000-row practice limit")
        def scalar(v):
            return round(v, 7) if isinstance(v, float) else v
        return tuple(tuple(scalar(v) for v in row) for row in rows)
    finally:
        db.close()


def check(question_id: str, candidate: str) -> tuple[bool, str]:
    index = questions()
    if question_id not in index:
        raise ValueError(f"Unknown question: {question_id}")
    reference = (BANK / "reference" / f"{question_id}.sql").read_text(encoding="utf-8")
    for variant, edge in (("base", False), ("edge", True)):
        expected = execute(reference, edge=edge)
        actual = execute(candidate, edge=edge)
        if actual != expected:
            preview = lambda data: repr(data[:5])[:500]
            return False, (
                f"{variant} dataset mismatch\n"
                f"Expected {len(expected)} rows: {preview(expected)}\n"
                f"Received {len(actual)} rows: {preview(actual)}"
            )
    return True, f"PASS {question_id} on base + edge datasets"


def verify_reference() -> int:
    items = questions()
    errors = []
    for qid in sorted(items):
        try:
            for edge in (False, True):
                execute((BANK / "reference" / f"{qid}.sql").read_text(encoding="utf-8"), edge=edge)
        except (sqlite3.Error, ValueError) as exc:
            errors.append((qid, str(exc)))
            print(f"FAIL {qid}: {exc}", file=sys.stderr)
    if errors:
        print(f"{len(items)-len(errors)}/{len(items)} reference queries executable")
        return 1
    print(f"PASS: {len(items)} reference queries on two datasets ({len(items)*2} executions)")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    list_parser = sub.add_parser("list", help="List all questions")
    list_parser.add_argument("--level", choices=LEVELS)
    show = sub.add_parser("show", help="Read a question without revealing its answer")
    show.add_argument("id")
    grade = sub.add_parser("check", help="Grade one local SQL answer")
    grade.add_argument("id")
    grade.add_argument("file", type=Path)
    sub.add_parser("verify-reference", help="Run all reference queries on both fixtures")
    args = parser.parse_args()
    if args.command == "verify-reference":
        return verify_reference()
    index = questions()
    if args.command == "list":
        for qid, q in sorted(index.items()):
            if args.level is None or q["level"] == args.level:
                print(f"{qid} | {q['level']:<12} | {q['title']}")
        return 0
    if args.id not in index:
        print(f"Unknown question: {args.id}", file=sys.stderr)
        return 2
    q = index[args.id]
    if args.command == "show":
        print(f"{q['id']} — {q['title']}\n{q['prompt']}\nHint: {q['hint']}")
        return 0
    try:
        sql = args.file.read_text(encoding="utf-8")
        ok, message = check(args.id, sql)
    except (OSError, ValueError, sqlite3.Error) as exc:
        print(f"FAIL {args.id}: {exc}", file=sys.stderr)
        return 1
    print(message)
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
