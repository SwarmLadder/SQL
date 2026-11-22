-- Cohort and Retention Report: reference solution. Runs on a fresh sample database.

-- Ticket 1: one row per customer with the facts every later stage needs.
WITH per_customer AS (
  SELECT c.customer_id,
         strftime('%Y-%m', c.joined_at) AS cohort,
         c.joined_at,
         MIN(CASE WHEN o.status = 'paid' THEN o.ordered_at END) AS first_paid_at,
         SUM(CASE WHEN o.status = 'paid' THEN 1 ELSE 0 END) AS paid_orders
  FROM customers c
  LEFT JOIN orders o ON o.customer_id = c.customer_id
  GROUP BY c.customer_id, c.joined_at
)
-- Ticket 2: cohort table.
SELECT cohort,
       COUNT(*) AS customers,
       SUM(CASE WHEN paid_orders >= 1 THEN 1 ELSE 0 END) AS converted,
       SUM(CASE WHEN paid_orders >= 2 THEN 1 ELSE 0 END) AS repeat_buyers,
       ROUND(100.0 * SUM(CASE WHEN paid_orders >= 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS conversion_pct,
       ROUND(AVG(julianday(first_paid_at) - julianday(joined_at)), 1) AS avg_days_to_first_paid
FROM per_customer
GROUP BY cohort
ORDER BY cohort;

-- Ticket 3: time between consecutive orders, per customer.
WITH gaps AS (
  SELECT customer_id, order_id, ordered_at,
         julianday(ordered_at) - julianday(LAG(ordered_at) OVER (PARTITION BY customer_id ORDER BY ordered_at, order_id)) AS gap_days
  FROM orders
)
SELECT customer_id, COUNT(gap_days) AS repeat_orders, CAST(AVG(gap_days) AS INTEGER) AS avg_gap_days
FROM gaps
GROUP BY customer_id
HAVING COUNT(gap_days) > 0
ORDER BY customer_id;

-- Ticket 4: a reusable view with each customer's lifecycle stage.
CREATE VIEW customer_lifecycle AS
SELECT c.customer_id, c.full_name,
       CASE
         WHEN SUM(CASE WHEN o.status = 'paid' THEN 1 ELSE 0 END) >= 2 THEN 'repeat'
         WHEN SUM(CASE WHEN o.status = 'paid' THEN 1 ELSE 0 END) = 1  THEN 'converted'
         WHEN COUNT(o.order_id) > 0                                  THEN 'tried'
         ELSE 'registered'
       END AS stage
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name;

SELECT stage, COUNT(*) AS customers FROM customer_lifecycle GROUP BY stage ORDER BY customers DESC, stage;
