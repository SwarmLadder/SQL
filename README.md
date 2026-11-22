# SQL & Backend Database Interviews

A hands-on SQL course for **backend developer interviews and database engineering practice**.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/SwarmLadder/SQL)

**No install needed:** Codespaces opens the course with Python and SQLite ready, including every checker. Locally you only need Python 3.10+ (no database server).

| Learning material | Count |
|---|---:|
| [Guided lessons](basics/README.md) across 3 levels | 30 |
| [Graded practice exercises](practice/README.md) with progressive hints | 56 (+4 written) |
| [Worked examples](basics/worked_examples/README.md) | 6 |
| [Graded SQL interview challenges](interview/README.md) | 48 |
| [Graded schema design challenges](interview/schema/README.md) | 4 |
| [Projects](basics/projects/README.md) | 6 |
| Backend SQL recipes | 8 |
| [PostgreSQL labs](advanced/postgresql/README.md) | 9 |

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

1. **Read a lesson** and run its `.sql` file. Predict each result before you look.
2. **Solve its practice exercises.** Each lesson's exercises are listed in `<level>/exercises/README.md`:
   ```bash
   python tools/practice.py show PB05
   python tools/practice.py check PB05      # grades practice/starter/PB05.sql
   python tools/practice.py hint PB05 1     # hints get more specific: 1, 2, 3
   ```
   Every answer runs on the course data **and** an edge-case fixture. ❌ tells you what differs, never the answer.
3. **Study the worked examples** (`<level>/worked_examples/`): plan, a tempting wrong attempt, the fix, and the test.
4. **Answer the interview challenges** of the level, then build the projects.
5. **Take the level's assessment** (`<level>/ASSESSMENT.md`) and check yourself with `python tools/verify_level.py <level>`.

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
python tools/practice_docs.py --check
python tools/run_sql.py --check
python -m unittest discover -s tests -v
```

**Dataset:** fictional customers, orders, products, payments, and employees. Every SQLite run uses a fresh **in-memory database**.

**PostgreSQL:** optional dialect-specific labs require a separate disposable PostgreSQL server; they are not part of SQLite CI.

[MIT License](LICENSE) · [Contributing](CONTRIBUTING.md)
