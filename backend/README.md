# Backend Database Engineering

Two runnable labs and eight SQL recipes. Python 3.10+; everything here uses **in-memory SQLite**.

```bash
python -m backend.lab
python -m backend.query_patterns
python tools/run_sql.py backend/sql/01_keyset_pagination.sql
python -m unittest discover -s tests -v
```

## Skills

| Topic | Practice |
|---|---|
| Data consistency | Atomic inventory reservation and rollback |
| Retries | Inbox, idempotency keys, conflict rejection, outbox |
| Multi-tenancy | Tenant-scoped queries and composite uniqueness |
| Pagination | Stable keyset cursors and compound indexes |
| Query performance | Detect and fix N+1 queries |
| SQL security | Bound values and allowlisted sort identifiers |
| Concurrent writes | Optimistic version checks |
| Migrations | Additive changes and expand/backfill/contract |
| Operations | Index plans, soft delete, audit queries |

**Resources:** [8 SQL recipes](sql/) · [design scenarios](SCENARIOS.md) · [production checklist](CHECKLIST.md) · [interview questions](../interview/BACKEND_QA.md).

These are educational examples, not production payment or authorization systems.
