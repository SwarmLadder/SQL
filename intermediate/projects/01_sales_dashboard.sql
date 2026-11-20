WITH order_totals AS (
  SELECT o.order_id, o.customer_id, o.ordered_at,
         SUM(i.quantity*i.unit_price_cents) AS total_cents
  FROM orders o JOIN order_items i ON i.order_id=o.order_id
  WHERE o.status='paid'
  GROUP BY o.order_id,o.customer_id,o.ordered_at
), monthly AS (
  SELECT SUBSTR(ordered_at,1,7) AS month,
         COUNT(*) AS paid_orders,
         SUM(total_cents) AS revenue_cents
  FROM order_totals GROUP BY SUBSTR(ordered_at,1,7)
)
SELECT month,paid_orders,revenue_cents,
       LAG(revenue_cents) OVER (ORDER BY month) AS previous_month_cents,
       SUM(revenue_cents) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING) AS year_to_date_cents
FROM monthly ORDER BY month;
WITH paid_customer_totals AS (
 SELECT o.customer_id, SUM(i.quantity*i.unit_price_cents) AS revenue_cents
 FROM orders o JOIN order_items i ON i.order_id=o.order_id
 WHERE o.status='paid' GROUP BY o.customer_id
)
SELECT c.customer_id,c.full_name,COALESCE(t.revenue_cents,0) AS lifetime_cents,
       DENSE_RANK() OVER (ORDER BY COALESCE(t.revenue_cents,0) DESC) AS rank_by_value
FROM customers c LEFT JOIN paid_customer_totals t ON t.customer_id=c.customer_id
ORDER BY rank_by_value,c.customer_id;
