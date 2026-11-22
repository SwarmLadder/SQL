#!/usr/bin/env python3
"""Check whether every graded exercise of a level passes (used for achievement claims).

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


def _normal(sql: str) -> str:
    return " ".join(practice.ANSWER_MARKER.sub("", sql).lower().split())


def copied_reference(answer: Path, reference: Path) -> bool:
    """True when an answer is the reference file with only comments/whitespace/case changed."""
    try:
        return _normal(answer.read_text(encoding="utf-8")) == _normal(reference.read_text(encoding="utf-8"))
    except OSError:
        return False


def _flag_copies(rows, answers: Path, references: Path):
    flagged = []
    for pid, ok, message in rows:
        if ok and copied_reference(answers / f"{pid}.sql", references / f"{pid}.sql"):
            ok, message = False, "identical to the reference answer: write your own solution"
        flagged.append((pid, ok, message))
    return flagged


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
    sections = {
        "practice": _flag_copies(practice.progress(level), ROOT / "practice" / "starter",
                                 ROOT / "practice" / "answers"),
        "interview": _flag_copies(interview_report(level), ROOT / "interview" / "starter",
                                  ROOT / "interview" / "reference"),
    }
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
