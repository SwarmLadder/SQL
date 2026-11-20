# 01 · Scalar, IN, and derived-table subqueries

**Learn**
- Subqueries can return a scalar, a set of values, or a temporary table.
- Favor readable queries and test NULL behavior; not every subquery performs the same.

**Run:** `python tools/run_sql.py intermediate/lessons/01_subqueries.sql`

**Practice**
1. Find employees paid above their team average using a subquery.
2. Find product IDs purchased in paid orders.
3. Find customers with no paid orders using a NOT EXISTS alternative.

**Check:** A scalar subquery should be written with a clear expectation about row count.
