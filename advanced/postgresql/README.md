# PostgreSQL lab (optional)

**Dialect:** PostgreSQL 16+; **not** compatible with SQLite. These are short, standalone PostgreSQL examples.

Run in a disposable PostgreSQL database with `psql`:

```bash
psql -v ON_ERROR_STOP=1 -d your_disposable_database -f advanced/postgresql/01_jsonb.sql
```

| Lab | Topic |
|---|---|
| [01](01_jsonb.sql) | JSONB and GIN index |
| [02](02_row_locks.sql) | Row locks and safe updates |
| [03](03_query_plans.sql) | EXPLAIN ANALYZE and buffers |
| [04](04_materialized_view.sql) | Materialized views and refresh |
| [05](05_skip_locked.sql) | SKIP LOCKED work queues |
| [06](06_isolation.sql) | Transaction isolation |
| [07](07_keyset_index.sql) | Keyset pagination and composite indexes |
| [08](08_outbox_transaction.sql) | Atomic outbox storage |
| [09](09_optimistic_concurrency.sql) | Version-checked updates |

Each lab rolls back its demonstration writes where applicable. These scripts are **not checked in SQLite CI**; run them separately in PostgreSQL before relying on them.

For real systems: plan permissions, migrations, monitoring, backups, and concurrency tests.
