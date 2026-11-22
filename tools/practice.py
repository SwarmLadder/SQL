#!/usr/bin/env python3
"""Graded course practice: write SQL in practice/starter/, check it offline.

    python tools/practice.py list --level basics
    python tools/practice.py show PB07
    python tools/practice.py hint PB07 1          # hints unlock one level at a time: 1, 2, 3
    python tools/practice.py check PB07           # grades practice/starter/PB07.sql
    python tools/practice.py check PB07 my.sql    # or any file you choose
    python tools/practice.py progress basics
    python tools/practice.py verify-reference

Every answer runs twice: on the course dataset and on an edge-case fixture with
extra rows. A failing check tells you what differs, never the reference answer.

Exercise kinds (see CONTRIBUTING.md):
  query   one read-only SELECT / WITH; its rows are compared with the reference
  script  any SQL (DDL, DML, transactions, triggers). The grader then runs fixed
          `probe` statements, records whether each was accepted or rejected, and
          compares `verify` queries (and optional query-plan rules) with the reference.
  written a discussion prompt with no automatic grade; answer it in your notes.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sqlite3
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from interview_practice import EDGE_SQL, sanitize  # noqa: E402
from run_sql import new_database  # noqa: E402

BANK = ROOT / "practice"
LEVELS = ("basics", "intermediate", "advanced")
KINDS = ("query", "script", "written")
ROW_LIMIT = 2000
STEP_LIMIT = 2_000_000
ANSWER_MARKER = re.compile(r"(?m)^\s*--[^\n]*")


class PracticeError(ValueError):
    """The submission cannot be graded (not the same as a wrong answer)."""


def exercises() -> dict[str, dict]:
    index: dict[str, dict] = {}
    for level in LEVELS:
        for item in json.loads((BANK / f"{level}.json").read_text(encoding="utf-8")):
            pid = item["id"]
            if item["level"] != level or pid in index or item["kind"] not in KINDS:
                raise ValueError(f"Invalid or repeated exercise {pid}")
            if item["kind"] != "written":
                for folder in ("answers", "starter"):
                    if not (BANK / folder / f"{pid}.sql").is_file():
                        raise ValueError(f"Missing {folder}/{pid}.sql")
            index[pid] = item
    return index


def _deny_attach(action, *_):
    # Keep every run inside its private in-memory database.
    if action in (sqlite3.SQLITE_ATTACH, sqlite3.SQLITE_DETACH):
        return sqlite3.SQLITE_DENY
    return sqlite3.SQLITE_OK


# Extra rows for practice only (the interview fixture stays unchanged):
# - a product bought only in a cancelled order ("never paid for" ≠ "never ordered");
# - a large pending order, so forgetting the status filter changes "top" lists;
# - a customer with no orders at all, so COUNT(*) after a LEFT JOIN is caught.
PRACTICE_EDGE_SQL = """
INSERT INTO products VALUES (11,'P11',5,'Gift Card',1500,1);
INSERT INTO orders VALUES (114,9,'2026-07-20','cancelled');
INSERT INTO order_items VALUES (114,11,1,1500);
INSERT INTO orders VALUES (115,9,'2026-08-03','pending');
INSERT INTO order_items VALUES (115,4,3,15900);
INSERT INTO customers VALUES (10,'Jon Gol','jon@example.test','Arad','2026-08-10');
"""


def fresh_db(edge: bool) -> sqlite3.Connection:
    db = new_database()
    if edge:
        db.executescript(EDGE_SQL + PRACTICE_EDGE_SQL)
    db.isolation_level = None  # learners control their own transactions
    db.set_authorizer(_deny_attach)
    db.set_progress_handler(lambda: 1, STEP_LIMIT)
    return db


def explain_error(error: sqlite3.Error) -> str:
    if "interrupted" in str(error):
        return "stopped after too many steps: look for a runaway recursive CTE or an accidental cross join"
    return str(error)


def _scalar(value):
    return round(value, 7) if isinstance(value, float) else value


def run_query(db: sqlite3.Connection, sql: str) -> tuple[tuple[str, ...], tuple[tuple, ...]]:
    cursor = db.execute(sql)
    if cursor.description is None:
        raise PracticeError("the query must return rows")
    rows = cursor.fetchmany(ROW_LIMIT + 1)
    if len(rows) > ROW_LIMIT:
        raise PracticeError(f"result exceeds the {ROW_LIMIT}-row practice limit")
    columns = tuple(col[0].lower() for col in cursor.description)
    return columns, tuple(tuple(_scalar(v) for v in row) for row in rows)


def has_sql(text: str) -> bool:
    return bool(ANSWER_MARKER.sub("", text).strip(" \n\t;"))


def evaluate(item: dict, sql: str, *, edge: bool) -> dict:
    """Run one submission on one fixture and return everything the grader compares."""
    if not has_sql(sql):
        raise PracticeError("no SQL yet: write your answer below the comments")
    if len(sql) > 20000:
        raise PracticeError("answer is too long (limit: 20,000 characters)")
    db = fresh_db(edge)
    try:
        if item["kind"] == "query":
            sanitize(sql)
            db.execute("PRAGMA query_only=ON")
            columns, rows = run_query(db, sql)
            return {"results": [(columns, rows)], "probe": [], "plan": None}
        if not sqlite3.complete_statement(sql):
            raise PracticeError("end every statement with a semicolon")
        try:
            db.executescript(sql)
        except sqlite3.Error as error:
            raise PracticeError(f"your script failed: {explain_error(error)}") from error
        if db.in_transaction:
            raise PracticeError("your script left a transaction open: finish with COMMIT or ROLLBACK")
        outcomes = []
        for statement in item.get("probe", []):
            try:
                db.execute(statement)
                outcomes.append("accepted")
            except sqlite3.DatabaseError:
                outcomes.append("rejected")
        db.execute("PRAGMA query_only=ON")
        results = []
        for query in item.get("verify", []):
            try:
                results.append(run_query(db, query))
            except sqlite3.Error as error:
                raise PracticeError(f"the checker could not read your result ({error}); "
                                    "check table and column names against the prompt") from error
        plan = None
        if "plan" in item:
            detail = " | ".join(row[-1] for row in db.execute("EXPLAIN QUERY PLAN " + item["plan"]["query"]))
            plan = detail
        return {"results": results, "probe": outcomes, "plan": plan}
    finally:
        db.close()


def _normalise(item: dict, columns, rows):
    rows = rows if item.get("ordered", True) else tuple(sorted(rows, key=repr))
    return (columns if item.get("check_columns") else None), rows


def plan_problem(item: dict, plan: str) -> str | None:
    rules = item["plan"]
    if not any(word in plan for word in rules.get("require_any", [""])):
        return f"the query plan does not use an index yet: {plan}"
    for word in rules.get("forbid", []):
        if word in plan:
            return f"the query plan still contains '{word}': {plan}"
    return None


def compare(item: dict, expected: dict, actual: dict, variant: str) -> str | None:
    if actual["probe"] != expected["probe"]:
        for n, (want, got) in enumerate(zip(expected["probe"], actual["probe"]), 1):
            if want != got:
                return (f"{variant} dataset: probe statement {n} was {got} but should be {want}:\n"
                        f"    {item['probe'][n - 1]}")
    for n, ((ecols, erows), (acols, arows)) in enumerate(zip(expected["results"], actual["results"]), 1):
        label = f"{variant} dataset" + (f", check {n}" if len(expected["results"]) > 1 else "")
        ecols, erows = _normalise(item, ecols, erows)
        acols, arows = _normalise(item, acols, arows)
        if ecols is not None and acols != ecols:
            return f"{label}: columns should be named {', '.join(ecols)} (you returned {', '.join(acols)})"
        if len(arows) != len(erows):
            return f"{label}: expected {len(erows)} row(s), received {len(arows)}. Check filters, joins and duplicates."
        if arows and len(arows[0]) != len(erows[0]):
            return f"{label}: expected {len(erows[0])} columns per row, received {len(arows[0])}"
        if set(arows) == set(erows) and arows != erows:
            return f"{label}: the right rows in the wrong order. Re-read the ORDER BY in the prompt."
        for index, (want, got) in enumerate(zip(erows, arows), 1):
            if want != got:
                return f"{label}: row {index} differs. You returned {got!r}"
    if actual["plan"] is not None:
        problem = plan_problem(item, actual["plan"])
        if problem:
            return f"{variant} dataset: {problem}"
    return None


def answer_path(pid: str) -> Path:
    return BANK / "answers" / f"{pid}.sql"


def starter_path(pid: str) -> Path:
    return BANK / "starter" / f"{pid}.sql"


def check(pid: str, sql: str) -> tuple[bool, str]:
    index = exercises()
    if pid not in index:
        raise PracticeError(f"unknown exercise {pid}")
    item = index[pid]
    if item["kind"] == "written":
        return False, f"{pid} is a written exercise: discuss it in your notes or with a reviewer"
    reference = answer_path(pid).read_text(encoding="utf-8")
    for variant, edge in (("base", False), ("edge", True)):
        expected = evaluate(item, reference, edge=edge)
        try:
            actual = evaluate(item, sql, edge=edge)
        except sqlite3.Error as error:
            return False, f"{variant} dataset: SQLite error: {explain_error(error)}"
        problem = compare(item, expected, actual, variant)
        if problem:
            return False, problem
    return True, f"PASS {pid} on base + edge datasets"


def graded(level: str | None = None) -> list[dict]:
    return [q for q in exercises().values()
            if q["kind"] != "written" and (level is None or q["level"] == level)]


def progress(level: str, folder: Path | None = None) -> list[tuple[str, bool, str]]:
    report = []
    for item in graded(level):
        path = (folder or BANK / "starter") / f"{item['id']}.sql"
        try:
            ok, message = check(item["id"], path.read_text(encoding="utf-8"))
        except (OSError, ValueError) as error:
            ok, message = False, str(error)
        report.append((item["id"], ok, message))
    return report


def verify_reference() -> int:
    errors = 0
    items = graded()
    for item in items:
        sql = answer_path(item["id"]).read_text(encoding="utf-8")
        try:
            non_empty = False
            for edge in (False, True):
                result = evaluate(item, sql, edge=edge)
                if result["plan"] is not None and plan_problem(item, result["plan"]):
                    raise PracticeError(plan_problem(item, result["plan"]))
                non_empty = non_empty or any(rows for _, rows in result["results"])
            if not non_empty:
                raise PracticeError("reference returns no rows on either fixture")
        except (sqlite3.Error, ValueError) as error:
            errors += 1
            print(f"FAIL {item['id']}: {error}", file=sys.stderr)
    if errors:
        print(f"{len(items) - errors}/{len(items)} practice references pass")
        return 1
    print(f"PASS: {len(items)} practice references on two datasets ({len(items) * 2} runs)")
    return 0


def describe(item: dict) -> str:
    lines = [f"{item['id']} — {item['title']}  [{item['level']}, {item['kind']}]",
             f"Lesson: {item['lesson']}", "", item["prompt"]]
    if item.get("probe"):
        lines += ["", "After your script, the checker runs these statements and expects "
                  "the same accepted/rejected outcome as the reference:"]
        lines += [f"  {s}" for s in item["probe"]]
    if item["kind"] != "written":
        lines += ["", f"Write your answer in practice/starter/{item['id']}.sql, then run:",
                  f"  python tools/practice.py check {item['id']}"]
    if item.get("hints"):
        lines += ["", f"Hints: python tools/practice.py hint {item['id']} 1  (up to {len(item['hints'])})"]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = parser.add_subparsers(dest="command", required=True)
    lister = sub.add_parser("list", help="List exercises")
    lister.add_argument("--level", choices=LEVELS)
    show = sub.add_parser("show", help="Read an exercise")
    show.add_argument("id")
    hint = sub.add_parser("hint", help="Reveal hints up to a level (1 = gentle, 3 = most specific)")
    hint.add_argument("id")
    hint.add_argument("level", type=int, nargs="?", default=1)
    grade = sub.add_parser("check", help="Grade one answer")
    grade.add_argument("id")
    grade.add_argument("file", type=Path, nargs="?")
    prog = sub.add_parser("progress", help="Grade every starter file of a level")
    prog.add_argument("level", choices=LEVELS)
    sub.add_parser("verify-reference", help="Run every reference answer on both fixtures")
    args = parser.parse_args()

    if args.command == "verify-reference":
        return verify_reference()
    if args.command == "progress":
        report = progress(args.level)
        for pid, ok, message in report:
            print(f"{'✅' if ok else '❌'} {pid}: {message if not ok else 'pass'}")
        passed = sum(ok for _, ok, _ in report)
        print(f"\n{passed}/{len(report)} {args.level} exercises pass")
        return 0 if passed == len(report) else 1
    index = exercises()
    if args.command == "list":
        for pid, item in sorted(index.items()):
            if args.level in (None, item["level"]):
                print(f"{pid} | {item['level']:<12} | {item['kind']:<7} | {item['title']}")
        return 0
    pid = args.id.upper()
    if pid not in index:
        print(f"Unknown exercise: {pid}", file=sys.stderr)
        return 2
    item = index[pid]
    if args.command == "show":
        print(describe(item))
        return 0
    if args.command == "hint":
        if not item.get("hints"):
            print(f"{pid} has no hints: it is a {item['kind']} exercise")
            return 0
        level = max(1, min(args.level, len(item["hints"])))
        for n, text in enumerate(item["hints"][:level], 1):
            print(f"Hint {n}: {text}")
        if level < len(item["hints"]):
            print(f"\nStill stuck? python tools/practice.py hint {pid} {level + 1}")
        return 0
    path = args.file or starter_path(pid)
    try:
        ok, message = check(pid, path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as error:
        print(f"❌ {pid}: {error}", file=sys.stderr)
        return 1
    print(("✅ " if ok else "❌ ") + message)
    if not ok and item["kind"] != "written":
        print(f"   Need a nudge? python tools/practice.py hint {pid} 1")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
