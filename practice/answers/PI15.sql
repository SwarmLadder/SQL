SELECT o.order_id, o.customer_id,
  CAST(julianday(o.ordered_at) - julianday(c.joined_at) AS INTEGER) AS days_after_signup
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE julianday(o.ordered_at) - julianday(c.joined_at) > 7
ORDER BY o.order_id;
