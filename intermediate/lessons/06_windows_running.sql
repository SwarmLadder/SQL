SELECT order_id, customer_id, ordered_at,
       LAG(ordered_at) OVER (PARTITION BY customer_id ORDER BY ordered_at, order_id) AS previous_order
FROM orders ORDER BY customer_id, ordered_at;
WITH daily AS (
  SELECT o.ordered_at, SUM(oi.quantity * oi.unit_price_cents) AS daily_total
  FROM orders o JOIN order_items oi ON oi.order_id=o.order_id
  WHERE o.status='paid'
  GROUP BY o.ordered_at
)
SELECT ordered_at, daily_total,
       SUM(daily_total) OVER (ORDER BY ordered_at ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM daily ORDER BY ordered_at;
SELECT full_name, team_id, salary_cents,
       LEAD(salary_cents) OVER (PARTITION BY team_id ORDER BY salary_cents DESC) AS next_salary
FROM employees ORDER BY team_id, salary_cents DESC;
