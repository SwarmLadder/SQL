# 03 · Atomic changes and savepoints

**Learn**
- Transactions make related writes commit or roll back together.
- Savepoints create nested rollback points. The example restores all changed data.

**Run:** `python tools/run_sql.py advanced/lessons/03_transactions_savepoints.sql`

**Practice**
1. Use a savepoint to temporarily change an order's status and undo it.
2. Explain why transferring funds requires one transaction.
3. Explain how isolation and locking differ between SQLite and PostgreSQL.

**Check:** The SQLite runner starts each SQL file with a fresh in-memory database.
