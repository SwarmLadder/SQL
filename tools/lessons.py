#!/usr/bin/env python3
"""Build lesson and worked-example pages from their Markdown source, and check they are current.

    python tools/lessons.py           # rewrite results, exercise lists, quizzes and lesson .sql files
    python tools/lessons.py --check   # fail if anything is out of date (CI)

A lesson (`<level>/lessons/NN_topic.md`) is ordinary Markdown with a few conventions:

* A ```sql block is an example. All examples of a lesson run in order against ONE fresh
  sample database, so later examples see earlier changes. The block's results are written
  below it between `<!-- result -->` and `<!-- /result -->`.
* ```sql error marks an example that is supposed to fail; the error message is shown.
* ```sql norun is shown but never executed (other dialects, fragments, pseudo-code).
* `<!-- exercises -->` / `<!-- /exercises -->` is filled from practice/<level>.json
  (every exercise whose `lesson` is this file).
* `<!-- quiz -->` / `<!-- /quiz -->` is filled from quizzes/<level>.json.

The sibling `NN_topic.sql` is generated from the runnable examples, so
`python tools/run_sql.py <level>/lessons/NN_topic.sql` replays the lesson.
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
from run_sql import new_database, statements  # noqa: E402

LEVELS = ("basics", "intermediate", "advanced")
MAX_ROWS = 12
BLOCK = re.compile(r"```sql( error| norun)?\n(.*?)```\n(?:\n?<!-- result -->\n.*?<!-- /result -->\n)?", re.S)
KINDS = {"query": "query", "script": "script", "written": "written ✍️"}


def cell(value) -> str:
    if value is None:
        return "*NULL*"
    return str(value).replace("|", "\\|")


def table(cursor: sqlite3.Cursor) -> str:
    rows = cursor.fetchall()
    head = [col[0] for col in cursor.description]
    lines = ["| " + " | ".join(head) + " |", "|" + "---|" * len(head)]
    lines += ["| " + " | ".join(cell(v) for v in row) + " |" for row in rows[:MAX_ROWS]]
    if not rows:
        lines.append("| " + " | ".join(["*(no rows)*"] + [""] * (len(head) - 1)) + " |")
    if len(rows) > MAX_ROWS:
        lines.append(f"\n*… {len(rows) - MAX_ROWS} more rows*")
    return "\n".join(lines)


def run_block(db: sqlite3.Connection, sql: str, mode: str | None, where: str) -> str:
    if mode == " error":
        try:
            for statement in statements(sql):
                db.execute(statement)
        except sqlite3.Error as error:
            return f"**Error:** `{error}`"
        raise ValueError(f"{where}: example marked `error` ran without an error")
    out = []
    for statement in statements(sql):
        try:
            cursor = db.execute(statement)
        except sqlite3.Error as error:
            raise ValueError(f"{where}: {error}\n{statement}") from error
        reads = re.match(r"(?is)\s*(select|with|explain|pragma|values)\b", statement) \
            or re.search(r"(?is)\breturning\b", statement)
        if cursor.description and reads:
            out.append(table(cursor))
        elif re.match(r"(?is)\s*(insert|update|delete)\b", statement):
            out.append(f"*Rows changed: {max(cursor.rowcount, 0)}*")
    return "\n\n".join(out) or "*Done (no rows returned).*"


def render_examples(text: str, where: str) -> tuple[str, list[str]]:
    db = new_database()
    db.isolation_level = None
    runnable: list[str] = []

    def replace(match: re.Match) -> str:
        mode, sql = match.group(1), match.group(2)
        if mode == " norun":
            return f"```sql norun\n{sql}```\n"
        result = run_block(db, sql, mode, where)
        if mode is None:
            runnable.append(sql.strip())
        return f"```sql{mode or ''}\n{sql}```\n\n<!-- result -->\n{result}\n<!-- /result -->\n"

    try:
        return BLOCK.sub(replace, text), runnable
    finally:
        db.close()


def fill(text: str, marker: str, body: str, where: str) -> str:
    start, end = f"<!-- {marker} -->", f"<!-- /{marker} -->"
    if start not in text:
        return text
    if text.count(start) != 1 or end not in text:
        raise ValueError(f"{where}: needs exactly one {start} … {end}")
    before, rest = text.split(start, 1)
    return before + start + "\n" + body.rstrip() + "\n" + end + rest.split(end, 1)[1]


def exercise_list(lesson: str, bank: list[dict]) -> str:
    items = [i for i in bank if i["lesson"] == lesson]
    if not items:
        return "*No graded exercises for this lesson.*"
    rows = ["Each exercise is graded on the course data **and** an edge-case fixture. "
            "Write your answer in `practice/starter/<ID>.sql`.", "",
            "| ID | Exercise | Kind |", "|---|---|---|"]
    for item in items:
        rows.append(f"| `{item['id']}` | **{item['title']}.** {item['prompt']} | {KINDS[item['kind']]} |")
    first = items[0]["id"]
    rows += ["", "```bash", f"python tools/practice.py show {first}",
             f"python tools/practice.py check {first}", f"python tools/practice.py hint {first} 1",
             "```"]
    return "\n".join(rows)


def quiz_block(key: str, quiz: dict | None) -> str:
    if not quiz:
        return "*No quiz for this lesson.*"
    lines = ["Answer in your head first, then check. The answers are stored as hashes, "
             "so reading the files won't spoil them.", ""]
    for number, question in enumerate(quiz["questions"], 1):
        lines.append(f"**{number}.** {question['question']}")
        lines.append("")
        for letter, option in question["options"].items():
            lines.append(f"   - **{letter})** {option}")
        lines.append("")
    lines += ["```bash", f"python tools/quiz.py {key} 1 b      # question 1, answer b",
              f"python tools/quiz.py {key}           # list the questions", "```"]
    return "\n".join(lines)


def lesson_sql(md: Path, title: str, runnable: list[str]) -> str:
    rel = md.relative_to(ROOT).as_posix()
    head = [f"-- {title}", f"-- Examples from {rel}, in order, on a fresh sample database.",
            f"-- Run: python tools/run_sql.py {md.with_suffix('.sql').relative_to(ROOT).as_posix()}", ""]
    return "\n".join(head) + "\n\n".join(runnable) + "\n"


def build() -> dict[Path, str]:
    outputs: dict[Path, str] = {}
    for level in LEVELS:
        bank = json.loads((ROOT / "practice" / f"{level}.json").read_text(encoding="utf-8"))
        quiz_path = ROOT / "quizzes" / f"{level}.json"
        quizzes = json.loads(quiz_path.read_text(encoding="utf-8")) if quiz_path.exists() else {}
        pages = sorted((ROOT / level / "lessons").glob("[0-9][0-9]_*.md"))
        pages += sorted((ROOT / level / "worked_examples").glob("[0-9][0-9]_*.md"))
        for md in pages:
            where = md.relative_to(ROOT).as_posix()
            text = md.read_text(encoding="utf-8")
            title = text.splitlines()[0].removeprefix("# ").strip()
            text, runnable = render_examples(text, where)
            text = fill(text, "exercises", exercise_list(where, bank), where)
            if md.parent.name == "lessons":
                key = f"{level}/{md.name[:2]}"
                text = fill(text, "quiz", quiz_block(key, quizzes.get(key)), where)
            outputs[md] = text
            if runnable:
                outputs[md.with_suffix(".sql")] = lesson_sql(md, title, runnable)
    return outputs


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        outputs = build()
    except ValueError as error:
        print(f"FAIL {error}", file=sys.stderr)
        return 1
    stale = [path for path, text in outputs.items()
             if not path.exists() or path.read_text(encoding="utf-8") != text]
    if args.check:
        if stale:
            print("Out of date (run python tools/lessons.py): "
                  + ", ".join(p.relative_to(ROOT).as_posix() for p in stale), file=sys.stderr)
            return 1
        print(f"lessons up to date ({sum(p.suffix == '.md' for p in outputs)} pages)")
        return 0
    for path in stale:
        path.write_text(outputs[path], encoding="utf-8")
    print(f"updated {len(stale)} file(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
