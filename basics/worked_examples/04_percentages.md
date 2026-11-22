# Worked example B4 · Percentages that aren't zero

**Problem.** "What percentage of our orders were paid?" A one-line question that produces a wrong answer surprisingly often.

**Run:** `python tools/run_sql.py basics/worked_examples/04_percentages.sql`

## 1. Plan

A percentage is `100 × part / whole`. Both counts come from the same table, with different filters: the *part* is paid orders, the *whole* is all orders.

## 2. Tempting attempt

```sql
SELECT (SELECT COUNT(*) FROM orders WHERE status = 'paid') * 100
       / (SELECT COUNT(*) FROM orders) AS paid_pct_int,
       (SELECT COUNT(*) FROM orders WHERE status = 'paid')
       / (SELECT COUNT(*) FROM orders) * 100 AS paid_pct_broken;
```

<!-- result -->
| paid_pct_int | paid_pct_broken |
|---|---|
| 72 | 0 |
<!-- /result -->

- `paid_pct_int` gives 72, not 72.7: integer division throws away the fraction.
- `paid_pct_broken` gives **0**: `8 / 11` is 0 in integer arithmetic, and 0 × 100 is still 0.

## 3. Fix: real division, then round for display

```sql
SELECT COUNT(*) AS orders,
       SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid,
       ROUND(100.0 * SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) / COUNT(*), 1) AS paid_pct
FROM orders;
```

<!-- result -->
| orders | paid | paid_pct |
|---|---|---|
| 11 | 8 | 72.7 |
<!-- /result -->

`100.0` makes the whole expression real. One scan counts both the part and the whole. The `CASE` inside `SUM` is previewed here and taught fully in [Intermediate 04](../../intermediate/lessons/04_case_conditional.md).

## 4. Edge cases

**Zero in the denominator.** Percentages per group break on empty groups. `NULLIF(x, 0)` turns a zero divisor into NULL, so the result is NULL ("no data") instead of an error:

```sql
SELECT status,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM orders WHERE status = 'refunded'), 0), 1) AS pct_of_refunded
FROM orders
GROUP BY status
ORDER BY status;
```

<!-- result -->
| status | orders | pct_of_refunded |
|---|---|---|
| cancelled | 1 | *NULL* |
| paid | 8 | *NULL* |
| pending | 2 | *NULL* |
<!-- /result -->

(SQLite returns NULL for division by zero anyway; PostgreSQL raises an error. `NULLIF` makes the intent portable.)

**Shares that don't add up to 100.** Three groups of 1/3 round to 33.3 + 33.3 + 33.3 = 99.9. Keep full precision for calculations and say "may not sum to 100 because of rounding" in reports.

**Practise next:** [PB37](../../practice/starter/PB37.sql), [PI31](../../practice/starter/PI31.sql).
