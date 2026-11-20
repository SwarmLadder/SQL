WITH paid_order_totals AS (
  SELECT o.order_id,o.customer_id,o.ordered_at,
         SUM(oi.quantity*oi.unit_price_cents) AS total_cents
  FROM orders o JOIN order_items oi ON oi.order_id=o.order_id
  WHERE o.status='paid'
  GROUP BY o.order_id,o.customer_id,o.ordered_at
),
customer_totals AS (
  SELECT c.customer_id,c.full_name,
         COUNT(p.order_id) AS paid_orders,
         COALESCE(SUM(p.total_cents),0) AS lifetime_value_cents
  FROM customers c LEFT JOIN paid_order_totals p ON p.customer_id=c.customer_id
  GROUP BY c.customer_id,c.full_name
)
SELECT *, DENSE_RANK() OVER (ORDER BY lifetime_value_cents DESC) AS value_rank
FROM customer_totals ORDER BY value_rank,customer_id;
WITH monthly AS (
  SELECT SUBSTR(o.ordered_at,1,7) AS month,
         SUM(oi.quantity*oi.unit_price_cents) AS revenue_cents
  FROM orders o JOIN order_items oi ON oi.order_id=o.order_id
  WHERE o.status='paid' GROUP BY SUBSTR(o.ordered_at,1,7)
)
SELECT month,revenue_cents,
       LAG(revenue_cents) OVER (ORDER BY month) AS prior_month_cents
FROM monthly ORDER BY month;
