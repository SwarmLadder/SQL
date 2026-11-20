# Advanced Practice · 20 tasks

Use the [sample database](../../data/README.md). Write your answers in a new SQL file and run it with `python tools/run_sql.py path/to/file.sql`. Every result needs a check for filters, duplicates, and missing values.

1. Explain a plan using EXPLAIN QUERY PLAN.
2. Create an index for a frequent WHERE + ORDER BY access path.
3. Explain the read/write cost of maintaining indexes.
4. Rewrite an EXISTS filter as a JOIN without duplicate rows.
5. Find a correlated subquery and describe an aggregate CTE alternative.
6. Walk the employee hierarchy using WITH RECURSIVE.
7. Add a depth limit and discuss cycle handling.
8. Use a savepoint to verify rollback of two updates.
9. Create an idempotent request table with unique keys.
10. Implement an UPSERT for a category counter.
11. Reject conflicting idempotency payloads by policy.
12. Add a trigger logging changes to a selected field.
13. Explain why triggers are not complete audit security.
14. Build a snapshot summary table and show staleness after source changes.
15. Create a constrained table with UNIQUE and CHECK.
16. Plan a non-breaking additive schema migration.
17. Demonstrate the NULL trap in NOT IN.
18. Build an order-to-payment reconciliation with mismatch flags.
19. Build a top-customer ranking with DENSE_RANK.
20. Write a query correctness checklist for a revenue report.

Representative answers: [solutions](../solutions/README.md).
