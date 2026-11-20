# Sales Dashboard with CTEs and Windows

**Deliverables**
- Monthly paid revenue and order count.
- Month-over-month revenue comparison with LAG.
- Customer lifetime value ranking without duplicate multiplication.

**Run:** `python tools/run_sql.py intermediate/projects/01_sales_dashboard.sql`

**Extend**
1. Add category-level revenue per month.
2. Add the percentage change from the previous month, handling division by zero.
3. Compare sum of monthly amounts with sum of per-order amounts.

**Done when:** your queries run on a fresh database and results match the stated business definitions.
