#!/usr/bin/env python3
"""Check whether every graded exercise of a level passes (your level self-check).

    python tools/verify_level.py basics
    python tools/verify_level.py advanced --json report.json

A level counts as complete when both pass from your own files:
  * every graded practice exercise in practice/starter/<id>.sql, and
  * every interview challenge of that level in interview/starter/<id>.sql.
Written exercises are discussion prompts and are not part of the automatic check.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sqlite3
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import interview_practice  # noqa: E402
import practice  # noqa: E402


def interview_report(level: str) -> list[tuple[str, bool, str]]:
    report = []
    for qid, item in sorted(interview_practice.questions().items()):
        if item["level"] != level:
            continue
        path = ROOT / "interview" / "starter" / f"{qid}.sql"
        try:
            ok, message = interview_practice.check(qid, path.read_text(encoding="utf-8"))
        except (OSError, ValueError, sqlite3.Error) as error:
            ok, message = False, str(error)
        report.append((qid, ok, message.splitlines()[0]))
    return report


def verify(level: str) -> dict:
    sections = {"practice": practice.progress(level), "interview": interview_report(level)}
    total = sum(len(rows) for rows in sections.values())
    passed = sum(ok for rows in sections.values() for _, ok, _ in rows)
    return {"level": level, "passed": passed, "total": total, "complete": passed == total,
            "results": {name: [{"id": i, "pass": ok, "message": m} for i, ok, m in rows]
                        for name, rows in sections.items()}}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("level", choices=practice.LEVELS)
    parser.add_argument("--json", type=Path, help="also write a machine-readable report")
    args = parser.parse_args(argv)
    report = verify(args.level)
    for name, rows in report["results"].items():
        done = sum(r["pass"] for r in rows)
        print(f"\n{name.title()} ({done}/{len(rows)})")
        for row in rows:
            print(f"  {'✅' if row['pass'] else '❌'} {row['id']}" + ("" if row["pass"] else f": {row['message']}"))
    verdict = "COMPLETE" if report["complete"] else "NOT COMPLETE"
    print(f"\n{args.level}: {report['passed']}/{report['total']} graded exercises pass. {verdict}")
    if args.json:
        args.json.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0 if report["complete"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
