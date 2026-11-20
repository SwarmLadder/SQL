# 01 · Query rewrites and correct grain

**Learn**
- Test correctness first: rewriting queries can change duplicate counts or NULL semantics.
- Pre-aggregate many-to-one relations before joining to other facts.

**Run:** `python tools/run_sql.py advanced/lessons/01_query_rewrites.sql`

**Practice**
1. Compare NOT EXISTS with a LEFT JOIN anti-match query.
2. Rewrite a correlated aggregate into a CTE with a JOIN.
3. Explain which rewrite loses order lines when a table is joined incorrectly.

**Check:** Different SQL expressions are only interchangeable under stated assumptions.
