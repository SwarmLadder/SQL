# Worked example I4 · The median order value

**Problem.** One big order makes the *average* order value misleading. Finance asks for the **median**: the middle value when orders are sorted. SQLite has no `MEDIAN()` function.

**Run:** `python tools/run_sql.py intermediate/worked_examples/04_median.sql`

## 1. Plan

1. Compute each paid order's value (one row per order).
2. Number the orders by value and count them.
3. With *n* orders, the median is the middle row (odd *n*) or the average of the two middle rows (even *n*).

## 2. Average vs median

```sql
WITH order_values AS (
  SELECT o.order_id, SUM(i.quantity * i.unit_price_cents) AS value_cents
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.order_id
), ranked AS (
  SELECT value_cents,
         ROW_NUMBER() OVER (ORDER BY value_cents) AS rn,
         COUNT(*) OVER () AS n
  FROM order_values
)
SELECT (SELECT ROUND(AVG(value_cents)) FROM order_values) AS mean_cents,
       AVG(value_cents) AS median_cents
FROM ranked
WHERE rn IN ((n + 1) / 2, (n + 2) / 2);
```

<!-- result -->
| mean_cents | median_cents |
|---|---|
| 12744.0 | 12575.0 |
<!-- /result -->

With *n* = 8, the integer expressions `(n + 1) / 2` and `(n + 2) / 2` give rows 4 and 5, the two middle ones, and `AVG` of them is the median. With odd *n* both give the same row.

## 3. Show the effect of an outlier

```sql
BEGIN;
INSERT INTO orders VALUES (130, 2, '2026-08-01', 'paid');
INSERT INTO order_items VALUES (130, 4, 10, 15900);

WITH order_values AS (
  SELECT o.order_id, SUM(i.quantity * i.unit_price_cents) AS value_cents
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.order_id
), ranked AS (
  SELECT value_cents, ROW_NUMBER() OVER (ORDER BY value_cents) AS rn, COUNT(*) OVER () AS n
  FROM order_values
)
SELECT (SELECT ROUND(AVG(value_cents)) FROM order_values) AS mean_cents,
       AVG(value_cents) AS median_cents
FROM ranked
WHERE rn IN ((n + 1) / 2, (n + 2) / 2);

ROLLBACK;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

| mean_cents | median_cents |
|---|---|
| 28994.0 | 13800.0 |
<!-- /result -->

One order of ten keyboards (159 000 cents) roughly doubles the mean; the median barely moves. That's why medians (and percentiles) are preferred for "typical" values.

## 4. Variations

- **Median per group:** add `PARTITION BY group_col` to both window functions and group the outer query by it.
- **Percentiles:** `NTILE(100)` or `PERCENT_RANK()` give approximate percentiles; PostgreSQL has `percentile_cont(0.5) WITHIN GROUP (ORDER BY x)`.
- Ties don't matter for the median value, only for *which* row is chosen.

**Practise next:** [PI33](../../practice/starter/PI33.sql), [PI35](../../practice/starter/PI35.sql).
