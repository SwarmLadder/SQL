# Backend Database Engineering

Hands-on patterns for backend interviews. Uses Python's standard library and **in-memory SQLite**.

## Run the lab

```bash
python -m backend.lab
python -m unittest discover -s tests -v
```

The runnable lab covers **multi-tenant SQL scoping, keyset pagination, inventory reservation, idempotency, transactional inbox/outbox, and rollback**.

## Interview topics

| Area | What you should explain |
|---|---|
| Data modeling | keys, relationships, constraints, normalization |
| Application queries | joins, aggregate grain, NULLs, pagination |
| Performance | composite indexes, EXPLAIN, N+1 queries |
| Correctness | transactions, isolation, locks, deadlocks |
| Reliability | retries, idempotency keys, inbox/outbox |
| Security | SQL injection, tenant filters, least privilege |
| Production | migrations, backups, pooling, observability |
| PostgreSQL | MVCC, row locks, SKIP LOCKED, JSONB |

See [backend design scenarios](SCENARIOS.md), [production checklist](CHECKLIST.md), [interview Q&A](../interview/BACKEND_QA.md), and [PostgreSQL labs](../advanced/postgresql/README.md).

**Scope:** These are learning examples, not production payment or authorization systems.
