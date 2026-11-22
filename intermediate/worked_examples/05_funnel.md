# Worked example I5 · An order funnel by month

**Problem.** Product wants a funnel per month: how many orders were placed, how many got paid, how many were cancelled, and the conversion rate. All in **one** query, one row per month.

**Run:** `python tools/run_sql.py intermediate/worked_examples/05_funnel.sql`

## 1. Plan

- Grain: one row per order month.
- Each column counts the same orders under a different condition, which is the job of conditional aggregation.
- Conversion = paid ÷ placed, as a real-number percentage.

## 2. Tempting attempt: one query per status

```sql
SELECT strftime('%Y-%m', ordered_at) AS month, COUNT(*) AS paid
FROM orders WHERE status = 'paid'
GROUP BY month ORDER BY month;
```

<!-- result -->
| month | paid |
|---|---|
| 2026-01 | 1 |
| 2026-02 | 1 |
| 2026-03 | 1 |
| 2026-04 | 1 |
| 2026-05 | 1 |
| 2026-06 | 2 |
| 2026-07 | 1 |
<!-- /result -->

Three such queries must then be glued together, and months with **no** paid orders vanish from this one, so the pieces don't line up.

## 3. Fix: one scan, many conditions

```sql
SELECT strftime('%Y-%m', ordered_at) AS month,
       COUNT(*) AS placed,
       SUM(CASE WHEN status = 'paid'      THEN 1 ELSE 0 END) AS paid,
       SUM(CASE WHEN status = 'pending'   THEN 1 ELSE 0 END) AS pending,
       SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
       ROUND(100.0 * SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) / COUNT(*), 1) AS conversion_pct
FROM orders
GROUP BY month
ORDER BY month;
```

<!-- result -->
| month | placed | paid | pending | cancelled | conversion_pct |
|---|---|---|---|---|---|
| 2026-01 | 1 | 1 | 0 | 0 | 100.0 |
| 2026-02 | 1 | 1 | 0 | 0 | 100.0 |
| 2026-03 | 2 | 1 | 1 | 0 | 50.0 |
| 2026-04 | 2 | 1 | 0 | 1 | 50.0 |
| 2026-05 | 2 | 1 | 1 | 0 | 50.0 |
| 2026-06 | 2 | 2 | 0 | 0 | 100.0 |
| 2026-07 | 1 | 1 | 0 | 0 | 100.0 |
<!-- /result -->

## 4. Add a running total and test

```sql
WITH funnel AS (
  SELECT strftime('%Y-%m', ordered_at) AS month,
         COUNT(*) AS placed,
         SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid
  FROM orders
  GROUP BY month
)
SELECT month, placed, paid,
       SUM(paid)   OVER (ORDER BY month) AS paid_to_date,
       SUM(placed) OVER (ORDER BY month) AS placed_to_date,
       ROUND(100.0 * SUM(paid) OVER (ORDER BY month) / SUM(placed) OVER (ORDER BY month), 1) AS cumulative_conversion_pct
FROM funnel
ORDER BY month;
```

<!-- result -->
| month | placed | paid | paid_to_date | placed_to_date | cumulative_conversion_pct |
|---|---|---|---|---|---|
| 2026-01 | 1 | 1 | 1 | 1 | 100.0 |
| 2026-02 | 1 | 1 | 2 | 2 | 100.0 |
| 2026-03 | 2 | 1 | 3 | 4 | 75.0 |
| 2026-04 | 2 | 1 | 4 | 6 | 66.7 |
| 2026-05 | 2 | 1 | 5 | 8 | 62.5 |
| 2026-06 | 2 | 2 | 7 | 10 | 70.0 |
| 2026-07 | 1 | 1 | 8 | 11 | 72.7 |
<!-- /result -->

**Checks:**

- `paid + pending + cancelled = placed` on every row. If not, a new status exists that the `CASE` branches miss.
- The final `placed_to_date` (11) equals `SELECT COUNT(*) FROM orders`.
- Months with no orders at all are still missing. Add a calendar ([Advanced 02](../../advanced/lessons/02_recursive_cte.md)) if the chart needs them.

**Practise next:** [PI08](../../practice/starter/PI08.sql), [PI30](../../practice/starter/PI30.sql).
