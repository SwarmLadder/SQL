-- 03 · Common table expressions
-- Examples from intermediate/lessons/03_cte.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/lessons/03_cte.sql
WITH paid_orders AS (
  SELECT order_id, customer_id, ordered_at
  FROM orders
  WHERE status = 'paid'
)
SELECT customer_id, COUNT(*) AS paid_orders, MAX(ordered_at) AS last_paid_order
FROM paid_orders
GROUP BY customer_id
ORDER BY customer_id;

WITH item_totals AS (          -- one row per order
  SELECT order_id, SUM(quantity * unit_price_cents) AS items_cents
  FROM order_items
  GROUP BY order_id
),
payment_totals AS (            -- one row per order that has payments
  SELECT order_id, SUM(amount_cents) AS paid_cents
  FROM payments
  GROUP BY order_id
),
paid_order_report AS (         -- one row per paid order
  SELECT o.order_id, o.customer_id, t.items_cents,
         COALESCE(p.paid_cents, 0) AS paid_cents
  FROM orders o
  JOIN item_totals t ON t.order_id = o.order_id
  LEFT JOIN payment_totals p ON p.order_id = o.order_id
  WHERE o.status = 'paid'
)
SELECT customer_id,
       COUNT(*)         AS paid_orders,
       SUM(items_cents) AS items_cents,
       SUM(paid_cents)  AS paid_cents
FROM paid_order_report
GROUP BY customer_id
ORDER BY items_cents DESC, customer_id;

WITH monthly AS (
  SELECT SUBSTR(o.ordered_at, 1, 7) AS month,
         SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o
  JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY month
)
SELECT month, revenue_cents,
       (SELECT ROUND(AVG(revenue_cents)) FROM monthly) AS avg_month_cents
FROM monthly
WHERE revenue_cents > (SELECT AVG(revenue_cents) FROM monthly)
ORDER BY month;

WITH item_totals AS (
  SELECT order_id, SUM(quantity * unit_price_cents) AS items_cents
  FROM order_items
  GROUP BY order_id
)
SELECT COUNT(*) AS rows_in_stage,
       COUNT(DISTINCT order_id) AS distinct_orders
FROM item_totals;
