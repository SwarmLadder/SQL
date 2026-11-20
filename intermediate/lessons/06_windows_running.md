# 06 · LAG, LEAD, and running totals

**Learn**
- `LAG` and `LEAD` access adjacent rows within a window ordering.
- Use an explicit window frame for running aggregates where appropriate.

**Run:** `python tools/run_sql.py intermediate/lessons/06_windows_running.sql`

**Practice**
1. Compute each customer's time gap between consecutive orders.
2. Show monthly revenue and its month-over-month change.
3. Explain the impact of ROWS versus default RANGE for duplicate sort values.

**Check:** Ordering defines what 'previous', 'next', and 'running' mean.
