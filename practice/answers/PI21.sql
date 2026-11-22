WITH lines AS (
  SELECT order_id, COUNT(*) AS line_count FROM order_items GROUP BY order_id
), pays AS (
  SELECT order_id, COUNT(*) AS payment_count FROM payments GROUP BY order_id
)
SELECT o.order_id, lines.line_count, COALESCE(pays.payment_count, 0) AS payment_count
FROM orders o
JOIN lines ON lines.order_id = o.order_id
LEFT JOIN pays ON pays.order_id = o.order_id
WHERE o.status = 'paid'
ORDER BY o.order_id;
