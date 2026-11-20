# Backend Database Interview — Quick Answers

Short answers to common interview follow-ups. Be ready to demonstrate each one with a query.

## Data modeling
1. **Primary key?** Uniquely identifies a row; choose a stable key.
2. **Foreign key?** Enforces a relationship between tables when enabled.
3. **UNIQUE vs primary key?** Both enforce uniqueness; a table has one declared primary key.
4. **Normalization?** Avoid repeated facts and update anomalies; denormalize for measured needs.
5. **One-to-many?** Store the parent key in the child.
6. **Many-to-many?** Use a junction table with a composite uniqueness constraint.
7. **Money type?** Prefer integer minor units or exact DECIMAL/NUMERIC, not binary floats.

## Query correctness
8. **INNER vs LEFT JOIN?** INNER matches both sides; LEFT retains unmatched left rows.
9. **Why row multiplication?** Joining multiple one-to-many facts expands combinations.
10. **Fix multiplied sums?** Aggregate each fact to the required grain before joining.
11. **WHERE vs HAVING?** WHERE filters rows; HAVING filters groups.
12. **COUNT(*) vs COUNT(child.id)?** COUNT(*) includes unmatched LEFT JOIN rows.
13. **NULL equality?** Use IS NULL, not = NULL.
14. **NOT IN pitfall?** A NULL in the set can yield UNKNOWN; prefer NOT EXISTS.
15. **ROW_NUMBER vs RANK?** ROW_NUMBER creates unique row positions; RANK keeps ties and skips ranks.
16. **CTE faster than subquery?** Not necessarily; inspect plans and actual measurements.

## Indexing and performance
17. **When add an index?** For measured frequent filters, joins, or orderings.
18. **Index downside?** Extra storage, writes, and maintenance.
19. **Composite index order?** Match filtering and sorting patterns, not alphabetical columns.
20. **EXPLAIN vs EXPLAIN ANALYZE?** Planner estimate vs actual execution (PostgreSQL).
21. **Why N+1?** Fetching parents then querying each child individually; batch/join instead.
22. **OFFSET vs keyset?** OFFSET skips rows and can shift; keyset resumes by stable indexed cursor.
23. **Covering index?** Contains columns needed to answer a query without extra table lookups when supported.

## Transactions and concurrency
24. **ACID?** Atomicity, Consistency, Isolation, Durability.
25. **Lost update?** One write overwrites another; use locks or version checks.
26. **Write skew?** Concurrent transactions satisfy individual checks yet break a shared invariant.
27. **Deadlock?** Transactions wait cyclically; use consistent lock order and bounded retry.
28. **Isolation levels?** Trade off anomalies, concurrency and overhead; semantics vary by DB.
29. **Optimistic locking?** UPDATE ... WHERE version=old_version; detect zero updated rows.
30. **Pessimistic locking?** Lock selected rows during the transaction (e.g. PostgreSQL FOR UPDATE).
31. **UPSERT?** Insert or resolve a unique-key conflict atomically.

## Reliability
32. **Idempotency key?** Identifies one logical request so safe retries do not duplicate effects.
33. **What must be atomic?** Business change and durable request/outcome record.
34. **Outbox pattern?** Store intended event in the same transaction as business data.
35. **Inbox pattern?** Deduplicate incoming event processing using durable identifiers.
36. **Exactly-once delivery?** Usually not guaranteed end-to-end; design exactly-once effects with deduplication.

## Backend security and operations
37. **SQL injection defense?** Parameterize values; allowlist dynamic identifiers.
38. **Multi-tenant isolation?** Every data access must scope tenant identity; enforce policies in DB when possible.
39. **Connection pooling?** Reuse connections with limits; never leak connections across requests/transactions.
40. **Zero-downtime migration?** Expand schema, deploy compatible code, backfill, then contract.
41. **Soft delete trade-off?** Easier recovery; all queries/unique constraints must account for tombstones.
42. **Backup confidence?** Test restoration and recovery objectives, not only backup creation.
43. **Read replica trade-off?** Scales reads but may be eventually consistent/lagging.
44. **Cache invalidation?** Define TTL, ownership, consistency, and invalidation triggers.
45. **Database observability?** Query latency, slow statements, locks, errors, pool utilization, disk and replicas.
46. **Rate limiting?** Bound requests over time; a concurrency semaphore is different.
47. **Schema migration rollback?** Plan compatibility and data recovery before deployment.
48. **Database vs queue?** DB stores authoritative state; queue distributes work with retry semantics.

For deeper practice, use [48 SQL coding questions](README.md) and [backend design scenarios](../backend/SCENARIOS.md).
