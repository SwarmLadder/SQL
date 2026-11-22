# Contributing

How the course is maintained. Questions, typo reports and "this confused me" issues are welcome: use the issue templates.

## Ground rules

1. Explain one topic per lesson, with a paired `.md` and `.sql` file.
2. Use the sample dataset in `data/`; never include personal data or credentials.
3. Keep PostgreSQL-only syntax in `advanced/postgresql/`. Everything else must run on SQLite.
4. Store money as integer cents.
5. Keep reference answers out of lessons and hints. Learners should be able to read everything except `practice/answers/` and `interview/reference/` without spoilers.

## Run every check

```bash
python tools/lessons.py --check
python tools/level_index.py --check
python tools/run_sql.py --check
python tools/interview_practice.py verify-reference
python tools/schema_practice.py verify-reference
python tools/practice.py verify-reference
python tools/practice_docs.py --check
python -m unittest discover -s tests -v
```

CI runs the same commands on every pull request.

## Write or change a lesson

Read the [authoring guide](curriculum/AUTHORING.md) first. In short: edit the lesson's Markdown, never type result tables by hand, and run

```bash
python tools/lessons.py
```

to execute the examples and refresh results, exercise lists, quizzes and the lesson's `.sql` file. Then update [`curriculum/concepts.json`](curriculum/concepts.json) if the lesson introduces or relies on new concepts, and run `python tools/level_index.py` if you changed a title or time.

## Add or change a practice exercise

Exercises live in `practice/<level>.json`. Each one has:

| Field | Meaning |
|---|---|
| `id` | `PB..`, `PI..` or `PA..` + two digits; never reuse an ID |
| `lesson` | the lesson file it practises |
| `title`, `prompt` | the task. Name every output column, the filter and the full sort order, so exactly one result is correct |
| `kind` | `query`, `script` or `written` (see [practice/README.md](practice/README.md#exercise-kinds)) |
| `hints` | three hints: a nudge, the approach, then near-syntax. Never the whole answer |
| `ordered` | optional, default `true`; set `false` only if the prompt allows any order |
| `check_columns` | optional; also compare column names (only when the prompt asks for specific aliases) |
| `probe` | script only: statements run after the learner's script; each must be accepted/rejected like the reference |
| `verify` | script only: read-only queries whose results must match the reference |
| `plan` | script only: `query`, `require_any`, `forbid`: rules on `EXPLAIN QUERY PLAN` output |

Then add `practice/answers/<id>.sql` (the reference) and `practice/starter/<id>.sql` (comments only, as in the existing files), and run `python tools/practice_docs.py` and `python tools/lessons.py` to refresh the tables and the lesson's *Your turn* section.

## Add or change a quiz question

Quizzes live in `quizzes/<level>.json`. Answers are stored as hashes, never as letters:

```bash
python tools/quiz.py --fingerprint basics/05 2 c   # the value for "answer"
```

Each question needs `question`, `options` (a, b, c), `answer` (the fingerprint), `section` (the exact lesson heading to re-read) and `explain` (shown after a correct answer). Then run `python tools/lessons.py`.

**Make the edge fixture matter.** Before submitting, write the most likely *wrong* answer and confirm the checker rejects it:

```bash
python tools/practice.py check PI05 my_wrong_attempt.sql   # must print ❌
```

If it passes, tighten the prompt or add rows to `PRACTICE_EDGE_SQL` in `tools/practice.py`, then re-run `verify-reference`. Changing `EDGE_SQL` in `tools/interview_practice.py` affects the 48 interview checks too.
