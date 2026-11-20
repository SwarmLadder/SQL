# 06 · INNER JOIN relationships

**Learn**
- Use `JOIN ... ON` to connect tables via keys.
- One-to-many joins duplicate parent values; aggregate at the correct grain.

**Run:** `python tools/run_sql.py basics/lessons/06_joins.sql`

**Practice**
1. List order IDs with customer city and order status.
2. List each employee alongside their team.
3. Show every ordered item with its SKU and quantity.

**Check:** Never join by display names when stable IDs exist.
