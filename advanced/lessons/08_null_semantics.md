# 08 · NULL, anti-joins, and query correctness

**Learn**
- `NULL` is not equal to itself under `=`; use `IS NULL` for missing data.
- `NOT IN` can behave unexpectedly if its subquery includes NULL. Prefer `NOT EXISTS` for anti-matches.

**Run:** `python tools/run_sql.py advanced/lessons/08_null_semantics.sql`

**Practice**
1. Compare `NOT IN` and `NOT EXISTS` when the candidate list includes NULL.
2. Explain how a filter in WHERE can accidentally turn a LEFT JOIN into INNER.
3. Test duplicate rows and missing rows when validating a query rewrite.

**Check:** Use real row-count and reconciliation tests to validate critical reports.
