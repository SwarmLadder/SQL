-- Worked example I4 · The median order value
-- Examples from intermediate/worked_examples/04_median.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/worked_examples/04_median.sql
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
