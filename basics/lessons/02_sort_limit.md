# 02 · ORDER BY and LIMIT

**Learn**
- `ORDER BY` makes result order explicit; without it, row order is not guaranteed.
- Use multiple sort keys for deterministic ties. `LIMIT` restricts returned rows.

**Run:** `python tools/run_sql.py basics/lessons/02_sort_limit.sql`

**Practice**
1. Find the two cheapest active products.
2. List the latest five orders.
3. Show customer names sorted Z–A.

**Check:** OFFSET pagination may become slow or inconsistent on changing data.
