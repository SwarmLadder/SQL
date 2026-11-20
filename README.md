# SQL & Backend Database Interviews

A hands-on SQL course for **backend developer interviews and database engineering practice**.

| Learning material | Count |
|---|---:|
| [Guided lessons](basics/README.md) across 3 levels | 30 |
| [Graded interview challenges](interview/README.md) | 48 |
| Additional [course exercises](basics/exercises/README.md) | 60 |
| [Projects](basics/projects/README.md) | 6 |
| Backend SQL recipes | 8 |
| [PostgreSQL labs](advanced/postgresql/README.md) | 9 |

## Start an interview question

```bash
git clone https://github.com/SwarmLadder/sql-course.git
cd sql-course
python tools/interview_practice.py list
python tools/interview_practice.py show B10
```

Write your answer in `interview/starter/B10.sql`, then check:

```bash
python tools/interview_practice.py check B10 interview/starter/B10.sql
```

The checker compares output against **two datasets**, including edge cases. It runs locally with Python 3.10+ and SQLite, with no external database.

## Learning paths

- [Basics](basics/README.md): SQL foundations, joins, aggregation, updates.
- [Intermediate](intermediate/README.md): CTEs, window functions, dates, reports.
- [Advanced](advanced/README.md): indexes, transactions, concurrency-related SQL, reconciliation.
- [Backend engineering lab](backend/README.md): tenancy, safe SQL, N+1, keyset pagination, optimistic locking, stock reservation, idempotent requests, outbox.
- [Mock interview rounds](interview/MOCK_INTERVIEWS.md): junior, backend, senior.
- [48 short backend Q&As](interview/BACKEND_QA.md) and [12 design scenarios](backend/SCENARIOS.md).
- [Four-week interview plan](interview/ROADMAP.md).

## Run and test

```bash
python tools/run_sql.py basics/lessons/00_select.sql
python -m backend.lab
python -m backend.query_patterns
python tools/interview_practice.py verify-reference
python tools/run_sql.py --check
python -m unittest discover -s tests -v
```

**Dataset:** fictional customers, orders, products, payments, and employees. Every SQLite run uses a fresh **in-memory database**.

**PostgreSQL:** optional dialect-specific labs require a separate disposable PostgreSQL server; they are not part of SQLite CI.

[MIT License](LICENSE) · [Contributing](CONTRIBUTING.md)
