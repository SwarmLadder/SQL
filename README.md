# SQL & Backend Database Interviews

A free, hands-on SQL course from first `SELECT` to production database engineering, built for **backend developer interviews and real work**. Every lesson runs its examples on a real (fictional) shop database and shows the actual results; every exercise is graded automatically on two datasets, so a query that only works on the visible data fails.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/SwarmLadder/SQL)

**No install needed:** Codespaces opens the course with Python and SQLite ready, including every checker. Locally you only need Python 3.10+ (no database server).

| Level | Lessons (each with a quiz) | Graded exercises | Quiz questions | Worked examples | Projects | Interview challenges |
|---|---:|---:|---:|---:|---:|---:|
| [Basics](basics/README.md) | 10 | 58 | 39 | 6 | 3 | 16 |
| [Intermediate](intermediate/README.md) | 10 | 47 | 40 | 6 | 3 | 16 |
| [Advanced](advanced/README.md) | 10 | 34 + 4 written | 39 | 6 | 3 | 16 |
| **Total** | **30** | **139** | **118** | **18** | **9** | **48** |

Plus 4 graded [schema design challenges](interview/schema/README.md), 8 [backend SQL recipes](backend/README.md) and 9 optional [PostgreSQL labs](advanced/postgresql/README.md).

## Start on your computer

```bash
git clone https://github.com/SwarmLadder/SQL.git
cd SQL
python tools/run_sql.py basics/lessons/00_select.sql     # run a lesson's examples
python tools/practice.py show PB01                         # read your first exercise
```

Open [basics/lessons/00_select.md](basics/lessons/00_select.md) and start reading.

## Start an interview question

```bash
git clone https://github.com/SwarmLadder/SQL.git
cd SQL
python tools/interview_practice.py list
python tools/interview_practice.py show B10
```

Write your answer in `interview/starter/B10.sql`, then check:

```bash
python tools/interview_practice.py check B10 interview/starter/B10.sql
```

The checker compares output against **two datasets**, including edge cases. It runs locally with Python 3.10+ and SQLite, with no external database.

## How to study

1. **Read a lesson.** Predict each example's result before you look at the table under it, then run the lesson's `.sql` file and change things.
2. **Solve the lesson's exercises** (its *Your turn* section):
   ```bash
   python tools/practice.py show PB05
   python tools/practice.py check PB05      # grades practice/starter/PB05.sql
   python tools/practice.py hint PB05 1     # hints get more specific: 1, 2, 3
   ```
   Every answer runs on the course data **and** an edge-case fixture. ❌ tells you what differs, never the answer.
3. **Take the lesson's quick quiz:** `python tools/quiz.py basics/05 2 c`. Answers are stored as hashes; a correct answer explains why.
4. **Study the worked examples** (`<level>/worked_examples/`): plan, a tempting wrong attempt, the fix, and the test.
5. **Answer the interview challenges** of the level, then build the three projects.
6. **Take the level's assessment** (`<level>/ASSESSMENT.md`) and check yourself with `python tools/verify_level.py <level>`.

## Learning paths

- [Basics](basics/README.md): SQL foundations, joins, aggregation, updates.
- [Intermediate](intermediate/README.md): CTEs, window functions, dates, reports.
- [Advanced](advanced/README.md): indexes, transactions, concurrency-related SQL, reconciliation.
- [Backend engineering lab](backend/README.md): tenancy, safe SQL, N+1, keyset pagination, optimistic locking, stock reservation, idempotent requests, outbox.
- [Mock interview rounds](interview/MOCK_INTERVIEWS.md): junior, backend, senior.
- [Schema design interviews](interview/schema/README.md): constraints, partial indexes, queues, webhook deduplication.
- [48 short backend Q&As](interview/BACKEND_QA.md) and [12 design scenarios](backend/SCENARIOS.md).
- [Four-week interview plan](interview/ROADMAP.md).

## Run and test

```bash
python tools/run_sql.py basics/lessons/00_select.sql
python -m backend.lab
python -m backend.query_patterns
python tools/interview_practice.py verify-reference
python tools/schema_practice.py verify-reference
python tools/practice.py verify-reference
python tools/lessons.py --check
python tools/practice_docs.py --check
python tools/level_index.py --check
python tools/run_sql.py --check
python -m unittest discover -s tests -v
```

**Dataset:** fictional customers, orders, products, payments, and employees. Every SQLite run uses a fresh **in-memory database**.

**PostgreSQL:** optional dialect-specific labs require a separate disposable PostgreSQL server; they are not part of SQLite CI.

[MIT License](LICENSE) · [Contributing](CONTRIBUTING.md)
