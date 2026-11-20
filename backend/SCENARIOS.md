# Backend System Design Practice — Database Scenarios

Pick one scenario. Sketch tables, constraints, queries, transaction boundaries, indexes, failure modes, and tests. Aim for a 10-minute explanation.

| Scenario | Key requirements | Strong answer mentions |
|---|---|---|
| 1. Shopping checkout | Prevent oversell; charge exactly once | atomic conditional UPDATE, idempotency, outbox |
| 2. Webhook ingestion | Duplicates and out-of-order events | inbox unique keys, replay policy, ordering |
| 3. Multi-tenant SaaS | Tenant-specific customers/orders | tenant-key filters, composite keys, RLS |
| 4. Timeline API | Stable feed pagination | composite index and keyset cursor |
| 5. Job workers | Claim work without duplicates | locks, leases, SKIP LOCKED (Postgres) |
| 6. Subscriptions | Renewals, retries, cancellation | state machine, unique invoices, audit trail |
| 7. Blog comments | Nested replies and moderation | parent foreign key, recursive CTE, soft delete |
| 8. Inventory catalog | Frequent reads and price updates | indexes, versioning, cache invalidation |
| 9. Financial ledger | Auditable balance history | append-only entries, integer money, reconciliation |
| 10. Analytics dashboard | High-volume order summaries | report grain, CTEs, materialized summaries |
| 11. Database migration | Add required column without downtime | expand/backfill/contract, mixed-version clients |
| 12. Read scaling | Heavy traffic and stale replicas | pooling, read replicas, consistency budget |

**Scoring:** data model (25), correctness under concurrency (25), performance (20), recovery (15), clarity (15).

**Hands-on companion:** `python -m backend.lab`. Avoid describing this teaching lab as a production payment system.
