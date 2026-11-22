#!/usr/bin/env python3
"""Regenerate the exercise tables in practice/README.md and <level>/exercises/README.md.

    python tools/practice_docs.py          # rewrite the files
    python tools/practice_docs.py --check  # fail if they are out of date (used by tests)
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
LEVELS = {"basics": "Basics", "intermediate": "Intermediate", "advanced": "Advanced"}
KIND = {"query": "query", "script": "script", "written": "written ✍️"}
START, END = "<!-- exercises:start -->", "<!-- exercises:end -->"


def bank(level: str) -> list[dict]:
    return json.loads((ROOT / "practice" / f"{level}.json").read_text(encoding="utf-8"))


def table(level: str, link_prefix: str) -> str:
    rows = ["| ID | Exercise | Kind | Lesson |", "|---|---|---|---|"]
    for item in bank(level):
        lesson = item["lesson"]
        name = Path(lesson).stem.split("_", 1)[1].replace("_", " ")
        exercise = item["title"]
        if item["kind"] != "written":
            exercise = f"[{item['title']}]({link_prefix}practice/starter/{item['id']}.sql)"
        rows.append(f"| `{item['id']}` | {exercise} | {KIND[item['kind']]} | "
                    f"[{lesson.split('/')[2][:2]} {name}]({link_prefix}{lesson}) |")
    return "\n".join(rows)


def level_readme(level: str) -> str:
    items = bank(level)
    graded = sum(i["kind"] != "written" for i in items)
    written = [i for i in items if i["kind"] == "written"]
    parts = [f"# {LEVELS[level]} Practice · {len(items)} tasks", "",
             f"{graded} of these tasks are **graded automatically** on the course dataset and on an "
             "edge-case fixture. Each one has three hints that get more specific.", "",
             "```bash",
             f"python tools/practice.py list --level {level}",
             f"python tools/practice.py show {items[0]['id']}",
             f"python tools/practice.py check {items[0]['id']}      # grades practice/starter/{items[0]['id']}.sql",
             f"python tools/practice.py hint {items[0]['id']} 1",
             f"python tools/practice.py progress {level}",
             "```", "", START, table(level, "../../"), END, ""]
    if written:
        parts += ["## Written tasks", "",
                  "These have no automatic grade. Answer them in your notes, in a study group, or in "
                  "your achievement PR description.", ""]
        parts += [f"- **{i['id']} · {i['title']}.** {i['prompt']}" for i in written]
        parts.append("")
    parts += ["See [how practice works](../../practice/README.md). Stuck? Read the hints before the "
              "[worked examples](../worked_examples/README.md).", ""]
    return "\n".join(parts)


def practice_readme(current: str) -> str:
    before, rest = current.split(START, 1)
    after = rest.split(END, 1)[1]
    body = []
    for level, title in LEVELS.items():
        body += [f"### {title}", "", table(level, "../"), ""]
    return before + START + "\n" + "\n".join(body).rstrip() + "\n" + END + after


def outputs() -> dict[Path, str]:
    files = {ROOT / level / "exercises" / "README.md": level_readme(level) for level in LEVELS}
    readme = ROOT / "practice" / "README.md"
    files[readme] = practice_readme(readme.read_text(encoding="utf-8"))
    return files


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    stale = []
    for path, text in outputs().items():
        if path.read_text(encoding="utf-8") != text:
            stale.append(path.relative_to(ROOT))
            if not args.check:
                path.write_text(text, encoding="utf-8")
    if args.check and stale:
        print("Out of date (run python tools/practice_docs.py): " + ", ".join(map(str, stale)), file=sys.stderr)
        return 1
    print("practice docs up to date" if not stale else "updated: " + ", ".join(map(str, stale)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
