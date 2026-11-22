SELECT c.customer_id, c.full_name
FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.customer_id
    AND julianday(o.ordered_at) - julianday(c.joined_at) <= 30
)
ORDER BY c.customer_id;
