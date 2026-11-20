# 00 · Indexes and query plans

**Learn**
- Indexes speed some lookups but add storage and write cost.
- `EXPLAIN QUERY PLAN` describes SQLite's chosen operations; actual speed depends on data.

**Run:** `python tools/run_sql.py advanced/lessons/00_indexes_explain.sql`

**Practice**
1. Create an index supporting frequent searches by product name.
2. Explain why indexing every column is a poor default.
3. Compare an index plan and a scan plan on the sample data.

**Check:** `EXPLAIN QUERY PLAN` shows a plan, not a measured wall-clock performance claim.
