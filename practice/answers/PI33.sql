WITH revenue AS (
  SELECT o.customer_id, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.customer_id
)
SELECT customer_id, revenue_cents,
  ROUND(100.0 * revenue_cents / SUM(revenue_cents) OVER (), 1) AS pct_of_total
FROM revenue
ORDER BY revenue_cents DESC, customer_id;
