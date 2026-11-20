# 08 · UNION, INTERSECT, EXCEPT

**Learn**
- Set operations combine compatible result sets. `UNION` removes duplicates; `UNION ALL` retains them.
- `INTERSECT` finds shared rows; `EXCEPT` finds rows in the left set but not right.

**Run:** `python tools/run_sql.py intermediate/lessons/08_set_operations.sql`

**Practice**
1. Compare a UNION with UNION ALL on order status selections.
2. Find products appearing in both paid and pending orders.
3. Find teams with employees but no manager-level employees.

**Check:** Every SELECT in a compound query must return the same number of columns.
