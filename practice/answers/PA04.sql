WITH stats AS (
  SELECT customer_id, COUNT(*) AS order_count, MAX(ordered_at) AS last_ordered_at
  FROM orders
  GROUP BY customer_id
)
SELECT c.customer_id, COALESCE(s.order_count, 0) AS order_count, s.last_ordered_at
FROM customers c
LEFT JOIN stats s ON s.customer_id = c.customer_id
ORDER BY c.customer_id;
