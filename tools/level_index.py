#!/usr/bin/env python3
"""Refresh the generated tables in each level README (lessons, worked examples, projects).

    python tools/level_index.py           # rewrite the tables
    python tools/level_index.py --check   # fail if a README is out of date (CI)
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
LEVELS = ("basics", "intermediate", "advanced")
START, END = "<!-- index:start -->", "<!-- index:end -->"


def lesson_rows(level: str) -> list[str]:
    bank = json.loads((ROOT / "practice" / f"{level}.json").read_text(encoding="utf-8"))
    quizzes = json.loads((ROOT / "quizzes" / f"{level}.json").read_text(encoding="utf-8"))
    rows = ["| # | Lesson | Time | Graded exercises | Quiz |", "|---:|---|---:|---:|---:|"]
    for md in sorted((ROOT / level / "lessons").glob("[0-9][0-9]_*.md")):
        text = md.read_text(encoding="utf-8")
        title = text.splitlines()[0].removeprefix("# ").split(" · ", 1)[1]
        time = re.search(r"\*\*Time:\*\* about (\d+) minutes", text)
        rel = md.relative_to(ROOT).as_posix()
        graded = sum(1 for i in bank if i["lesson"] == rel and i["kind"] != "written")
        questions = len(quizzes.get(f"{level}/{md.name[:2]}", {}).get("questions", []))
        rows.append(f"| {md.name[:2]} | [{title}](lessons/{md.name}) | {time.group(1) if time else '?'} min | {graded} | {questions} |")
    return rows


def block(level: str) -> str:
    return "\n".join(lesson_rows(level))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    stale = []
    for level in LEVELS:
        path = ROOT / level / "README.md"
        text = path.read_text(encoding="utf-8")
        before, rest = text.split(START, 1)
        new = before + START + "\n" + block(level) + "\n" + END + rest.split(END, 1)[1]
        if new != text:
            stale.append(path.relative_to(ROOT).as_posix())
            if not args.check:
                path.write_text(new, encoding="utf-8")
    if args.check and stale:
        print("Out of date (run python tools/level_index.py): " + ", ".join(stale), file=sys.stderr)
        return 1
    print("level indexes up to date" if not stale else "updated: " + ", ".join(stale))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
