-- 06 · LAG, LEAD, and running totals
-- Examples from intermediate/lessons/06_windows_running.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/lessons/06_windows_running.sql
SELECT customer_id, order_id, ordered_at,
       LAG(ordered_at)  OVER w AS previous_order,
       LEAD(ordered_at) OVER w AS next_order,
       CAST(julianday(ordered_at) - julianday(LAG(ordered_at) OVER w) AS INTEGER) AS days_since_previous
FROM orders
WINDOW w AS (PARTITION BY customer_id ORDER BY ordered_at, order_id)
ORDER BY customer_id, ordered_at;

WITH monthly AS (
  SELECT SUBSTR(o.ordered_at, 1, 7) AS month,
         SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o
  JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY month
)
SELECT month, revenue_cents,
       LAG(revenue_cents) OVER (ORDER BY month) AS previous_cents,
       revenue_cents - LAG(revenue_cents) OVER (ORDER BY month) AS change_cents,
       ROUND(100.0 * (revenue_cents - LAG(revenue_cents) OVER (ORDER BY month))
             / LAG(revenue_cents) OVER (ORDER BY month), 1) AS change_pct
FROM monthly
ORDER BY month;

SELECT paid_at, payment_id, amount_cents,
       SUM(amount_cents) OVER (ORDER BY paid_at, payment_id) AS running_cents,
       COUNT(*)          OVER (ORDER BY paid_at, payment_id) AS payments_so_far
FROM payments
ORDER BY paid_at, payment_id;

WITH monthly AS (
  SELECT SUBSTR(paid_at, 1, 7) AS month, SUM(amount_cents) AS revenue_cents
  FROM payments GROUP BY month
)
SELECT month, revenue_cents,
       ROUND(AVG(revenue_cents) OVER (ORDER BY month
                                      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)) AS moving_avg_3,
       SUM(revenue_cents) OVER (ORDER BY month
                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS grand_total
FROM monthly
ORDER BY month;

BEGIN;
INSERT INTO payments VALUES (91, 109, 50, 'cash', '2026-06-21');

SELECT paid_at, payment_id, amount_cents,
       SUM(amount_cents) OVER (ORDER BY paid_at) AS range_default,
       SUM(amount_cents) OVER (ORDER BY paid_at ROWS UNBOUNDED PRECEDING) AS rows_frame
FROM payments
WHERE paid_at >= '2026-06-01'
ORDER BY paid_at, payment_id;

ROLLBACK;
