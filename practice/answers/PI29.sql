WITH revenue AS (
  SELECT o.customer_id, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.customer_id
)
SELECT c.customer_id, c.full_name, r.revenue_cents
FROM revenue r
JOIN customers c ON c.customer_id = r.customer_id
WHERE r.revenue_cents >= 15000
ORDER BY r.revenue_cents DESC, c.customer_id;
