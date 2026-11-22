#!/usr/bin/env python3
"""Lesson self-check quizzes. Answers are stored only as short hashes.

    python tools/quiz.py basics/05            # show the questions of a lesson
    python tools/quiz.py basics/05 2 c        # check your answer to question 2
    python tools/quiz.py --fingerprint basics/05 2 c   # for authors: the hash to store

After a correct answer you get the explanation. A wrong answer tells you which
lesson section to re-read, never the right letter.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
LEVELS = ("basics", "intermediate", "advanced")


def fingerprint(key: str, number: int, choice: str) -> str:
    return hashlib.sha256(f"sql-course-quiz|{key}|{number}|{choice.strip().lower()}".encode()).hexdigest()[:12]


def quizzes() -> dict[str, dict]:
    index: dict[str, dict] = {}
    for level in LEVELS:
        path = ROOT / "quizzes" / f"{level}.json"
        if path.exists():
            index.update(json.loads(path.read_text(encoding="utf-8")))
    return index


def grade(key: str, number: int, choice: str) -> tuple[bool, str]:
    quiz = quizzes().get(key)
    if quiz is None:
        raise KeyError(f"no quiz for {key}")
    if not 1 <= number <= len(quiz["questions"]):
        raise KeyError(f"{key} has questions 1–{len(quiz['questions'])}")
    question = quiz["questions"][number - 1]
    choice = choice.strip().lower()
    if choice not in question["options"]:
        raise KeyError(f"choose one of: {', '.join(question['options'])}")
    if fingerprint(key, number, choice) == question["answer"]:
        return True, f"✅ Q{number} correct. {question['explain']}"
    return False, f"❌ Q{number}: not quite. Re-read “{question['section']}” in {quiz['lesson']} and try again."


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--fingerprint", action="store_true")
    parser.add_argument("key", help="level/NN, e.g. basics/05")
    parser.add_argument("number", type=int, nargs="?")
    parser.add_argument("choice", nargs="?")
    args = parser.parse_args()
    if args.fingerprint:
        print(fingerprint(args.key, args.number, args.choice))
        return 0
    quiz = quizzes().get(args.key)
    if quiz is None:
        print(f"No quiz for {args.key}. Try e.g. basics/05.", file=sys.stderr)
        return 2
    if args.number is None or args.choice is None:
        print(f"Quiz for {quiz['lesson']}\n")
        for n, question in enumerate(quiz["questions"], 1):
            print(f"{n}. {question['question']}")
            for letter, option in question["options"].items():
                print(f"     {letter}) {option}")
            print()
        print(f"Check one: python tools/quiz.py {args.key} 1 b")
        return 0
    try:
        ok, message = grade(args.key, args.number, args.choice)
    except KeyError as error:
        print(error.args[0], file=sys.stderr)
        return 2
    print(message)
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
