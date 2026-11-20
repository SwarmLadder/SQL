#!/usr/bin/env python3
"""Run each SQLite lesson in a fresh in-memory sample database."""
from __future__ import annotations

import argparse
from pathlib import Path
import sqlite3
import sys

ROOT = Path(__file__).resolve().parents[1]
SCHEMA = (ROOT / "data/schema.sql").read_text(encoding="utf-8")
SEED = (ROOT / "data/seed.sql").read_text(encoding="utf-8")


def new_database() -> sqlite3.Connection:
    db = sqlite3.connect(":memory:")
    db.execute("PRAGMA foreign_keys=ON")
    db.executescript(SCHEMA)
    db.executescript(SEED)
    return db


def statements(sql: str):
    """Yield complete statements, including those with multiline SQL and comments."""
    buffered = ""
    for line in sql.splitlines(keepends=True):
        buffered += line
        if sqlite3.complete_statement(buffered):
            if buffered.strip():
                yield buffered
            buffered = ""
    if buffered.strip():
        raise ValueError("Incomplete SQL statement; end each statement with a semicolon")


def run_file(path: Path, *, verbose: bool = False) -> int:
    path = path.resolve()
    if not path.is_relative_to(ROOT):
        raise ValueError("SQL file must be within the course repository")
    if not path.is_file() or path.suffix != ".sql":
        raise ValueError(f"Not a .sql file: {path}")
    query_count = 0
    db = new_database()
    try:
        for statement in statements(path.read_text(encoding="utf-8")):
            cursor = db.execute(statement)
            query_count += 1
            if verbose:
                print(f"\n--- Statement {query_count} ---")
                if cursor.description:
                    print(" | ".join(col[0] for col in cursor.description))
                    for row in cursor.fetchall():
                        print(" | ".join("NULL" if x is None else str(x) for x in row))
                else:
                    print(f"Rows changed: {max(cursor.rowcount, 0)}")
    finally:
        db.close()
    if verbose:
        print(f"\nExecuted {query_count} statements from {path.relative_to(ROOT)}")
    return query_count


def sql_files():
    paths = []
    for level in ("basics", "intermediate", "advanced"):
        for part in ("lessons", "projects", "solutions"):
            paths.extend((ROOT / level / part).glob("*.sql"))
    return sorted(paths)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", nargs="?", type=Path, help="SQL file to run")
    parser.add_argument("--check", action="store_true", help="Validate all SQLite SQL files")
    args = parser.parse_args()
    if args.check:
        paths = sql_files()
        if not paths:
            parser.error("No course SQL files found")
        failed = []
        for path in paths:
            try:
                run_file(path)
                print(f"PASS {path.relative_to(ROOT)}")
            except (sqlite3.Error, OSError, ValueError) as error:
                print(f"FAIL {path.relative_to(ROOT)}: {error}", file=sys.stderr)
                failed.append(path)
        print(f"{len(paths)-len(failed)}/{len(paths)} SQL files passed")
        return 1 if failed else 0
    if args.file is None:
        parser.error("Provide a SQL file or --check")
    try:
        run_file(args.file, verbose=True)
        return 0
    except (sqlite3.Error, OSError, ValueError) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
