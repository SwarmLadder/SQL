# 05 · GROUP BY and HAVING

**Learn**
- `GROUP BY` forms groups before aggregates are evaluated.
- `HAVING` filters groups; `WHERE` filters individual rows.

**Run:** `python tools/run_sql.py basics/lessons/05_group_by_having.sql`

**Practice**
1. Find cities with at least one registered customer.
2. Find categories with more than two products.
3. Count orders per month using `SUBSTR(ordered_at, 1, 7)`.

**Check:** Group by the columns that identify each report grain.
