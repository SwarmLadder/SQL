# 04 · CASE and conditional aggregation

**Learn**
- `CASE WHEN ... THEN ... ELSE ... END` calculates conditional values.
- `SUM(CASE ...)` and `COUNT(CASE ...)` create pivot-style summaries.

**Run:** `python tools/run_sql.py intermediate/lessons/04_case_conditional.sql`

**Practice**
1. Classify products as cheap/medium/expensive with explicit thresholds.
2. Count paid, pending, and cancelled orders in one row.
3. Count employees per team who earn above 8000000 cents.

**Check:** Always include ELSE when an unhandled case should not become NULL.
