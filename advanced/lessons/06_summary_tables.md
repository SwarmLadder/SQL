# 06 · Summary tables and freshness

**Learn**
- SQLite views compute from source rows; a summary table stores a snapshot.
- Materialized summaries are faster to read only when their refresh and correctness costs are managed.

**Run:** `python tools/run_sql.py advanced/lessons/06_summary_tables.sql`

**Practice**
1. Explain why the snapshot becomes stale after a new paid order.
2. Describe an atomic refresh strategy for a summary table.
3. Design a summary table by customer and month with a unique key.

**Check:** SQLites's `CREATE TABLE AS SELECT` is a snapshot, not automatic materialization.
