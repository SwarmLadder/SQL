# 04 · COUNT, SUM, MIN, MAX, AVG

**Learn**
- Aggregates summarize many rows into one result; `COUNT(*)` counts rows.
- `COUNT(column)` excludes NULL, and `SUM`/`AVG` operate on non-NULL values.

**Run:** `python tools/run_sql.py basics/lessons/04_aggregates.sql`

**Practice**
1. Count active and inactive products.
2. Compute the total units sold from `order_items`.
3. Find the average employee salary in integer cents.

**Check:** AVG is not always an integer, even when inputs are.
