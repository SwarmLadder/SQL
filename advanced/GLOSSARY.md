# Advanced SQL Glossary

Terms used across the 10 Advanced lessons, exercises PA01–PA20 and the backend lab.

| Term | Definition |
|---|---|
| Additive migration | A schema change that only adds (columns with defaults, tables, indexes), so old code keeps working. |
| Audit trail | A record of who changed what and when. Trustworthy only if writers cannot also edit or bypass it. |
| `CHECK` constraint | A rule every row must satisfy, e.g. `percent_off BETWEEN 1 AND 90`. |
| Composite index | An index on several columns; usable left to right (equality columns first, then range or sort). |
| Covering index | An index that contains every column a query needs, so the table itself isn't read. |
| Expand / migrate / contract | Zero-downtime migration pattern: add the new shape, move data and code, then remove the old shape. |
| `EXPLAIN QUERY PLAN` | SQLite command showing how a query will run: `SCAN` (read all) vs `SEARCH` (use an index). |
| Expression index | An index on a computed value, e.g. `json_extract(payload_json, '$.order_id')`. |
| Idempotency | Repeating an operation has the same effect as doing it once; essential for retries. |
| Idempotency key | A client-supplied unique key stored with a request hash, so retries can be recognised. |
| Isolation | How much concurrent transactions see of each other's uncommitted or committed work. |
| Keyset pagination | Paging with `WHERE (sort_key, id) > (last_seen…)` instead of `OFFSET`, so cost doesn't grow with depth. |
| Lost update | Two transactions read the same value and both write, so one change silently disappears. |
| `NOT IN` trap | `x NOT IN (subquery)` is never true if the subquery returns a `NULL`; use `NOT EXISTS`. |
| Optimistic locking | Detecting conflicting writes with a version column (`WHERE version = ?`) instead of locks. |
| Outbox | Writing an event to a table in the same transaction as the data change, then publishing it later. |
| Reconciliation | Comparing two sources that should agree (order totals vs payments) and flagging differences. |
| Recursive CTE | `WITH RECURSIVE`: an anchor query plus a member that refers to the CTE, repeated until no new rows. |
| Snapshot / summary table | Pre-computed results stored as rows; fast to read, stale until rebuilt. |
| Temp B-tree | A temporary structure SQLite builds to sort or de-duplicate when no index provides the order. |
| Trigger | SQL that runs automatically before or after `INSERT`, `UPDATE` or `DELETE` on a table. |
| Unique index | An index that rejects duplicate key values; the database-level guarantee behind idempotency. |
| UPSERT | `INSERT … ON CONFLICT (key) DO UPDATE`: insert or update atomically in one statement. |
| Write amplification | Extra work each write causes, e.g. updating every index on the table. |
