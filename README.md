# SQL & Database Engineering

Practical SQL course by **SwarmLadder**. Short lessons, runnable queries, exercises, and projects.

| Level | Lessons | Practice | Projects |
|---|---:|---:|---:|
| [Basics](basics/README.md) | 10 | 20 tasks | 2 |
| [Intermediate](intermediate/README.md) | 10 | 20 tasks | 2 |
| [Advanced](advanced/README.md) | 10 | 20 tasks | 2 |
| **Total** | **30** | **60** | **6** |

Also includes **24 worked reference queries** and optional **PostgreSQL-specific examples**.

## Start

Requires **Python 3.10+**; SQLite is included with Python. No pip packages or database server needed.

```bash
git clone https://github.com/SwarmLadder/sql-course.git
cd sql-course
python tools/run_sql.py basics/lessons/00_select.sql
```

The runner loads a fresh **in-memory SQLite database** each time. It won't change local databases.

## Check everything

```bash
python tools/run_sql.py --check
python -m unittest discover -s tests -v
```

## Course content

- [Basics](basics/README.md): SELECT, filters, sorting, aggregation, joins, editing rows.
- [Intermediate](intermediate/README.md): subqueries, CTEs, windows, dates, views, transactions.
- [Advanced](advanced/README.md): indexes, EXPLAIN, recursion, constraints, UPSERT, triggers, reconciliation.
- [Dataset and schema](data/README.md): customers, orders, products, payments, employees.
- [PostgreSQL lab](advanced/postgresql/README.md): optional database-server examples.

**Learning routine:** Read a lesson's Markdown, run its matching SQL file, then solve its three questions. Work through the 20-task practice set and two projects per level.

**Note:** Main lessons use SQLite syntax. PostgreSQL examples are separate and are not part of automated SQLite checks.

[MIT License](LICENSE).
