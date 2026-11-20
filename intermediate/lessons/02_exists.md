# 02 · EXISTS and correlated subqueries

**Learn**
- `EXISTS` tests whether matching rows exist; its output does not depend on the selected columns.
- `NOT EXISTS` is generally easier to reason about than `NOT IN` when NULLs are possible.

**Run:** `python tools/run_sql.py intermediate/lessons/02_exists.sql`

**Practice**
1. Find customers with at least one pending order.
2. Find teams without employees using NOT EXISTS.
3. List products not sold on paid orders (ignore unpaid order lines).

**Check:** Correlated subqueries reference columns from the outer query.
