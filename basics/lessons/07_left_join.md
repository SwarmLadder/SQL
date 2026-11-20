# 07 · LEFT JOIN and missing data

**Learn**
- `LEFT JOIN` keeps rows from the left side even when no match exists.
- Filter unmatched rows with `WHERE right.key IS NULL`.

**Run:** `python tools/run_sql.py basics/lessons/07_left_join.sql`

**Practice**
1. Find products that were never ordered.
2. List employees and their managers, including team leads.
3. Count orders per customer, including customers with zero orders.

**Check:** For left joins, moving a right-side filter from `ON` to `WHERE` can remove unmatched rows.
