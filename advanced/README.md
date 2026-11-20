# Advanced · Performance, integrity, and operational SQL

Study lessons in order. Each lesson has a brief explanation, a runnable `.sql` file, and three tasks.

| # | Lesson |
|---:|---|
| 00 | [Indexes and EXPLAIN](lessons/00_indexes_explain.md) |
| 01 | [Query rewrites](lessons/01_query_rewrites.md) |
| 02 | [Recursive CTEs](lessons/02_recursive_cte.md) |
| 03 | [Transactions](lessons/03_transactions_savepoints.md) |
| 04 | [UPSERT and idempotency](lessons/04_upsert_idempotency.md) |
| 05 | [Triggers](lessons/05_triggers_audit.md) |
| 06 | [Summary freshness](lessons/06_summary_tables.md) |
| 07 | [Constraints and migrations](lessons/07_constraints_migrations.md) |
| 08 | [NULL correctness](lessons/08_null_semantics.md) |
| 09 | [Analytics review](lessons/09_advanced_capstone.md) |

## Practice

- [20 exercises](exercises/README.md)
- [8 reference queries](solutions/README.md)
- [Two projects](projects/README.md)

## Run

```bash
python tools/run_sql.py advanced/lessons/00_indexes_explain.sql
```

Advanced also offers [optional PostgreSQL labs](postgresql/README.md).
