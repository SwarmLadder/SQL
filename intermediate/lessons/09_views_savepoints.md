# 09 · Views, savepoints, and transactions

**Learn**
- Views encapsulate reusable SELECT statements but usually do not materialize rows.
- Transactions group changes; savepoints allow rolling back part of a transaction.

**Run:** `python tools/run_sql.py intermediate/lessons/09_views_savepoints.sql`

**Practice**
1. Create a view for paid customers with lifetime spend.
2. Use a savepoint to test and undo a scoped update.
3. Explain why a view query can produce a different result after underlying data changes.

**Check:** A transaction context and explicit CLOSE are separate resource concerns.
