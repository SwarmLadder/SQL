# 09 · Advanced reporting capstone

**Learn**
- Build a reliable business report using CTEs, windows, and reconciliation.
- Define the grain and monetary units. Check totals against the source records.

**Run:** `python tools/run_sql.py advanced/lessons/09_advanced_capstone.sql`

**Practice**
1. Create an order-to-payment reconciliation report with mismatch flags.
2. Add category-level revenue shares of paid item value.
3. Explain how you would index and test the report on millions of rows.

**Check:** Report queries must define 'paid', 'revenue', and `NULL` explicitly.
