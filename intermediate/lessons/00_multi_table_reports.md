# 00 · Multi-table reporting

**Learn**
- Define one row per business entity before joining tables.
- Joining two one-to-many tables can multiply amounts. Aggregate each separately first.

**Run:** `python tools/run_sql.py intermediate/lessons/00_multi_table_reports.sql`

**Practice**
1. Report each customer's number of paid orders and total item value.
2. Find mismatched paid-order item totals and payment totals.
3. Explain why joining payments and order_items before summing can inflate totals.

**Check:** Never multiply facts by joining unrelated detail tables at once.
