# Production Database Checklist

1. Define primary keys, foreign keys, UNIQUE and CHECK constraints.
2. Use parameterized SQL and restrict DB account privileges.
3. Scope queries and writes to the authenticated tenant.
4. Use transactions for multi-step state changes.
5. Enforce idempotency and replay conflicts in durable storage.
6. Use outbox/inbox for reliable external event processing.
7. Bound queries, timeouts, pagination, retries, and connection pools.
8. Confirm indexes with real workloads and query plans.
9. Test zero-downtime migrations with old and new app versions.
10. Monitor slow queries, deadlocks, pool saturation, disk and replica lag.
11. Test backups, restores, retention, encryption, and disaster recovery.
12. Include failure-injection, concurrency, and isolation tests.

**Practice:** [Backend lab](lab.py) · [Scenarios](SCENARIOS.md) · [Interview Q&A](../interview/BACKEND_QA.md).
