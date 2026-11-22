WITH order_totals AS (
  SELECT o.order_id, o.customer_id, SUM(i.quantity * i.unit_price_cents) AS total_cents
  FROM orders o
  JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.order_id, o.customer_id
)
SELECT customer_id, COUNT(*) AS paid_orders, ROUND(AVG(total_cents)) AS avg_order_cents
FROM order_totals
GROUP BY customer_id
ORDER BY customer_id;
