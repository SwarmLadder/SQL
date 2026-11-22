-- Worked example I2: a signup cohort table (rows = signup month, columns = order outcome).

-- Step 1: one row per customer with the facts we need.
WITH per_customer AS (
  SELECT c.customer_id,
         strftime('%Y-%m', c.joined_at) AS cohort,
         SUM(CASE WHEN o.status = 'paid' THEN 1 ELSE 0 END) AS paid_orders,
         COUNT(o.order_id) AS all_orders
  FROM customers c
  LEFT JOIN orders o ON o.customer_id = c.customer_id
  GROUP BY c.customer_id
)
-- Step 2: pivot those facts into columns per cohort with conditional aggregation.
SELECT cohort,
       COUNT(*) AS customers,
       SUM(CASE WHEN all_orders = 0 THEN 1 ELSE 0 END) AS never_ordered,
       SUM(CASE WHEN paid_orders = 1 THEN 1 ELSE 0 END) AS paid_once,
       SUM(CASE WHEN paid_orders >= 2 THEN 1 ELSE 0 END) AS paid_repeat,
       ROUND(100.0 * SUM(CASE WHEN paid_orders >= 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS paying_pct
FROM per_customer
GROUP BY cohort
ORDER BY cohort;
