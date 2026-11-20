# 02 · Recursive CTEs and hierarchies

**Learn**
- `WITH RECURSIVE` walks connected records by repeatedly expanding prior results.
- Always define a base case and termination condition; protect against cycles in real graphs.

**Run:** `python tools/run_sql.py advanced/lessons/02_recursive_cte.sql`

**Practice**
1. Show each employee with their chain depth.
2. Create a recursive sequence of powers of two under 1024.
3. Explain how to prevent cycles in untrusted hierarchy data.

**Check:** Depth bounds do not guarantee correctness, but help bound runaway work.
